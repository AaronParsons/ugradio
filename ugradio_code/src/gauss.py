import numpy as np
from scipy.optimize import curve_fit

def _gauss(x, *prms):
    '''Internal Gaussian model that is fit to the data.'''
    amp, avg, sig = prms
    return amp * np.exp(-(x-avg)**2/(2.*sig**2))

def gaussfit(x, y, amp=1., avg=0., sig=1., return_cov=False):
    '''Fit amp, avg, and sig for a Gaussian [y = amp * e^(-(x-avg)^2/(2*sig^2)].
    Parameters
    ----------
    x : x coordinate at which Gaussian is evaluated
    y : measured y coordinate to which Gaussian is compared
    amp : first guess at amp, the amplitude of the Gaussian, default=1.
    avg : first guess at avg, the average of the Gaussian, default=0.
    sig : first guess at sig, the width of the Gaussian, default=1.
    return_cov : return the [amp, avg, sig] covariance matrix of the solution

    Returns
    -------
    ans : dictionary with amp/avg/sig keys and fit solutions as values.
    prm_covariance : the [amp, avg, sig] covariance matrix'''
    prms0 = (amp, avg, sig)
    (amp,avg,sig), prm_covariance = curve_fit(gauss, x, y, p0=prms0)
    ans = {'amp':amp, 'avg':avg, 'sig':sig}
    if return_cov:
        return ans, prm_covariance
    else:
        return ans

def gaussval(x, amp, avg, sig):
    '''Evaluate a Gaussian given amp, avg, and sig [y = amp * e^(-(x-avg)^2/(2*sig^2)].
    Parameters
    ----------
    x : x coordinate at which Gaussian is evaluated
    amp : amplitude of Gaussian
    avg : center point of Gaussian
    sig : width of Gaussian

    Returns
    -------
    y : the evaluated Gaussian [y = amp * e^(-(x-avg)^2/(2*sig^2)]'''
    return _gauss(x, (amp,avg,sig))
    
