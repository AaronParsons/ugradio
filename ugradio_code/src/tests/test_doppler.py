import unittest
import ugradio.doppler

class TestDoppler(unittest.TestCase):
    def test_barycorrpy(self):
        ra = 26.0213645867
        dec = -15.9395557246  
        lat = -30.169283
        longi = -70.806789
        alt = 2241.9
        epoch = 2451545.0  
        result = ugradio.doppler.get_projected_velocity(ra, dec, 2458000., obs_lat=lat, obs_lon=longi, obs_alt=alt, epoch=epoch)
        self.assertAlmostEqual(result, 15414.6, 1)

if __name__ == '__main__':
    unittest.main()
