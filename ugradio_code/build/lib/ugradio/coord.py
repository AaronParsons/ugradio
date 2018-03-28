import astropy
import astropy.units as u
import nch
import time

def moonpos(jd=None, lat=nch.lat, lon=nch.lon, alt=nch.alt):
    """ Return (ra,dec) of the moon at the given Julian Date 
    when observed from the given location.

    Parameters
    ----------
    jd : float, Julian Date, default=now
    lat: float, latitude in degrees, default=nch
    lon: float, longitude in degrees, default=nch
    alt: float, altitude in m, default=nch

    Returns
    -------
    ra : float, right ascension in degrees
    dec: float, declination in degrees

    """
    if jd: t = astropy.time.Time(jd,format='jd')
    else: t = astropy.time.Time(time.time(),format='unix')
    l = astropy.coordinates.EarthLocation(lat=lat*u.deg,
                        lon=lon*u.deg,height=alt*u.m)
    moon = astropy.coordinates.get_moon(location=l,time=t)
    return moon.ra.deg, moon.dec.deg

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
    return sun.ra.deg, sun.dec.deg

def get_altaz(ra,dec,jd=None,lat=nch.lat,lon=nch.lon,alt=nch.alt,equinox='J2000'):
    """
    Return the altitude and azimuth of an object whose right ascension 
    and declination are known.

    Parameters
    ----------
    ra : float, right ascension in degrees
    dec: float, declination in degrees
    jd : float, Julian Date, default=now
    lat: float, latitude in degrees, default=nch
    lon: float, longitude in degrees, default=nch
    alt: float, altitude in m, default=nch
    equinox : string, equinox of ra/dec coordinates.  default='J2000'

    Returns
    -------
    alt : float, altitude in degrees
    az : float, azimuth in degrees
        
    """
    if jd: t = astropy.time.Time(jd,format='jd')
    else: t = astropy.time.Time(time.time(),format='unix')
    l = astropy.coordinates.EarthLocation(lat=lat*u.deg,
                        lon=lon*u.deg,height=alt*u.m)
    f = astropy.coordinates.AltAz(obstime=t,location=l)
    c = astropy.coordinates.SkyCoord(ra, dec, frame='fk5',unit='deg',equinox=equinox)
    altaz = c.transform_to(f)
    return altaz.alt.deg, altaz.az.deg

def precess(ra,dec,jd=None,equinox='J2000'):
    """
    Precess the given right ascension and declination to 
    the current equinox.

    Parameters
    ----------
    ra : float, right ascension in degrees at specified equinox
    dec: float, declination in degrees at specified equinox
    equinox : string, equinox of ra/dec coordinates.  default='J2000'

    Returns
    -------
    ra : float, right ascension in degrees
    dec : float, declination in degrees
        
    """
    c = astropy.coordinates.SkyCoord(ra,dec,unit='deg',frame='fk5',equinox='J2000')
    if jd: t = astropy.time.Time(jd,format='jd')
    else: t = astropy.time.Time(time.time(),format='unix')
    gcrs_now = astropy.coordinates.GCRS(obstime=t)
    c_now = c.transform_to(gcrs_now)
    return c_now.ra.deg, c_now.dec.deg
