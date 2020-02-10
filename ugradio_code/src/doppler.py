import barycorrpy
import astropy.time
from . import nch

def get_projected_velocity(ra, dec, jd, obs_lat=nch.lat, obs_lon=nch.lon, 
        obs_alt=nch.alt, epoch=2451545.):
    '''Compute the projected velocity of the telescope wrt the 
    Local Standard of Rest.
    Parameters
    ----------
    ra, dec : float degrees, the RA/DEC of target
    jd      : float, julian date (UTC) of the observation
    obs_lat : float degrees, latitude of observatory, default=nch.lat
    obs_lon : float degrees, longitude of observatory, default=nch.lon
    obs_alt : float meters, altitude of observatory, default=nch.alt
    epoch   : float, julian date epoch of ra/dec coordinates
              default=2451545 is J2000

    Returns
    -------
    v : float m/s, barycenter-corrected radial velocity,
        see (Wright & Eastman, 2014) '''
    jd_utc = astropy.time.Time(jd, format='jd', scale='utc')
    proper_motion_ra = 0. # proper motion in ra, mas/yr
    proper_motion_dec = 0. # proper motion in dec, mas/yr
    parallax = 0. # parallax of target in mas
    rv = 0. # radial velocity of target in m/s
    zmeas = 0. # measured redshift of spectrum
    ephemeris = 'de430' # ephemeris from jplephem, ~100MB download first use
    v, warn, flag = barycorrpy.get_BC_vel(JDUTC=jd_utc, ra=ra, dec=dec, 
        lat=obs_lat, longi=obs_lon, alt=obs_alt,
        pmra=proper_motion_ra, pmdec=proper_motion_dec,
        px=parallax, rv=rv, zmeas=zmeas,
        epoch=epoch, ephemeris=ephemeris, leap_update=False)
    return v
