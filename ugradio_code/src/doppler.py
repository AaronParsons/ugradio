#from __future__ import absolute_import
#import barycorrpy
#import astropy.time
#from . import nch
#
#def get_projected_velocity(ra, dec, jd, obs_lat=nch.lat, obs_lon=nch.lon, 
#        obs_alt=nch.alt, epoch=2451545.):
#    '''Compute the projected velocity of the telescope wrt the 
#    Local Standard of Rest.
#    Parameters
#    ----------
#    ra, dec : float degrees, the RA/DEC of target
#    jd      : float, julian date (UTC) of the observation
#    obs_lat : float degrees, latitude of observatory, default=nch.lat
#    obs_lon : float degrees, longitude of observatory, default=nch.lon
#    obs_alt : float meters, altitude of observatory, default=nch.alt
#    epoch   : float, julian date epoch of ra/dec coordinates
#              default=2451545 is J2000
#
#    Returns
#    -------
#    v : float m/s, barycenter-corrected radial velocity,
#        see (Wright & Eastman, 2014) '''
#    jd_utc = astropy.time.Time(jd, format='jd', scale='utc')
#    proper_motion_ra = 0. # proper motion in ra, mas/yr
#    proper_motion_dec = 0. # proper motion in dec, mas/yr
#    parallax = 0. # parallax of target in mas
#    rv = 0. # radial velocity of target in m/s
#    zmeas = 0. # measured redshift of spectrum
#    ephemeris = 'de430' # ephemeris from jplephem, ~100MB download first use
#    v, warn, flag = barycorrpy.get_BC_vel(JDUTC=jd_utc, ra=ra, dec=dec, 
#        lat=obs_lat, longi=obs_lon, alt=obs_alt,
#        pmra=proper_motion_ra, pmdec=proper_motion_dec,
#        px=parallax, rv=rv, zmeas=zmeas,
#        epoch=epoch, ephemeris=ephemeris, leap_update=False)
#    return v
#

from astropy.time import Time
from astropy.coordinates import SkyCoord, EarthLocation, ICRS, LSRK, LSR
import astropy.units as u
from . import nch


def get_projected_velocity(
    ra, dec, jd,
    obs_lat=nch.lat,
    obs_lon=nch.lon,
    obs_alt=nch.alt,
    epoch=2451545.0,
    lsr_frame="lsrk",
):
    """
    Compute the projected observer velocity toward (ra, dec) relative to an LSR frame.

    Parameters
    ----------
    ra, dec : float
        Target coordinates in degrees.
    jd : float
        Julian date (UTC) of the observation.
    obs_lat, obs_lon : float
        Observatory geodetic latitude/longitude in degrees.
    obs_alt : float
        Observatory altitude in meters.
    epoch : float
        Epoch of input coordinates as Julian date.
        2451545.0 means J2000. Used only if you want the input coordinates
        interpreted in FK5 at that equinox rather than ICRS.
    lsr_frame : {"lsrk", "lsr"}
        Which LSR definition to use.
        "lsrk" = historical kinematic LSR (common in radio astronomy)
        "lsr"  = Schönrich et al. solar motion used by Astropy's LSR frame

    Returns
    -------
    v : float
        Projected velocity correction in m/s to add to an observed topocentric
        radial velocity to express it in the requested LSR frame.
    """


    obstime = Time(jd, format="jd", scale="utc")
    location = EarthLocation.from_geodetic(
        lon=obs_lon * u.deg,
        lat=obs_lat * u.deg,
        height=obs_alt * u.m,
    )

    # fine for standard catalog ICRS/J2000 coordinates
    sc = SkyCoord(ra=ra * u.deg, dec=dec * u.deg, frame="icrs")

    los_icrs = SkyCoord(
        ra=ra * u.deg,
        dec=dec * u.deg,
        distance=1.0 * u.kpc,
        pm_ra_cosdec=0.0 * u.mas / u.yr,
        pm_dec=0.0 * u.mas / u.yr,
        radial_velocity=0.0 * u.km / u.s,
        frame="icrs",
    )

    barycorr = sc.radial_velocity_correction(
        kind="barycentric",
        obstime=obstime,
        location=location,
    )

    frame = lsr_frame.lower()
    if frame == "lsrk":
        los_lsr = los_icrs.transform_to(LSRK())
    elif frame == "lsr":
        los_lsr = los_icrs.transform_to(LSR())
    else:
        raise ValueError("lsr_frame must be 'lsrk' or 'lsr'")

    lsr_corr = los_lsr.radial_velocity

    return (barycorr + lsr_corr).to_value(u.m / u.s)
    
