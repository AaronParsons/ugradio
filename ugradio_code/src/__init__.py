try:
    from . import timing # ImportError if astropy not installed
    from . import doppler # ImportError if astropy not installed
    from . import coord # ImportError if astropy not installed
except ImportError as error:
    print(error) # Does not pass silently
    pass
try:
    from . import gauss # ImportError if scipy not installed
except ImportError as error:
    print(error) # Does not pass silently
    pass
try:
    from . import sdr # ImportError if rtlsdr not installed
except ImportError as error:
    print(error) # Does not pass silently
    pass

from . import pico
from . import dft
from . import agilent
from . import hp_multi
from . import interf
from . import interf_delay
from . import leusch
from . import nch
from . import leo
