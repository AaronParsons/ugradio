'''This script provides a command-line interface to the 
Leuschner spectrometer via the leuschner package. This
package is only python2 compatible, so this script
provides an interface by which python3 can interact
with the spectrometer.

Usage:
$ python2 leusch_helper.py <mode> <ip_addr> <args>

mode:
    cc = check connected
    rs = read spectra
        <args> = filename nspec coords system
ip_addr:
    ip address of the Leuschner spectrometer
'''

from __future__ import print_function
import sys

if sys.version_info > (3, 0):
    # this script must run as python2
    import os, subprocess
    absref = os.path.realpath(__file__)
    cmd = ['python2', absref] + sys.argv[1:]
    subprocess.run(cmd)
    sys.exit(0)

import leuschner

function = sys.argv[1]
ip = sys.argv[2]
sp = leuschner.Spectrometer(ip)

if function == "cc":
    sp.check_connected()

if function == "rs":
    filename = sys.argv[3]
    nspec = int(sys.argv[4])
    coords = eval(sys.argv[5])
    system = sys.argv[6]
    sp.read_spec(filename, nspec, coords, system)

if function == "it":
    print(sp.int_time)

sys.exit(0)
