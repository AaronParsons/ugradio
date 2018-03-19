#!/usr/bin/env python2

########################################################################
## This module plots averages of spectra from the spectrometer.
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

import argparse
import numpy as np
import pyfits as fits
import matplotlib.pyplot as plt

def get_auto(ftable, auto):
    """
    This function gets an auto-correlation from a FITS table.

    Input:

    - ``ftable``: FITS table containing spectra from one accumulation.
    - ``auto``: The autocorrelation to extract (0, 1).

    Return:

    - ``autocorr``: Autocorrelation of one polarization.
    """
    assert auto in [0, 1], 'ERROR: Invalid autocorrelation.'
    ftable.columns[0].array[0]
    autocorr = ftable.columns[auto].array
    return autocorr

def get_cross(ftable):
    """
    This function gets the cross-correlation from a FITS table.

    Input:

    - ``ftable``: FITS table containing spectra from one accumulation.

    Return:

    - ``crosscorr``: Cross correlation of the polarizations.
    """
    ftable.columns[0].array[0]
    real = ftable.columns[2].array
    imag = ftable.columns[3].array
    crosscorr = real + 1j * imag
    return crosscorr

def get_freqs(header):
    """
    This functions generates frequency information of the spectra from
    the primary header of a spectra FITS files.

    Input:

    - ``header``: FITS header with info of the spectrometer.

    Return:

    - ``freqs``: Frequency channels of the spectrometer.
    """
    nchan = header['NCHAN']
    res   = header['RES']
    freqs = np.arange(nchan) * res / 1e6 # Convert to MHz
    return freqs

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', nargs=1, help='Input FITS file.')
    parser.add_argument('-x', '--xcorr',
                        metavar='corr',
                        choices=['auto0', 'auto1', 'cross'],
                        help='Cross-correlation to plot.')

    args = parser.parse_args()

    hdulist = fits.open(args.infile[0])
    prihdr  = hdulist[0].header
    frequency = get_freqs(prihdr)
    nspec = prihdr['NSPEC']
    nchan = prihdr['NCHAN']

    # Prepare empty arrays for storing data.
    if args.xcorr is None:
        spectra = [np.zeros(nchan) for i in range(2)]
        spectra.append(np.zeros(nchan, dtype=complex))
    elif 'auto' in args.xcorr:
        spectra = np.zeros(nchan)
    else:
        spectra = np.zeros(nchan, dtype=complex)

    # Extract spectra
    for i in range(nspec):
        if args.xcorr is None:
            for j in range(2):
                spectra[j] += get_auto(hdulist[i+1], j)
            spectra[2] += get_cross(hdulist[i+1])
        elif 'auto' in args.xcorr:
            spectra += get_auto(hdulist[i+1], int(args.xcorr[-1]))
        else:
            spectra += get_cross(hdulist[i+1])

    # Get the absolute value of the cross-correlation.
    if args.xcorr is None:
        spectra[2] = np.abs(spectra[2])
    elif 'cross' in args.xcorr:
        spectra = np.abs(spectra)

    # Plot spectra
    if args.xcorr is None:
        for i, xcorr in enumerate(['auto0', 'auto1', 'cross']):
            plt.figure()
            plt.plot(frequency, spectra[i])
            plt.xlabel('Frequency (Mhz)')
            plt.ylabel('Spectra (ADU)')
            plt.title(xcorr)
            plt.tight_layout()
    else:
        plt.plot(frequency, spectra)
        plt.xlabel('Frequency (Mhz)')
        plt.ylabel('Spectra (ADU)')
        plt.title(args.xcorr)
        plt.tight_layout()

    plt.show()
