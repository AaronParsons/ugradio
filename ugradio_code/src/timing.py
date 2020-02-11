from __future__ import absolute_import
import astropy.time
import time
import datetime
from . import nch

def unix_time(jd=None):
    '''Return (current) time, in seconds since the Epoch (00:00:00 
    Coordinated Universal Time (UTC), Thursday, 1 January 1970).
    Parameters
    ----------
    jd : float, julian date, default=now

    Returns
    -------
    t : float, seconds since the Epoch'''
    if jd is None:
        return time.time()
    else:
        t = astropy.time.Time(jd, format='jd')
        return t.unix

def local_time(unix_t=None):
    '''Return (current) local time as a string.
    Parameters
    ----------
    unix_t : seconds since the Epoch, default=now

    Returns
    -------
    t : string, e.g. "Mon Jan 23 14:56:59 2018"'''
    return time.ctime(unix_t)

def utc(unix_t=None, fmt='%a %b %d %X %Y'):
    '''Return (current) UTC time as a string.
    Parameters
    ----------
    unix_t : seconds since the Epoch, default=now
    fmt    : format string (see time.strftime), default produces 
             "Mon Jan 23 14:56:59 2018"

    Returns
    -------
    t : string, e.g. "Mon Jan 23 14:56:59 2018"'''
    gmt = time.gmtime(unix_t)
    return time.strftime(fmt, gmt)

def julian_date(unix_t=None):
    '''Return (current) time as a Julian date.
    Parameters
    ----------
    unix_t : seconds since the Epoch, default=now

    Returns
    -------
    jd : float, julian date'''
    if unix_t is None:
        unix_t = time.time()
    t = astropy.time.Time(unix_t, format='unix')
    return t.jd

def lst(jd=None, lon=nch.lon):
    '''Return (current) LST.
    Parameters
    ----------
    jd : float, julian date, default=now
    lon : float, degrees longitude, default=nch.lon

    Returns
    -------
    t : float, local sidereal time in radians'''
    if jd is None:
        jd = julian_date()
    t = astropy.time.Time(jd, format='jd')
    return t.sidereal_time('apparent', longitude=lon).radian
