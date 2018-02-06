import numpy as np
from scipy.optimize import curve_fit

def _pack_prms(amp, avg, sig):
    '''Internal. Convert user arguments to parameter list.'''
    prms = np.array([amp, avg, sig])
    prms.shape = (3,-1)
    return prms.T.flatten()

def _unpack_prms(prms):
    '''Internal. Convert parameter list to user arguments.'''
    amp = np.array(prms[0::3]); amp.shape = (-1,1)
    avg = np.array(prms[1::3]); avg.shape = (-1,1)
    sig = np.array(prms[2::3]); sig.shape = (-1,1)
    return amp, avg, sig

def _gauss(x, *prms):
    '''Internal. Gaussian model that is fit to the data.'''
    amp, avg, sig = _unpack_prms(prms)
    ans = amp * np.exp(-(x-avg)**2/(2.*sig**2))
    return np.sum(amp * np.exp(-(x-avg)**2/(2.*sig**2)), axis=0)

def gaussfit(x, y, amp=1., avg=0., sig=1., return_cov=False):
    '''Fit amp, avg, and sig for a Gaussian [y = amp * e^(-(x-avg)^2/(2*sig^2)].
    amp/avg/sig can be lists/arrays to simultaneously fit multiple Gaussians.
    Parameters
    ----------
    x : x coordinate at which Gaussian is evaluated
    y : measured y coordinate to which Gaussian is compared
    amp : first guess at amp, the amplitude(s) of the Gaussian(s), default=1.
    avg : first guess at avg, the average(s) of the Gaussian(s), default=0.
    sig : first guess at sig, the width(s) of the Gaussian(s), default=1.
    return_cov : return the [amp, avg, sig] covariance matrix of the solution

    Returns
    -------
    ans : dictionary with amp/avg/sig keys and fit solutions as values.
    prm_covariance : the [amp, avg, sig] covariance matrix'''
    prms0 = _pack_prms(amp, avg, sig)
    prms, prm_covariance = curve_fit(_gauss, x, y, p0=prms0)
    amp, avg, sig = _unpack_prms(prms)
    ans = {'amp':amp.flatten(), 'avg':avg.flatten(), 'sig':sig.flatten()}
    if return_cov:
        return ans, prm_covariance
    else:
        return ans

def gaussval(x, amp, avg, sig):
    '''Evaluate a Gaussian given amp, avg, and sig [y = amp * e^(-(x-avg)^2/(2*sig^2)].
    amp/avg/sig can be lists/arrays to simultaneously fit multiple Gaussians.
    Parameters
    ----------
    x : x coordinate at which Gaussian is evaluated
    amp : amplitude(s) of Gaussian(s)
    avg : center point(s) of Gaussian(s)
    sig : width(s) of Gaussian(s)

    Returns
    -------
    y : the evaluated Gaussian [y = amp * e^(-(x-avg)^2/(2*sig^2)]'''
    prms = _pack_prms(amp, avg, sig)
    return _gauss(x, *prms)
    
