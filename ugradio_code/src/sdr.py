"""This module uses the pyrtlsdr package (built on librtlsdr) to interface
to SDR dongles based on the RTL2832/R820T2 chipset."""

from rtlsdr import RtlSdr
import numpy as np
import asyncio
import time

async def _streaming(q, sdr, nsamples):
    '''Asynchronously stream samples from an sdr onto a Queue.'''
    async for samples in sdr.stream(num_samples_or_bytes=2*nsamples, format='bytes'):
        t = time.time()
        samples = (np.frombuffer(samples, dtype='uint8') - 128).view('int8')
        samples.shape = (nsamples, 2)
        if sdr.direct:
            samples = samples[..., 0]
        await q.put((sdr.device_index, t, samples))

async def _collate_streams(q, sdrs, nblocks, nsamples):
    '''Process queue samples from multiple sdrs into blocks of data collated by sdr.'''
    shape = (nblocks, nsamples) if sdrs[0].direct else (nblocks, nsamples, 2)
    data = {sdr.device_index: np.empty(shape, dtype='int8') for sdr in sdrs}
    cnts = {sdr.device_index: 0 for sdr in sdrs}
    t_start = time.time()
    try:
        while True:
            dev_id, t, samples = await q.get()
            if t < t_start or cnts[dev_id] >= nblocks:
                continue
            data[dev_id][cnts[dev_id]] = samples
            cnts[dev_id] += 1
            q.task_done()
            if all([cnt >= nblocks for cnt in cnts.values()]):
                break
    finally:
        for sdr in sdrs:
            await sdr.stop()  # this closes the async for loop in _streaming
    return data

def capture_data(sdrs, nsamples=2048, nblocks=1):
    """
    Use SDR dongles to capture voltage samples.
    Note: the SDR analog system only passes signals from 0.5 to 24 MHz.

    Arguments:
        sdrs (SDR): an SDR object or a list of SDR objects.
        nsamples (int): number of samples to acquire. Default: 2048.
        nblocks (int): number of blocks of samples to acquire. Default:1

    Returns:
       dict of {device_index: block_of_samples}, where each device_index
        corresponds to the SDR provided, and each block_of_samples
        is a numpy.ndarray of type int8 with shape (nblocks, nsamples)
        (direct == True) or (nblocks, nsamples, 2) (direct == False). 
    """
    if isinstance(sdrs, SDR):
        sdrs = [sdrs]  # wrap a bare sdr object into a list, if provided
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    q = asyncio.Queue()
    try:
        producers = [loop.create_task(_streaming(q, sdr, nsamples)) for sdr in sdrs]
        data = loop.run_until_complete(
                    _collate_streams(q, sdrs, nblocks, nsamples)
                )  # closes sdr on exit
        asyncio.gather(*producers)  # cleanly exit the _streaming loops
    finally:
        loop.close()
    return data


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
        data = capture_data(self, nsamples=nsamples, nblocks=nblocks)
        return data[self.device_index]
