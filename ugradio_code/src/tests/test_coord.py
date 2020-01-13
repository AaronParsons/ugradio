import numpy as np
import time
from astropy.coordinates import SkyCoord,EarthLocation
from astropy.time import Time
import ugradio.coord as coord
import ugradio.nch
LAT,LON = ugradio.nch.lat, ugradio.nch.lon
import unittest

JD = 2458500.3

class TestSunPos(unittest.TestCase):
    def test_sunpos(self): 
        ra1,dec1 = coord.sunpos(jd=JD)
        self.assertAlmostEqual(ra1, 298.375, 0)
        self.assertAlmostEqual(dec1, -20.8789, 0)

class TestMoonPos(unittest.TestCase):
    def test_moonpos_loc(self):
        ra2,dec2 = coord.moonpos(jd=JD,lat=LAT,lon=LON)
        self.assertAlmostEqual(ra2, 56.0618, 0)
        self.assertAlmostEqual(dec2, 14.2344, 0)

class TestGetAltAz(unittest.TestCase):

    def setUp(self):
        self.now = Time(time.time(),format='unix')
        self.c = SkyCoord('05h34m31.95s +22d00m52.1s')
        self.alt,self.az = coord.get_altaz(self.c.ra,self.c.dec,
                           jd=self.now.jd,equinox='J2000')

    def test_getaltaz_equinox(self): 
        alt2,az2 = coord.get_altaz(self.c.ra,self.c.dec,
                   jd=self.now.jd,equinox='J2018') 
        self.assertNotEqual(self.alt,alt2,
        msg='getaltaz: alt not changing with equinox.') 
        self.assertNotEqual(self.az,az2, 
        msg='getaltaz: az not changing with equinox.')
        
    def test_getaltaz_time(self):
        alt2,az2 = coord.get_altaz(self.c.ra,self.c.dec,
                   jd=self.now.jd+1,equinox='J2000') 
        self.assertNotEqual(self.alt,alt2,
        msg='getaltaz: alt not changing with time.') 
        self.assertNotEqual(self.az,az2, 
        msg='getaltaz: az not changing with time.')

if __name__ == '__main__':
    unittest.main()
