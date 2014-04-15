import tempfile
import os
import subprocess
import time
import numpy as np
import sys
import matplotlib.pyplot as plt
import code

def plotMeNow(x_in, y_in, x_range=100):
    '''
    Purpose: plotMeNow emulates the real time plotting mechanism of 
    startchart1.pro in IDL by taking advantage of the interactive mode 
    of pyplot in python. plotMeNow plots data from the interferometer in 
    real time to allow for visualization of the voltage values and 
    monitoring of the feed for issues.

    Input: 
    -x_in and y_in are the horizontal and vertical data points to be 
    plotted. Note that x_in and y_in are the COMPLETE arrays, not the new 
    points to be added to the plot. 
    -xwin is an optional input that will set the number of data points in the
    viewing window. By default, up to 100 data points will be displayed.

    Output:
    -There is no real output for this function, but a plot will be generated 
    and maintained as data is collected.
    
    Updates:
    -Written March 2014
    '''

    if len(x_in) != len(y_in):
        print "ERROR: X and Y arrays must contain the same number of points"
        print ""
        print "Entering interactive mode for debugging purposes." 
        print "All variables defined up until this point may be used in ipython"
        print "To exit interactive mode, use Ctrl+d"
        code.interact(local = locals())

    xMinLim = (np.floor(np.max(x_in)/(x_range*1.0))-1)*x_range
    xMaxLim = np.ceil(np.max(x_in)/(x_range*1.0))*x_range

    x_out = x_in[np.where(np.logical_and(np.less(x_in,xMaxLim),np.greater(x_in,xMinLim)))]
    y_out = y_in[np.where(np.logical_and(np.less(x_in,xMaxLim),np.greater(x_in,xMinLim)))]

    plt.cla()
    plt.ion()
    plt.title('Measured Voltage of Source Object')
    plt.xlabel('Time since start of obs (sec)')
    plt.ylabel('Voltage [V]')
    plt.plot(x_out, y_out,'-*')
    plt.xlim([xMinLim,xMaxLim])
    plt.draw()
    plt.ioff()
    
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
    data = np.loadtxt(fileName)
    if useTemp:
        os.unlink(tempFile.name)
    
    return data

def dft(xRange,xVals,yRange,inverse=False):
    """DISCRETE FOURIER TRANSFORM FUNCTION
    NAME: dft

    PURPOSE: Perform a discrete fourier transform on an array of values

    CALLING SEQUENCE: sampler(xRange,xVals,yRange,inverse=True)

    OUTPUT:
        yVals (ndarray): Complex values for each of the frequencies/times
            specified in 'yRange'.
    
    REQUIRED INPUTS:
        xRange (ndarray): The times (or frequencies, if inverse=True) that
            each of the values was measured for.
        xVals (ndarray): The measured values for the times/frequencies specifed
            in 'xRange'.
        yRange (ndarray): The frequencies (or times, if inverse=True) to
            calculate the DFT for.
        
    OPTIONAL INPUTS:
        inverse (bool): When set to true, will calculate the inverse Fourier
            transform (freq -> time, instead of time->freq).
    
    MODIFICATION HIST:
        -- 2/17/2014 - Initial creation.
    """
    
    # Super-simple DFT algorithm
    # Make sure that the arrays are ARRAYS, not LISTS
    xRange = np.asarray(xRange)
    xVals = np.asarray(xVals)
    yRange = np.asarray(yRange)
    
    # Generate an empty complex array to store values in
    yVals = np.zeros_like(yRange)
    yVals = 1.0*yVals+(1.0j*yVals)
    
    # Perform DFT over specified frequencies
    idx=0;
    for yPos in yRange:
        if inverse:
            yVals[idx] = np.sum(xVals*np.e**(1.0j*xRange*yPos*2.0*np.pi))
        else:
            yVals[idx] = np.sum(xVals*np.e**(-1.0j*xRange*yPos*2.0*np.pi))
            
        idx+=1
    
    if not inverse:
        yVals = yVals/(xVals.size)
    
    return yVals

