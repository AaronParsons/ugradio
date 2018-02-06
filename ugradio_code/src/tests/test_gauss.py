import unittest
import ugradio.gauss
import numpy as np

np.random.seed(0)

class TestGauss(unittest.TestCase):
    def test_pack_prms(self):
        amp0, avg0, sig0 = 1.5, .1, 2.2
        prms0 = ugradio.gauss._pack_prms(amp0,avg0,sig0)
        np.testing.assert_equal(prms0, np.array([amp0, avg0, sig0]))
        amp0, avg0, sig0 = [1.,2], [3.,4], [5.,6]
        prms0 = ugradio.gauss._pack_prms(amp0,avg0,sig0)
        np.testing.assert_equal(prms0, np.array([1.,3,5,2,4,6]))
    def test_unpack_prms(self):
        amp0,avg0,sig0 = ugradio.gauss._unpack_prms(np.array([1,2,3]))
        self.assertEqual(amp0, 1)
        self.assertEqual(avg0, 2)
        self.assertEqual(sig0, 3)
        prms0 = np.array([1.,3,5,2,4,6])
        amp0, avg0, sig0 = [[1.],[2]], [[3.],[4]], [[5.],[6]]
        amp, avg, sig = ugradio.gauss._unpack_prms(prms0)
        np.testing.assert_equal(amp, np.array(amp0))
        np.testing.assert_equal(avg, np.array(avg0))
        np.testing.assert_equal(sig, np.array(sig0))
    def test_perfect_gaussian(self):
        amp0, avg0, sig0 = 1.5, .1, 2.2
        x = np.linspace(-6,6, 1024)
        y = amp0 * np.exp(-(x-avg0)**2 / (2*sig0**2))
        ans = ugradio.gauss.gaussfit(x, y)
        self.assertAlmostEqual(ans['amp'], amp0, 6)
        self.assertAlmostEqual(ans['avg'], avg0, 6)
        self.assertAlmostEqual(ans['sig'], sig0, 6)
        np.testing.assert_allclose(y, ugradio.gauss.gaussval(x, **ans), 6)
    def test_noisy_gaussian(self):
        amp0, avg0, sig0 = 1.5, .1, 2.2
        x = np.linspace(-6,6, 1024)
        y = amp0 * np.exp(-(x-avg0)**2 / (2*sig0**2))
        y += np.random.normal(scale=.1, size=y.size)
        ans = ugradio.gauss.gaussfit(x, y)
        self.assertAlmostEqual(ans['amp'], amp0, 1)
        self.assertAlmostEqual(ans['avg'], avg0, 1)
        self.assertAlmostEqual(ans['sig'], sig0, 1)
        np.testing.assert_allclose(y, ugradio.gauss.gaussval(x, **ans), atol=.3)
    def test_two_gaussian(self):
        amp0, avg0, sig0 = 1.5, .1, 2.2
        amp1, avg1, sig1 = 2.5, 1.1, 1.2
        x = np.linspace(-6,6, 1024)
        y0 = amp0 * np.exp(-(x-avg0)**2 / (2*sig0**2))
        y1 = amp1 * np.exp(-(x-avg1)**2 / (2*sig1**2))
        y = y0 + y1
        ans = ugradio.gauss.gaussfit(x, y, amp=[1,1], avg=[0,1], sig=[1,1])
        self.assertAlmostEqual(ans['amp'][0], amp0, 6)
        self.assertAlmostEqual(ans['avg'][0], avg0, 6)
        self.assertAlmostEqual(ans['sig'][0], sig0, 6)
        self.assertAlmostEqual(ans['amp'][1], amp1, 6)
        self.assertAlmostEqual(ans['avg'][1], avg1, 6)
        self.assertAlmostEqual(ans['sig'][1], sig1, 6)
        np.testing.assert_allclose(y, ugradio.gauss.gaussval(x, **ans), 6)

if __name__ == '__main__':
    unittest.main()
