#!/usr/bin/env python2

########################################################################
## This module is a very simple receiver script for Leuschner.
## Copyright (C) 2014 Rachel Domagalski: domagalski@berkeley.edu
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## ## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.
########################################################################

import os
import sys
import pyfits
import leuschner

def unpack_attr(obsfile):
    """
    Unpack observation attributes from a FITS file.

    Input:

    - ``obsfile``: Observation attributes file.

    Return:

    - ``nspec``: Number of spectra to collect.
    - ``cooords``: Coordinates of the observation target.
    - ``system``: Coordinate system of the coordinates.
    """
    obs_hdu = pyfits.open(obsfile)
    header = obs_hdu[0].header
    nspec = header['NSPEC']
    system = header['COORDSYS']

    # Extract coordinates
    if system == 'ga':
        lon = header['L']
        lat = header['B']
        coords = (lat, lon)
    elif system == 'eq':
        ra  = header['RA']
        dec = header['DEC']
        coords = (ra, dec)
    else:
        print 'ERROR: Invalid coordinate system:', system
        sys.exit(1)
    obs_hdu.close()

    return (nspec, coords, system)

if __name__ == '__main__':
    usage = 'Usage: python2 leuschner_rx.py obs_attr.fits outfile.fits'
    assert len(sys.argv) == 3, usage
    obsfile = sys.argv[1]
    outfile = sys.argv[2]
    nspec, coords, system = unpack_attr(obsfile)

    spec = leuschner.Spectrometer('10.0.1.2')
    spec.check_connected()
    spec.init_spec()
    spec.read_spec(outfile, nspec, coords, system)
    sys.exit(0)