def gpibCall(gpibString):
    tempFile = tempfile.NamedTemporaryFile(delete=False)
    tempFile.write(gpibString + '\n')
    tempFile.close()
    os.system('/home/global/ay121/python/gpib ' + tempFile.name + ' 10.32.92.86')
    os.unlink(tempFile.name)

def gpibReq(gpibString):
    tempFile = tempfile.NamedTemporaryFile(delete=False)
    tempFile.write(gpibString + '\n')
    tempFile.close()
    proc = subprocess.Popen(["/home/global/ay121/python/gpibw " + tempFile.name + " 10.32.92.86"],shell=True, stdout=subprocess.PIPE)
    (spOut,spErr) = proc.communicate()
    os.unlink(tempFile.name)
    return spOut

def sendPC(pcString):
    proc = subprocess.Popen(["echo " + pcString + "| /home/global/instrument/sendpc/sendpc"],shell=True, stdout=subprocess.PIPE)
    (spOut,spErr) = proc.communicate()
    return spOut

def getDVMData():
    gpibCall('++addr 17')
    dvmVolt = float(gpibReq('N4T3'))
    return dvmVolt

def pntHome(homeMax=5):
    '''INTERFEROMETER ANTENNA HOMING

    NAME: pntHome

    PURPOSE: Reset the encoders on the antennas by pointing home.

    CALLING SEQUENCE: pntHome(homeMax=5)
        
    OPTIONAL INPUTS:
        homeMax (int): Number of times to try homing before quiting.
            Default is 5.

    EXAMPLE: pntHome()

    NOTES: Under normal use (updating pointing every 30 or so seconds),
        you should use the homing function every hour. In short, the
        interferometer can run about 100 pointing commands before it
        begins to have appreciate pointing errors (of order the
        beamwidth of the telescope).
    '''
    
    sendPC('point tense alt_e=75 az_e=180 az_w=180 alt_w=75')
    homeStatus = sendPC('home alt_e az_e alt_w az_w').split()    
    homeAttempt = 1;
    while ((homeMax > homeAttempt) & (homeStatus[0] != 'done')):
        time.sleep(3)
        homeStatus = sendPC('home alt_e az_e alt_w az_w').split()

    if (homeStatus[0] != 'done'):
        print 'ERROR: Telescopes failed to home!'
        return 1
    else:
        print 'Homing successful after ' + str(homeAttempt) + ' tries!'
        return 0

def moveTo(az=None,alt=None,alt_w=None,az_w=None,alt_e=None,az_e=None):
    '''INTERFEROMETER ANTENNA CONTROL

    NAME: moveTo

    PURPOSE: Point the telescopes to particular encoder values of az/alt

    CALLING SEQUENCE: pntHome(homeMax=5)
        
    OPTIONAL INPUTS:
        homeMax (int): Number of times to try homing before quiting.
            Default is 5.

    EXAMPLE: pntHome()

    NOTES: Under normal use (updating pointing every 30 or so seconds),
        you should use the homing function every hour. In short, the
        interferometer can run about 100 pointing commands before it
        begins to have appreciate pointing errors (of order the
        beamwidth of the telescope).
    '''

    if (az is not None):
        az_w = az
        az_e = az
    if (alt is not None):
        alt_w = alt
        alt_e = alt

    if (((az_e is None) & (az_w is None)) & ((alt_e is None) & (alt_w is None))):
        raise Exception("ERROR: No pointing information included!")

    cmdStr = 'point tense'

    if (az_w is not None):
        cmdStr = cmdStr + ' az_w=' + str(az_w)
    if (az_e is not None):
        cmdStr = cmdStr + ' az_e=' + str(az_e)
    if (alt_w is not None):
        cmdStr = cmdStr + ' alt_w=' + str(alt_w)
    if (alt_e is not None):
        cmdStr = cmdStr + ' alt_e=' + str(alt_e)
    
    moveMsg = sendPC(cmdStr)
    return moveMsg
    
