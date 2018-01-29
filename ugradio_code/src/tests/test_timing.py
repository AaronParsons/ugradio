import unittest
import ugradio.timing
import astropy.time
import time, math

UNIX_TIME = 1517255985.
JD = 2458148.3331597224

class TestTime(unittest.TestCase):
    def test_unix_time(self):
        t1 = time.time()
        t2 = ugradio.timing.unix_time()
        t3 = time.time()
        self.assertLessEqual(t1, t2)
        self.assertLessEqual(t2, t3)
        t = ugradio.timing.unix_time(JD)
        self.assertAlmostEqual(t, UNIX_TIME, 4)
    def test_local_time(self):
        s = ugradio.timing.local_time(UNIX_TIME)
        self.assertEqual(s, 'Mon Jan 29 11:59:45 2018')
        t1 = time.time()
        s = ugradio.timing.local_time()
        t2 = time.strptime(s, '%a %b %d %X %Y')
        self.assertEqual(math.floor(t1), time.mktime(t2))
    def test_utc(self):
        s = ugradio.timing.utc(UNIX_TIME)
        self.assertEqual(s, 'Mon Jan 29 19:59:45 2018')
        t1 = time.time()
        s = ugradio.timing.utc()
        t = time.strptime(s, '%a %b %d %X %Y')
        self.assertAlmostEqual(t1, time.mktime(t), -5) # just check same day, b/c timezones
        # XXX think about testing format
    def test_julian_date(self):
        jd = ugradio.timing.julian_date(UNIX_TIME)
        self.assertEqual(jd, JD)
        t1 = time.time()
        jd2 = ugradio.timing.julian_date()
        t2 = ugradio.timing.unix_time(jd2)
        self.assertAlmostEqual(t1-t2, 0, 4)
    def test_lst(self):
        lst = ugradio.timing.lst(jd=JD)
        self.assertAlmostEqual(lst, 5.35285525418416, 4)
        lst = ugradio.timing.lst(jd=JD, lon=0)
        self.assertAlmostEqual(lst, 1.2034623666030373, 4)
        lst1 = ugradio.timing.lst()
        lst2 = ugradio.timing.lst()
        lst3 = ugradio.timing.lst()
        self.assertLessEqual(lst1, lst2)
        self.assertLessEqual(lst2, lst3)

if __name__ == '__main__':
    unittest.main()
