try:
    import timing # ImportError if astropy not installed
    import doppler # ImportError if astropy,barycorrpy not installed
    import coord # ImportError if astropy,barycorrpy not installed
except(ImportError): pass

try:
    import gauss # ImportError if scipy not installed
except(ImportError): pass

import pico, dft, agilent, hp_multi, interf, leusch