def pntSkyToEnc(az=None,alt=None,noEast=False,noWest=False):
    import pointcnfg
    pointcnfg = reload(pointcnfg)

    if ((az is None) | (alt is None)):
        raise Exception("ERROR: Not enough inputs!")
    
    az_w = float(az)
    az_e = float(az)
    alt_w = float(alt)
    alt_e = float(alt)

    if (np.less(np.mod(az_e+pointcnfg.eastAzFwrd,360.0),130) | np.greater(np.mod(az_e+pointcnfg.eastAzFwrd,360.0),310)):
        az_e = np.mod(az_e + 180,360)
        alt_e = 180 - alt_e
        eastAzOff = pointcnfg.eastAzRev
        eastElOff = pointcnfg.eastElRev
        eastFlop = pointcnfg.eastFlopRev
        eastSkew = pointcnfg.eastSkewRev
    else:
        eastAzOff = pointcnfg.eastAzFwrd
        eastElOff = pointcnfg.eastElFwrd
        eastFlop = pointcnfg.eastFlopFwrd
        eastSkew = pointcnfg.eastSkewFwrd

    if (np.less(np.mod(az_w+pointcnfg.westAzFwrd,360.0),90) | np.greater(np.mod(az_w+pointcnfg.westAzFwrd,360.0),270)):
        az_w = np.mod(az_w + 180,360)
        alt_w = 180 - alt_w
        westAzOff = pointcnfg.westAzRev
        westElOff = pointcnfg.westElRev
        westFlop = pointcnfg.westFlopRev
        westSkew = pointcnfg.westSkewRev
    else:
        westAzOff = pointcnfg.westAzFwrd
        westElOff = pointcnfg.westElFwrd
        westFlop = pointcnfg.westFlopFwrd
        westSkew = pointcnfg.westSkewFwrd
        
    alt_ec = alt_e + eastElOff + (eastFlop*np.cos(alt_e*180/np.pi))
    az_ec = np.mod(az_e + eastAzOff + eastSkew/np.cos(alt_e*180/np.pi),360)
    alt_wc = alt_w + westElOff + (westFlop*np.cos(alt_w*180/np.pi))
    az_wc = np.mod(az_w + westAzOff + westSkew/np.cos(alt_w*180/np.pi),360)

    if noWest:
        az_wc = None
        alt_wc = None
    if noEast:
        az_ec = None
        alt_ec = None

    pntDict = {'alt_w':alt_wc, 'az_w':az_wc, 'alt_e':alt_ec, 'az_e':az_ec}
    return pntDict

def pntTo(alt=None,az=None,noEast=False,noWest=False,ignoreLims=False):
    """INTERFEROMETER ANTENNA POINTING CONTROL

    NAME: pntTo

    PURPOSE: Move the telescopes to a specified az and alt.

    CALLING SEQUENCE: pntTo(alt=None,az=None,noEast=False,noWest=False,
        ignoreLims=False):
        
    OPTIONAL INPUTS:
        alt (float): Altitude to point the antenas to (in degrees). Default is
            not to move in alt.
        az (float): Azimuth to point the antennas to (in degrees). Default is
            not to move in az.
        noEast (bool): If true, do not move the east-most telescope.
        noWest (bool): If true, do not move the west-most telescope.
        ignoreLims (bool): If set to true, ignore the software limits on the
            telescope. DO NOT USE THIS IF YOU ARE NOT AN EXPERT/GSI.

    EXAMPLE: pnt(alt=45,az=180)

    NOTES: The telescopes will not point below 15 degrees in elevation, and
        not above 87 degrees in elevation. If pointing in azimuth in the
        northern hemisphere of the sky (az > 270 or az < 90), then the
        antennas will point 'backwards', which means that pointing in the
        northern half of the sky may be degraded.
        

    MODIFICATION HIST:
        -- 3/11/2014 - Initial creation.
    """

    if ((alt is None) | (az is None)):
        raise Exception("ERROR: Missing pointing information!")

    pntDict = pntSkyToEnc(alt=alt,az=az,noEast=noEast,noWest=noWest)
    if not ignoreLims:
        if (np.greater(pntDict['alt_e'],165) | np.greater(pntDict['alt_w'],165)):
            raise Exception("ERROR: Alt is too low!")
        if (np.less(pntDict['alt_e'],15) | np.less(pntDict['alt_w'],15)):
            raise Exception("ERROR: Alt is too low!")
        if (np.less(np.abs(90.0-pntDict['alt_e']),3) | np.less(np.abs(90.0-pntDict['alt_w']),3)):
            raise Exception("ERROR: Alt is too close to zenith!")
    
    pntStatus = moveTo(alt_e=pntDict['alt_e'],alt_w=pntDict['alt_w'],az_e=pntDict['az_e'],az_w=pntDict['az_w'])
    print pntStatus

