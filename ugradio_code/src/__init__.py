import warnings

try:
    # These modules will not import if astropy is not installed
    from . import timing
    from . import doppler
    from . import coord
except ImportError as error:
    #warnings.warn(error)
    warnings.warn("(Modules timing, doppler, coord unavailable if astropy is not installed)")

try:
    # These modules will not import if scipy is not installed
    from . import gauss
except ImportError as error:
    #warnings.warn(error)
    warnings.warn("(Module gauss unavailable if scipy is not installed)")

try:
    # These modules will not import if rtlsdr is not installed
    from . import sdr
except (ImportError) as error:
    #warnings.warn(error)
    warnings.warn("(Module sdr unavailable if pyrtlsdr is not installed)")

from . import pico
from . import dft
from . import agilent
from . import hp_multi
from . import interf
#from . import interf_delay
from . import leusch
from . import nch
from . import leo
