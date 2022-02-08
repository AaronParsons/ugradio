try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup
import glob
import os
import sys

def package_files(package_dir,subdirectory):
    # walk the input package_dir/subdirectory
    # return a package_data list
    paths = []
    directory = os.path.join(package_dir, subdirectory)
    for (path, directories, filenames) in os.walk(directory):
        for filename in filenames:
            path = path.replace(package_dir + '/', '')
            paths.append(os.path.join(path, filename))
    return paths
#data_files = package_files('src','data')

setup_args = {
    'name': 'ugradio',
    'author': 'UC Berkeley RadioLab',
    'url': 'https://github.com/AaronParsons/ugradio',
    'license': 'BSD',
    'description': 'collection of software for the UC Berkeley Undergraduate Radio Lab.',
    'package_dir': {'ugradio': 'src'},
    'packages': ['ugradio'],
    'include_package_data': True,
    'scripts': glob.glob('scripts/*'),
    'install_requires': [
        'astropy>2',
        'numpy',
        #'barycorrpy',
        'serial',
        'scipy'],
    'extras_require': {'sdr': ['pyrtlsdr']},
    'version': '0.0.1',
    #'package_data': {'ugradio': data_files},
    'zip_safe': False,
}


if __name__ == '__main__':
    setup(**setup_args)
