import os
import subprocess
import tempfile
import time
import numpy as np
import sys

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

    if (np.less(np.mod(az_e+pointcnfg.eastAzFwrd,360.0),90) | np.greater(np.mod(az_e+pointcnfg.eastAzFwrd,360.0),270)):
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
    if ((alt is None) | (az is None)):
        raise Exception("ERROR: Missing pointing information!")

    pntDict = pntSkyToEnc(alt=alt,az=az,noEast=noEast,noWest=noWest)
    if not ignoreLims:
        if (np.greater(pntDict['alt_e'],87) | np.greater(pntDict['alt_w'],87)):
            raise Exception("ERROR: Alt is too high!")
        if (np.less(pntDict['alt_e'],15) | np.less(pntDict['alt_w'],15)):
            raise Exception("ERROR: Alt is too low!")
    
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

def recordDVM(filename='voltdata.npz',sun=False,moon=False,recordLength=np.inf,verbose=True):
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
        decArr = np.append(decArr,ra)
        voltArr = np.append(voltArr,currVolt)
        lstArr = np.append(lstArr,currLST)
        jdArr = np.append(jdArr,currJulDay)

        if verbose:
            print 'Measuring voltage: ' + str(currVolt) + ' (LST: ' + str(currLST) +'  ' + time.asctime() + ')'
        
        np.savez(filename,ra=raArr,dec=decArr,jd=jdArr,lst=lstArr,volts=voltArr)
        sys.stdout.flush()
        time.sleep(np.max([0,1.0-(time.time()-startSamp)]))
        
    

def sunPos(julDay=None):
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

