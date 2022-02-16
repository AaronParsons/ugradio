'''This module uses the pyrtlsdr package (built on librtlsdr) to interface
to SDR dongles based on the RTL2832/R820T2 chipset.'''

from __future__ import print_function
from rtlsdr import RtlSdr
import numpy as np
import time
try:
    import asyncio
except ImportError as e:
    print(e)

SAMPLE_RATE_TOLERANCE = 0.1 # Hz
BUFFER_SIZE = 4096

def capture_data_direct(nsamples=2048, sample_rate=2.2e6, gain=1.):
    '''
    Use the SDR dongle as an ADC to directly capture voltage samples from the
    input. Note that the analog system on these devices only lets through
    signals from 0.5 to 24 MHz.
    Arguments:
        nsamples (int): number of samples to acquire. Default 2048.
        sample_rate (float): sample rate in Hz to use. Defaul 2.2e6.
        gain (float): gain in dB to apply. Probably unnecessary, as direct sampling
            should bypass the gain stage.
    Returns:
        numpy array (dtype float64) with dimensions (nsamples,)
    '''
    sdr = RtlSdr()
    sdr.set_direct_sampling('q') # read from RF directly
    sdr.set_center_freq(0) # essentially turn off the LO
    sdr.set_sample_rate(sample_rate)
    #assert abs(sample_rate - sdr.get_sample_rate()) < SAMPLE_RATE_TOLERANCE
    sdr.set_gain(gain) # adjust input gain XXX does this matter?
    #assert gain == sdr.get_gain()
    _ = sdr.read_samples(BUFFER_SIZE) # clear the buffer
    data = sdr.read_samples(nsamples)
    data = data.real # only real values have meaning
    return data
 

def capture_data_mixer(
        center_freq,
        nsamples=2048,
        nblocks=1,
        sample_rate=2.2e6,
        gain=1.,
        sleep=1e-3
):
    '''
    Use the SDR dongle as an ADC to capture voltage samples from the
    input. Unlike the capture_data_direct, we do not attempt to capture data
    directly but allows downconverting frequencies in the SDR.
    Note that the analog system on these devices only lets through
    signals from 0.5 to 24 MHz.
    Arguments:
        center_freq (float): center frequency to offset by. (LO frequency) 
        nsamples (int): number of samples to acquire. Default 2048.
        nblocks (int): number of blocks of data. Default 1.
        sample_rate (float): sample rate in Hz to use. Default 2.2e6.
        gain (float): gain in dB to apply. Default 1.
        sleep (float): seconds to sleep between blocks to prevent timeout.
        Default 0.1.
    Returns:
        numpy array (dtype float64) with dimensions (nsamples,)
    '''
    sdr = RtlSdr()
    sdr.set_direct_sampling(0) # standard I/Q sampling mode
    sdr.set_center_freq(center_freq)
    sdr.set_sample_rate(sample_rate)
    #assert abs(sample_rate - sdr.get_sample_rate()) < SAMPLE_RATE_TOLERANCE
    sdr.set_gain(gain)
    #assert gain == sdr.get_gain()
    data = np.empty((nblocks, nsamples))
    _ = sdr.read_samples(BUFFER_SIZE) # clear the buffer
    for i in range(nblocks):
        data[i] = sdr.read_samples(nsamples)
        time.sleep(sleep)
    return data
     

def capture_data_aio(
        center_freq,
        nsamples=2048,
        nblocks=1,
        sample_rate=2.2e6,
        gain=1.
):
    '''
    Use the SDR dongle as an ADC to capture voltage samples from the
    input. Unlike the capture_data_direct, we do not attempt to capture data
    directly but allows downconverting frequencies in the SDR.
    Note that the analog system on these devices only lets through
    signals from 0.5 to 24 MHz.
    Arguments:
        center_freq (float): center frequency to offset by. (LO frequency) 
        nsamples (int): number of samples to acquire. Default 2048.
        nblocks (int): number of blocks of data. Default 1.
        sample_rate (float): sample rate in Hz to use. Defaul 2.2e6.
        gain (float): gain in dB to apply.
    Returns:
        numpy array (dtype float64) with dimensions (nsamples,)
    '''
    sdr = RtlSdr()
    sdr.set_direct_sampling(0) # standard I/Q sampling mode
    sdr.set_center_freq(center_freq)
    sdr.set_sample_rate(sample_rate)
    #assert abs(sample_rate - sdr.get_sample_rate()) < SAMPLE_RATE_TOLERANCE
    sdr.set_gain(gain)
    #assert gain == sdr.get_gain()
    async def streaming():
        data = np.empty((nblocks, nsamples))
        _ = sdr.read_samples(BUFFER_SIZE) # clear the buffer
        async for count, samples in enumerate(sdr.stream(num_samples_or_bytes=nsamples)):
            data[count] = samples
            if count >= nblocks:
                break

         sdr.stop()
         await sdr.stop()
         sdr.close()
         await sdr.close()
         return data
     loop = asyncio.get_event_loop()
     data = loop.run_until_complete(streaming())
     return data
     
