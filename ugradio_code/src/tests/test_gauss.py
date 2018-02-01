import unittest
import ugradio.gauss
import numpy as np

np.random.seed(0)

class TestGauss(unittest.TestCase):
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

if __name__ == '__main__':
    unittest.main()
