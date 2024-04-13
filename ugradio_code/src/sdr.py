"""This module uses the pyrtlsdr package (built on librtlsdr) to interface
to SDR dongles based on the RTL2832/R820T2 chipset."""

from __future__ import print_function
from rtlsdr import RtlSdr
import numpy as np
import logging
import functools
import asyncio
import signal
import time

BUFFER_SIZE = 4096

async def _streaming(q, sdr, nsamples):
    '''Asynchronously read nblocks of data from the sdr.'''
    async for samples in sdr.stream(num_samples_or_bytes=2*nsamples, format='bytes'):
        t = time.time()
        samples = (np.frombuffer(samples, dtype='uint8') - 128).view('int8')
        samples.shape = (nsamples, 2)
        if sdr.direct:
            samples = samples[..., 0]
        await q.put((sdr.device_index, t, samples))

async def _collate_streams(q, sdrs, nblocks, nsamples):
    shape = (nblocks, nsamples) if sdrs[0].direct else (nblocks, nsamples, 2)
    data = {sdr.device_index: np.empty(shape, dtype='int8') for sdr in sdrs}
    cnts = {sdr.device_index: 0 for sdr in sdrs}
    t_start = time.time()
    try:
        while True:
        #for _ in range(nblocks):
            dev_id, t, samples = await q.get()
            if t < t_start or cnts[dev_id] > nblocks:
                continue
            data[cnts[dev_id]] = samples
            cnts[dev_id] += 1
            q.task_done()
            if all([cnt >= nblocks for cnt in cnts.values()]):
                break
    finally:
        for sdr in sdrs:
            await sdr.stop()  # this closes the async for loop in _streaming
    return data

#def handle_exception(loop, context, sdr):
#    '''Handle any exceptions that happen while in the asyncio loop.'''
#    msg = context.get("exception", context["message"])
#    logging.error(f"Caught exception: {msg}")
#    if loop.is_running():
#        asyncio.create_task(shutdown(loop, sdr))
#
#async def shutdown(loop, sdr, signal=None):
#    '''If an interrupt happens, shut down gracefully.'''
#    if signal:
#        logging.info(f"Received exit signal {signal.name}...")
#    if loop.is_running():
#        tasks = [t for t in asyncio.all_tasks() if t is not 
#                 asyncio.current_task()]
#        await sdr.stop()
#        await asyncio.gather(*tasks, return_exceptions=True)
#        loop.stop()

class SDR(RtlSdr):
    def __init__(self, device_index=0, direct=True, center_freq=1420e6,
                 sample_rate=2.2e6, gain=0., fir_coeffs=None):
        """
        Initialize SDR dongle to capture voltage samples from the input.

        Arguments:
            device_index (int): index of sdr, if multiple are plugged in.
                Default = 0.
            direct (bool): sampling mode to use. If True, use direct 
                sampling (no mixing, center_freq and gain ignored) and
                return real-valued data. If False, mix with LO=center_freq
                and return complex data for standard I/Q sampling.
            center_freq (float): center frequency in Hz of the downconverter
                (LO of mixer). Ignored if direct == True. Default: 1420e6.
            sample_rate (float): sample rate in Hz. Default: 2.2e6.
            gain (float): gain in dB to apply. Probably ignored when
                direct == True. Default: 0.
            fir_coeffs (int ndarray): fir coefficients used in the 
                downconverter filter. Default: None=default.

        Returns:
           initialized SDR object
        """
        RtlSdr.__init__(self, device_index=device_index)
        self.device_index = device_index
        self.direct = direct
        if direct:
            self.set_direct_sampling('q')
            self.set_center_freq(0)  # turn off the LO
        else:
            self.set_direct_sampling(0)
            assert center_freq >= 25e6  # minimum supported freq
            assert center_freq < 1750e6  # maximum supported freq
            self.set_center_freq(center_freq)
        self.set_gain(gain)
        self.set_sample_rate(sample_rate)
        if fir_coeffs is not None:
            self.set_fir_coeffs(fir_coeffs)
        _ = self.read_samples(BUFFER_SIZE)  # clear the buffer

    def __del__(self):
        self.close()

    def capture_data(self, nsamples=2048, nblocks=1):
        """
        Use the SDR dongle to capture voltage samples from the input.
        Note: the SDR analog system only passes signals from 0.5 to 24 MHz.

        Arguments:
            nsamples (int): number of samples to acquire. Default: 2048.
            nblocks (int): number of blocks of samples to acquire. Default:1

        Returns:
           numpy.ndarray of type int8 with shape (nblocks, nsamples)
           (direct == True) or (nblocks, nsamples, 2) (direct == False). 
        """
        # Make a new event loop and set it as the default
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        q = asyncio.Queue()
        #stop_event = asyncio.Event()
        try:
            ## Add signal handlers
            #for s in (signal.SIGHUP, signal.SIGTERM, signal.SIGINT):
            #    loop.add_signal_handler(s,
            #        lambda: asyncio.create_task(
            #                    shutdown(loop, self, signal=s)
            #                )
            #    )
            ## splice sdr handle into handle_exception arguments
            #h = functools.partial(handle_exception, sdr=self)
            #loop.set_exception_handler(h)
            producer = loop.create_task(_streaming(q, self, nsamples))
            data = loop.run_until_complete(
                        _collate_streams(q, [self], nblocks, nsamples)
                    )
            #producer.cancel()
            #try:
            asyncio.gather(producer)
            #except asyncio.CancelledError:
            #    pass
        finally:
            loop.close()

        return data[self.device_index]
