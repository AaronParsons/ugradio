import numpy as np
import time
from astropy.coordinates import SkyCoord,EarthLocation
from astropy.time import Time
import ugradio.coord as coord
import unittest

class TestSunPos(unittest.TestCase):
    
    def setUp(self):
        self.now = Time(time.time(),format='unix')
        
    def test_sunpos_time(self): 
        ra1,dec1 = coord.sunpos(jd=self.now.jd)
        ra2,dec2 = coord.sunpos(jd=self.now.jd+1)
        self.assertNotEqual(ra1,ra2,
        msg='sunpos: ra not changing with time.') 
        self.assertNotEqual(dec1,dec2, 
        msg='sunpos: dec not changing with time.')

class TestMoonPos(unittest.TestCase):

    def setUp(self):
        self.now = Time(time.time(),format='unix')
        self.ra,self.dec = coord.moonpos(jd=self.now.jd)
        
    def test_moonpos_loc(self):
        #ra,dec should change with location
        ra2,dec2 = coord.moonpos(jd=self.now.jd,lat=38,lon=-120)
        self.assertNotEqual(self.ra,ra2,
        msg='moonpos: ra not changing with observer location.') 
        self.assertNotEqual(self.dec,dec2, 
        msg='moonpos: dec not changing with observer location.')

    def test_moonpos_time(self): 
        ra2,dec2 = coord.moonpos(jd=self.now.jd+1)
        self.assertNotEqual(self.ra,ra2,
        msg='moonpos: ra not changing with time.') 
        self.assertNotEqual(self.dec,dec2, 
        msg='moonpos: dec not changing with time.')

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