def getJulDay(gmtime=None):
    if gmtime is None:
        gmtime = time.gmtime()
    
    julian = 367*gmtime.tm_year-int(7*(gmtime.tm_year+int((gmtime.tm_mon+9.0)/12.0))/4.0)+int(275.0*gmtime.tm_mon/9.0) \
             + gmtime.tm_mday +(gmtime.tm_hour/24.0)+(gmtime.tm_min/1440.0)+(gmtime.tm_sec/86400.0) + 1721013.5
    return julian

def getLST(lon=-122.254618,date=None,juldate=None):
    if ((juldate is None) & (date is None)):
        juldate = getJulDay()
    elif juldate is None:
        juldate = getJulDay(gmtime=date)
    
    cVals = [280.46061837, 360.98564736629, 0.000387933, 38710000.0 ]
    jdJ2000 = juldate - 2451545.0

    theta = cVals[0] + (cVals[1] * jdJ2000) + ((jdJ2000/36526)**2)*(cVals[2] - (jdJ2000/36425)/ cVals[3] )
    lst = np.mod(( theta + (lon))/15.0,24)
    return lst

def recordDVM(filename='voltdata.npz',sun=False,moon=False,recordLength=np.inf,verbose=True,showPlot=False,plotRange=120):
    """DIGITAL VOLT METER RECORDER

    NAME: recordDVM

    PURPOSE: Data recorder for the interferometer. Its MAGIC!

    CALLING SEQUENCE: recordDVM(filename='voltdata.npz',sun=False,moon=False,
        recordLength=np.inf,verbose=True,showPlot=False,plotRange=120)
        
    OPTIONAL INPUTS:
        fileName (string): Data file to record (in npz format). Data is saved
            as a dictionary with 5 items -- 'ra' records RA of the source
            in decimal hours, 'dec' records Dec in decimal degrees, 'lst'
            records the LST at the time that the voltage was measured, 'jd'
            records the JD at which the voltage was measured, and 'volts'
            records the measured voltage in units of Volts. Default is a file
            called 'voltdata.npz'.
        sun (bool): If set to true, will record the Sun's RA and Dec to the
            file. Default is not to record RA or Dec.
        moon (bool): If set to true, will record the Moon's RA and Dec to the
            file. Default is not to record RA or Dec.
        recordLength(float): Length to run the observations for, in seconds.
            Default will cause recordDVM to run until interrupted by Ctrl+C or
            terminal kill.
        verbose (bool): If true, will print out information about each voltage
            measurement as it is taken.
        showPlot (bool): If true, will show a live plot of the data being
            recorded to disk (requires X11 to be on).
        plotRange (float): Range in time (in seconds) to show data over.
            Default will show the data taken over the last 1-2 minutes.

    EXAMPLE: recordDVM(filename='myfolder/mydata.npz',showPlot=True)

    NOTES: The .npz file is saved with each new datapoint, which means that
        you can for the observation to stop at any point by using Ctrl+C (or
        if the observation is interrupted because of network issues, the
        data will still be saved to disk).

    MODIFICATION HIST:
        -- 3/11/2014 - Initial creation.
    """

    ra = 0
    dec = 0
    raArr = np.ndarray(0)
    decArr = np.ndarray(0)
    lstArr = np.ndarray(0)
    jdArr = np.ndarray(0)
    voltArr = np.ndarray(0)
    
    startTime = time.time()

    while np.less(time.time()-startTime,recordLength):
        if sun:
            raDec = sunPos()
            ra = raDec[0]
            dec = raDec[1]
        startSamp = time.time()
        currVolt = getDVMData()
        currLST = getLST()
        currJulDay = getJulDay()
        raArr = np.append(raArr,ra)
        decArr = np.append(decArr,dec)
        voltArr = np.append(voltArr,currVolt)
        lstArr = np.append(lstArr,currLST)
        jdArr = np.append(jdArr,currJulDay)

        if showPlot:
            plotMeNow((jdArr-jdArr[0])*86400,voltArr,x_range=plotRange/2.0)
        if verbose:
            print 'Measuring voltage: ' + str(currVolt) + ' (LST: ' + str(currLST) +'  ' + time.asctime() + ')'
        
        np.savez(filename,ra=raArr,dec=decArr,jd=jdArr,lst=lstArr,volts=voltArr)
        sys.stdout.flush()
        time.sleep(np.max([0,1.0-(time.time()-startSamp)]))
        
    

