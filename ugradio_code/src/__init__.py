try:
    from . import timing # ImportError if astropy not installed
    from . import doppler # ImportError if astropy,barycorrpy not installed
    from . import coord # ImportError if astropy,barycorrpy not installed
except ImportError as error:
    print(error) # Does not pass silently
    pass
try:
    from . import gauss # ImportError if scipy not installed
except ImportError as error:
    print(error) # Does not pass silently
    pass

from . import pico
from . import dft
from . import agilent
from . import hp_multi
from . import interf
from . import leusch
from . import nch
from . import leo
