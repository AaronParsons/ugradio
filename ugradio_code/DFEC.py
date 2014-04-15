import numpy
import pylab
import tempfile
import os

# Code for the Digital Front-End Control (DFEC)
# Abandon all hope, all ye who enter!

def set_srs(srs_num,freq=None,vpp=None,dbm=None,off=None,pha=None):
    """SRS FUNCTION GENERATOR CONTROL

    NAME: set_srs

    PURPOSE: All-in-one program to control SRS DS345 function generators

    CALLING SEQUENCE: set_srs(srs_number,freq=None,vpp=None,dbm=None,off=None,
        pha=None)
    
    REQUIRED INPUTS:
        srs_num (int): The SRS LO number (either 1 or 2).
        
    OPTIONAL INPUTS:
        freq (float): Frequency to set the LO to (in Hz). Must be between 0 and
            30 MHz. Default does not change frequency.
        vpp (float): Amplitude to set the LO to in Volts, peak to peak. Must be
            between -5 and +5 Volts. Default does not change amplitude.
        dbm (float): Amplitude to set the LO to, in dBm (decible-milliWatts). Must be
            between -36 and 23 dBm. Default does not change amplitude.
        off (float): DC offset for the LO in Volts. Must be between -5 and +5
            Volts. Default does not change amplitude.
        pha (float): Phase offset to apply to LO signal in degrees. Must be
            0 and 7200 degrees. Default does not change phase.

    EXAMPLE: set_srs(1,freq=1e7,dbm=0,pha=180)

    NOTES: You cannot set both vpp and dbm, since the are both controlling the
    amplitude of the LO. Also, one should avoid having the total voltage at any
    given time exceed +/- 5 Volts (i.e. don't set off=5 AND vpp=5).

    MODIFICATION HIST:
        -- 2/11/2014 - Initial creation.
    """

    if srs_num not in [1, 2]:
        raise Exception("ERROR: SRS generator not defined!")
    elif srs_num == 1:
        addr = '19'
    elif srs_num == 2:
        addr = '21'
    
    tempFile = tempfile.NamedTemporaryFile(delete=False)
    tempFile.write('++addr ' + addr + '\n')
    tempFile.close()
    os.system('gpib ' + tempFile.name + ' 10.32.92.86')
    os.unlink(tempFile.name)
    tempFile = tempfile.NamedTemporaryFile(delete=False)
    tempFile.write('++mode 1\n')
    tempFile.close()
    os.system('gpib ' + tempFile.name + ' 10.32.92.86')
    os.unlink(tempFile.name)
    tempFile = tempfile.NamedTemporaryFile(delete=False)
    tempFile.write('++eos 2\n')
    tempFile.close()
    os.system('gpib ' + tempFile.name + ' 10.32.92.86')
    os.unlink(tempFile.name)
    
    if (freq is not None) and (freq <= 0 or freq >= 3e7):
        raise Exception("ERROR: Freq must be between 0 Hz and 30 MHz!")
    
    if (vpp is not None) and (vpp <= -5 or vpp >= 5):
        raise Exception("ERROR: Peak-to-peak volts must be between +/- 5 V!")
    
    if (dbm is not None) and (dbm <= -36 or dbm >= 23):
        raise Exception("ERROR: Power must be between -36 and +23 dBm!")
    
    if (pha is not None) and (pha < 0 or dbm >= 7200):
        raise Exception("ERROR: Phase offset must be between 0 and 7200 degrees!")    

    if (dbm is not None) and (vpp is not None):
        raise Exception("ERROR: Cannot define both Vpp and dBm!")

    if freq is not None:
        tempFile = tempfile.NamedTemporaryFile(delete=False)
        tempFile.write('FREQ %0.6f\n' % freq)
        tempFile.close()
        os.system('gpib ' + tempFile.name + ' 10.32.92.86')
        os.unlink(tempFile.name)
    
    if vpp is not None:
        tempFile = tempfile.NamedTemporaryFile(delete=False)
        tempFile.write('AMPL %0.2f VP\n' % vpp)
        tempFile.close()
        os.system('gpib ' + tempFile.name + ' 10.32.92.86')
        os.unlink(tempFile.name)
    
    if dbm is not None:
        tempFile = tempfile.NamedTemporaryFile(delete=False)
        tempFile.write('AMPL %0.2f DB\n' % dbm)
        tempFile.close()
        os.system('gpib ' + tempFile.name + ' 10.32.92.86')
        os.unlink(tempFile.name)
    
    if off is not None:
        tempFile = tempfile.NamedTemporaryFile(delete=False)
        tempFile.write('OFFS %0.2f\n' % off)
        tempFile.close()
        os.system('gpib ' + tempFile.name + ' 10.32.92.86')
        os.unlink(tempFile.name)
    
    if pha is not None:
        tempFile = tempfile.NamedTemporaryFile(delete=False)
        tempFile.write('PHSE %0.3f\n' % pha)
        tempFile.close()
        os.system('gpib ' + tempFile.name + ' 10.32.92.86')
        os.unlink(tempFile.name)


