"""
Leuscher radio spectrometer control software.
"""
from distutils.core import setup
import glob

if __name__ == '__main__':
    setup(name = 'leuschner',
        description = __doc__,
        long_description = __doc__,
        license = 'GPL',
        author = 'Rachel Domagalski',
        author_email = 'domagalski@berkeley.edu',
        url = 'https://github.com/domagalski/leuschner-spectrometer',
        package_dir = {'':'src'},
        py_modules = ['leuschner'],
        scripts = glob.glob('scripts/*.py'),
    )
