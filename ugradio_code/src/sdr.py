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
    asyncio.create_task(shutdown(loop, sdr))

async def shutdown(loop, sdr, signal=None):
    '''If an interrupt happens, shut down gracefully.'''
    if signal:
        logging.info(f"Received exit signal {signal.name}...")
    tasks = [t for t in asyncio.all_tasks() if t is not 
             asyncio.current_task()]
    await sdr.stop()
    await asyncio.gather(*tasks, return_exceptions=True)
    loop.stop()

def capture_data(
        direct=True,
        center_freq=1420e6,
        nsamples=2048,
        nblocks=1,
        sample_rate=2.2e6,
        gain=0.,
):
    """
    Use the SDR dongle to capture voltage samples from the input. Note that
     the analog system on these devices only lets through signals from 0.5 to
    24 MHz.

    There are two modes (corresponding to the value of direct):
    direct = True: the direct sampling is enabled (no mixing), center_freq does
    not matter and gain probably does not matter. Data returned is real.
    direct = False: use the standard I/Q sampling, center_freq is the LO of the
    mixer. Returns complex data.

    Arguments:
        direct (bool): which mode to use. Default: True.
        center_freq (float): the center frequency in Hz of the downconverter
        (LO of mixer). Ignored if direct == True. Default: 1420e6.
        nsamples (int): number of samples to acquire. Default: 2048.
        nblocks (int): number of blocks of samples to acquire. Default: 1.
        sample_rate (float): sample rate in Hz. Default: 2.2e6.
        gain (float): gain in dB to apply. Probably unnecessary when
        direct == True. Default: 0.

    Returns:
       numpy.ndarray of type float64 (direct == True) or complex64
       (direct == False). Shape is (nblocks, nsamples) when nblocks > 1 or
       (nsamples,) when nblocks == 1.
    """
    sdr = RtlSdr()
    # Make a new event loop and set it as the default
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        if direct:
            sdr.set_direct_sampling('q')
            sdr.set_center_freq(0)  # turn off the LO
        else:
            sdr.set_direct_sampling(0)
            sdr.set_center_freq(center_freq)
        sdr.set_gain(gain)
        sdr.set_sample_rate(sample_rate)
        _ = sdr.read_samples(BUFFER_SIZE)  # clear the buffer
        # Add signal handlers
        for s in (signal.SIGHUP, signal.SIGTERM, signal.SIGINT):
            loop.add_signal_handler(
                s, lambda: asyncio.create_task(shutdown(loop,sdr,signal=s)))
        # splice sdr handle into handle_exception arguments
        h = functools.partial(handle_exception, sdr=sdr)
        loop.set_exception_handler(h)
        data = loop.run_until_complete(_streaming(sdr, nblocks, nsamples))
    finally:
        sdr.close()
        loop.close()

    if direct:
        return data.real
    else:
        return data

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
    data = capture_data(
            direct=True,
            nsamples=nsamples,
            sample_rate=sample_rate,
            gain=gain
        )
    return data

def capture_data_mixer(center_freq, nsamples=2048, sample_rate=2.2e6, gain=1.):
    '''
    Use the SDR dongle as an ADC to capture voltage samples from the
    input. Unlike the capture_data_direct, we do not attempt to capture data
    directly but allows downconverting frequencies in the SDR.
    Note that the analog system on these devices only lets through
    signals from 0.5 to 24 MHz.
    Arguments:
        center_freq (float): center frequency to offset by. 
        nsamples (int): number of samples to acquire. Default 2048.
        sample_rate (float): sample rate in Hz to use. Defaul 2.2e6.
        gain (float): gain in dB to apply.
    Returns:
        numpy array (dtype float64) with dimensions (nsamples,)
    '''
    data = capture_data(
            direct=False,
            center_freq=center_freq,
            nsamples=nsamples,
            sample_rate=sample_rate,
            gain=gain
        )
    return data
