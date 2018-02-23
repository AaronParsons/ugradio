import astropy
import astropy.units as u
import nch
import time

def moonpos(jd=None,loc=(nch.lat,nch.lon,nch.alt)):
    """ Return (ra,dec) of the moon at the given Julian Date 
    when observed from the given location.

    Parameters
    ----------
    jd : float, Julian Date, default=now
    loc: tuple, (latitude [degrees], longitude [degrees], altitude [m])
         default=New Campbell Hall

    Returns
    -------
    ra : float, right ascension in degrees
    dec: float, declination in degrees

    """
    if jd: t = astropy.time.Time(jd,format='jd')
    else: t = astropy.time.Time(time.time(),format='unix')
    l = astropy.coordinates.EarthLocation(lat=loc[0]*u.deg,
                        lon=loc[1]*u.deg,height=loc[2]*u.m)
    moon = astropy.coordinates.get_moon(location=l,time=t)
    return (moon.ra.deg, moon.dec.deg)

def sunpos(jd=None):
    """ Return (ra,dec) of the sun at the given Julian Date. 

    Parameters
    -----------
    jd: float, Julian Date, default=now

    Returns
    -------
    ra : float, right ascension in degrees
    dec: float, declination in degrees

    """
    if jd: t = astropy.time.Time(jd,format='jd')
    else: t = astropy.time.Time(time.time(),format='unix')
    sun = astropy.coordinates.get_sun(time=t)
    return (sun.ra.deg, sun.dec.deg)

def get_altaz((ra,dec),jd=None,loc=(nch.lat,nch.lon,nch.alt)):
    """
    Return the altitude and azimuth of an object whose right ascension 
    and declination are known.

    Parameters
    ----------
    ra : float, right ascension in degrees
    dec: float, declination in degrees
    jd : float, Julian Date, default=now
    loc: tuple, (latitude [deg], longitude [deg], altitute [m])
         default= New Campbell Hall

    Returns
    -------
    alt : float, altitude in degrees
    az : float, azimuth in degrees
        
    """
    if jd: t = astropy.time.Time(jd,format='jd')
    else: t = astropy.time.Time(time.time(),format='unix')
    l = astropy.coordinates.EarthLocation(lat=loc[0]*u.deg,
                        lon=loc[1]*u.deg,height=loc[2]*u.m)    
    f = astropy.coordinates.AltAz(obstime=t,location=l)
    c = astropy.coordinates.SkyCoord(ra, dec, frame='icrs',unit='deg')
    altaz = c.transform_to(f)
    return (altaz.alt.deg,altaz.az.deg)
