import numpy as np
from scipy.special import j1

WAVELEN = 2.5  # cm

def get_w(baseline, src, wavelen):
    return np.dot(baseline, src) / wavelen

def visibility(baseline, src, wavelen=WAVELEN):
    """Return the visibility corresponding to the provided baseline, src, and wavelen."""
    return np.exp(-2j * np.pi * get_w(baseline, src, wavelen))

def bessel_it_up(baseline, src, ang_r, wavelen=WAVELEN):
    """Return the bessel function corresponding to the provided baseline, src, and wavelen."""
    w = get_w(baseline, src, wavelen)
    umag = np.sqrt(np.dot(baseline, baseline) / wavelen**2 - w**2)
    x = 2 * np.pi * ang_r * umag
    #print(umag, x)
    return np.where(x == 0, 1, j1(x) / x)


def rotate_matrix_eq2now(lst):
    """Rotate from equatorial coordinate system to local sidereal time."""
    zeros = np.zeros_like(lst)
    oones = np.ones_like(lst)
    return np.array([[ np.cos(lst), np.sin(lst), zeros],
                     [-np.sin(lst), np.cos(lst), zeros],
                     [       zeros,       zeros, oones]])

def rotate_matrix_eq2top(lat):
    """Rotate from topocentric coordinate system to equatorial."""
    zeros = np.zeros_like(lat)
    oones = np.ones_like(lat)
    return np.array([[       zeros,           oones,       zeros],
                     [-np.sin(lat),           zeros, np.cos(lat)],
                     [ np.cos(lat),           zeros, np.sin(lat)]])



if __name__ == '__main__':
    np.testing.assert_allclose(visibility(np.array([1, 0, 0]), np.array([0, 1, 0]), 2), 1+0j)
    np.testing.assert_allclose(rotate_matrix_eq2now(0), np.identity(3))
    np.testing.assert_allclose(rotate_matrix_eq2now(np.pi/2), np.array([[0, 1, 0],[-1, 0, 0], [0, 0, 1]]), atol=1e-7)
