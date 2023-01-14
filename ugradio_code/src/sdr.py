"""This module uses the pyrtlsdr package (built on librtlsdr) to interface
to SDR dongles based on the RTL2832/R820T2 chipset."""

from __future__ import print_function
from rtlsdr import RtlSdr
import numpy as np
import logging
import functools
import asyncio
import signal

BUFFER_SIZE = 4096

async def _streaming(sdr, nblocks, nsamples):
    '''Asynchronously read nblocks of data from the sdr.'''
    data = np.empty((nblocks, nsamples), dtype="complex64")
    count = 0
    async for samples in sdr.stream(num_samples_or_bytes=nsamples):
        data[count] = samples
        count += 1
        if count >= nblocks:
            break
    try:
        await sdr.stop()
    except(AssertionError):
        logging.warn(f'Only returning {count} blocks.')
        return data[:count].copy()
    return data

def handle_exception(loop, context, sdr):
    '''Handle any exceptions that happen while in the asyncio loop.'''
    msg = context.get("exception", context["message"])
    logging.error(f"Caught exception: {msg}")
    if loop.is_running():
        asyncio.create_task(shutdown(loop, sdr))

async def shutdown(loop, sdr, signal=None):
    '''If an interrupt happens, shut down gracefully.'''
    if signal:
        logging.info(f"Received exit signal {signal.name}...")
    if loop.is_running():
        tasks = [t for t in asyncio.all_tasks() if t is not 
                 asyncio.current_task()]
        await sdr.stop()
        await asyncio.gather(*tasks, return_exceptions=True)
        loop.stop()

class SDR(RtlSdr):
    def __init__(self, direct=True, center_freq=1420e6, sample_rate=2.2e6,
        gain=0., fir_coeffs=None):
        """
        Initialize SDR dongle to capture voltage samples from the input.

        Arguments:
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
        RtlSdr.__init__(self)
        self.direct = direct
        if direct:
            self.set_direct_sampling('q')
            self.set_center_freq(0)  # turn off the LO
        else:
            self.set_direct_sampling(0)
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
            nblocks (int): number of blocks of samples to acquire. Default: 1.

        Returns:
           numpy.ndarray of type float64 (direct == True) or complex64
           (direct == False). Shape is (nblocks, nsamples) when nblocks > 1 or
           (nsamples,) when nblocks == 1.
        """
        # Make a new event loop and set it as the default
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            # Add signal handlers
            for s in (signal.SIGHUP, signal.SIGTERM, signal.SIGINT):
                loop.add_signal_handler(s,
                    lambda: asyncio.create_task(
                                shutdown(loop, self, signal=s)
                            )
                )
            # splice sdr handle into handle_exception arguments
            h = functools.partial(handle_exception, sdr=self)
            loop.set_exception_handler(h)
            data = loop.run_until_complete(
                        _streaming(self, nblocks, nsamples)
                    )
        finally:
            loop.close()

        if self.direct:
            return data.real
        else:
            return data
