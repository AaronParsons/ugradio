from setuptools import setup
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
    #'scripts': ['scripts/firstcal_run.py', 'scripts/omni_apply.py',
    #            'scripts/omni_run.py', 'scripts/extract_hh.py'],
    'version': '0.0.1',
    #'package_data': {'ugradio': data_files},
    'zip_safe': False,
}


if __name__ == '__main__':
    apply(setup, (), setup_args)

