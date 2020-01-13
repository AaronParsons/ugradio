try:
    import timing # ImportError if astropy not installed
    import doppler # ImportError if astropy,barycorrpy not installed
    import coord # ImportError if astropy,barycorrpy not installed
except(ImportError): pass

try:
    import gauss # ImportError if scipy not installed
except(ImportError): pass

from . import pico
from . import dft
from . import agilent
from . import hp_multi
from . import interf
from . import leusch
from . import nch
from . import leo