def sampler(nSamp,freqSamp,fileName=None,dual=False,low=False,integer=False,timeWarn=True):
    """PULSAR SAMPLER FUNCTION
    NAME: sampler

    PURPOSE: Get data from the sampler in Pulsar

    CALLING SEQUENCE: sampler(nSamp,freqSamp,fileName=None,dual=False,low=False,
        integer=False, timeWarn=True)

    OUTPUT:
        data (ndarray): Series of values measured by the sampler.
    
    REQUIRED INPUTS:
        nSamp (int): Number of samples to record to the file. Must be between
            0 and 262144 samples.
        freqSamp (float): Sampling frequency (in Hz) to record data at. Must
            below 20 MHz (or 10 MHz for "dual mode").
        
    OPTIONAL INPUTS:
        fileName (str): Location of file to record data to.
        dual (bool): If True, then samples in "dual channel" mode, where data is
            recorded from two channels instead of just one.
        low (bool): "Low Voltage Mode" -- nominally, the ADC is designed to sample
            between +/- 5 Volts. However, if low is set to True, the ADC will
            sample between +/- 1 Volts. Use this only if you know your incoming
            signal will not exceed +/- 1 Volts!
        integer (bool): If set to true, will record the values as integer values
            coming from the ADC (between 0 and 4096) instead of converting the
            values to Volts.
        timeWarn (bool): If sampling for longer than a tenth of a second,
            pulsar may take an extremely long amount of time to return a value.
            Setting this to True will force the function throw an error if
            sampling for longer than this time (i.e. 10*nSamp > freqSamp)
            
    EXAMPLE: sampler(1000,1e7,dual=True,integer=True)
    
    MODIFICATION HIST:
        -- 2/11/2014 - Initial creation.
    """
    if fileName is None:
        tempFile = tempfile.NamedTemporaryFile(delete=False)
        fileName = tempFile.name
        useTemp = True
    elif not isinstance(fileName,str):
        raise Exception('ERROR: Filename must be a string!')
    else:
        useTemp = False
    
    if (freqSamp > 2e7):
        raise Exception("ERROR: Sampling frequency cannot be greater than 20 MHz!")
    elif dual and (freqSamp > 1e7):
        raise Exception("ERROR: Sampling frequency cannot be greater than 10 MHz (in dual mode)!")
    
    if (nSamp >= 262144) or (nSamp <= 0):
        raise Exception("ERROR: Number of samples must be between 0 and 262144!")
    
    if (timeWarn and (freqSamp < 10.0*nSamp)):
        raise Exception("ERROR: Sampling time is too long!")
    
    if dual:
        chanStr = 'dual'
    else:
        chanStr = 'chan=2'

    if low:
        lowStr = ' lo'
    else:
        lowStr = ''

    if integer:
        intStr = ' integer'
    else:
        intStr = ''
    
    os.system('echo adc nsamples=%i freq=%.5e %s fname=%s%s%s | /home/global/instrument/sendpc/sendpc' % (nSamp,freqSamp,chanStr,fileName,lowStr,intStr))
    data = numpy.loadtxt(fileName)
    if useTemp:
        os.unlink(tempFile.name)
    
    return data