def sunPos(julDay=None):
    # Code taken from the Goddard Software library, so I think it can be
    # trusted.
    if julDay is None:
        julDay = getJulDay()
    
    dtor = np.pi/180.0
    
    julCen = (julDay - 2415020.0)/36525.0

    solarLon = (279.696678+np.mod((36000.768925*julCen), 360.0))*3600.0
    
    mEarth = 358.475844 + np.mod((35999.049750*julCen), 360.0)
    earthCorr  = (6910.1 - 17.2*julCen)*np.sin(mEarth*dtor) + 72.3*np.sin(2.0*mEarth*dtor)
    solarLon = solarLon + earthCorr
    # allow for the Venus perturbations using the mean anomaly of Venus MV
    mVenus = 212.603219 +np.mod((58517.803875*julCen), 360.0) 
    venusCorr = 4.8 * np.cos((299.1017 + mVenus - mEarth)*dtor) + \
              5.5 * np.cos((148.3133 + 2.0*mVenus - 2.0*mEarth )*dtor) + \
              2.5 * np.cos((315.9433 + 2.0*mVenus - 3.0*mEarth )*dtor) + \
              1.6 * np.cos((345.2533 + 3.0*mVenus - 4.0*mEarth )*dtor) + \
              1.0 * np.cos((318.15   + 3.0*mVenus - 5.0*mEarth )*dtor)
    solarLon = solarLon + venusCorr

    mMars = 319.529425 + np.mod(( 19139.858500*julCen), 360.0)
    marsCorr = 2.0*np.cos((343.8883 - 2.0*mMars + 2.0*mEarth)*dtor ) + \
               1.8*np.cos((200.4017 - 2.0*mMars + mEarth)*dtor)
    solarLon = solarLon + marsCorr

    mJup = 225.328328 + np.mod(( 3034.6920239*julCen), 360.0)
    jupCorr = 7.2*np.cos((179.5317 - mJup + mEarth)*dtor) + \
              2.6*np.cos((263.2167 - mJup)*dtor) + \
              2.7*np.cos(( 87.1450 - 2.0*mJup + 2.0*mEarth)*dtor) + \
              1.6*np.cos((109.4933 - 2.0*mJup + mEarth)*dtor)

    solarLon = solarLon + jupCorr

    dMoon = 350.7376814 + np.mod((445267.11422*julCen),360.0)
    moonCorr  = 6.5*np.sin(dMoon*dtor)
    solarLon = solarLon + moonCorr

    longTerm = 6.4*np.sin((231.19 + 20.20*julCen)*dtor)
    solarLon = solarLon + longTerm
    solarLon = np.mod((solarLon + 2592000.0),1296000.0)
    longMed = solarLon/3600.0
    solarLon  = solarLon - 20.5
    
    # Allow for Nutation using the longitude of the Moons mean node OMEGA

    omega = 259.183275 - np.mod(( 1934.142008*julCen),360.0)
    solarLon  =  solarLon - 17.2*np.sin(omega*dtor)
    
    oblt  = 23.452294 - 0.0130125*julCen + (9.2*np.cos(omega*dtor))/3600.0

    solarLon = solarLon/3600.0
    ra  = np.mod(np.arctan2(np.sin(solarLon*dtor)*np.cos(oblt*dtor),np.cos(solarLon*dtor)),2*np.pi)
    dec = np.arcsin(np.sin(solarLon*dtor)*np.sin(oblt*dtor))
 
    ra = (ra/dtor)/15.0
    dec = dec/dtor
    
    return [ra,dec]

