#!/usr/bin/env python2

########################################################################
## This module provides tools for interacting with the spectrometer at
## the UC Berkeley Leuschner Radio Observatory.
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

import os as _os
import time as _time
import numpy as _np
import ephem as _ephem
import pyfits as _fits
from corr import katcp_wrapper as _katcp

# Disable warnings.
import warnings as _warn
_warn.simplefilter('ignore', UserWarning)

class Spectrometer(_katcp.FpgaClient):
    """
    KATCP interface to the ROACH spectrometer.
    """
    def __init__(self, *args, **kwargs):
        """
        Create the interface to the ROACH.
        """
        # Run the katcp initialization.
        _katcp.FpgaClient.__init__(self, *args, **kwargs)

        # Set some variables to default values.
        self.mode = 'spec'
        self.count = 0
        self.scale = 0
        self.boffile = 'spec_ds8_8192.bof'
        self.nchan = 1 << 13    # 8192 channels.
        self.downsample = 1 << 3 # ADC downsample period
        self.fft_shift = (1 << 14) - 1  # Shift every stage.
        self.acc_len = 1 << 27 # This is 1024 integrations per dump time.

    def check_connected(self, timeout=10):
        """
        This function checks if the ROACH is connected, and raises an
        IOError if the client can't reach the ROACH.

        Input:

        - ``timeout``: The amount of seconds to wait before IOError.
        """
        if not self.wait_connected(timeout):
            raise IOError('Cannot connect to the ROACH')
        print 'Connection to ROACH established.'

    def check_running(self):
        """
        This function checks to see if the bof process for the
        spectrometer has been initialized on the ROACH. I've put a
        constant in the design that translates to the mode of the
        spectrometer, and if it can be read, this indicates that the
        bof process has been started.
        """
        try:
            return mode_int2str(self.read_int('mode')) == self.mode
        except RuntimeError:
            return False

    def fits_create(self, nspec, coords, system='ga'):
        """
        Open a fits file for reading and create a primary HDU with the
        observation attributes.

        Inputs:

        - ``nspec``: Number of spectra to collect.
        - ``coords``: Coordinates of the target of observation. \
                Format: (lon/ra, lat/dec)
        - ``system``: Coordinate system of ``coords`` (eq, ga).

        Return:

        - This function returns a primary HDU with a header containing \
                the attributes of the observation.
        """
        # Check that the user isn't a dingus
        if system != 'ga' and system != 'eq':
            raise ValueError('Invalid coordinate system: ' + system)

        # Create a header and write spectral info to it.
        obs_attr = _fits.Header()
        obs_attr['NSPEC'] = (nspec, 'Number of spectra recorded')
        obs_attr['BOFFILE'] = (self.boffile, 'FPGA binary code')
        obs_attr['MODE'] = (self.mode, 'Spectrometer mode')
        obs_attr['FPGA'] = (self.clock_rate, 'FPGA clock speed (Hz)')
        obs_attr['IADC'] = (self.iadc_rate, 'iADC clock speed (Hz)')
        obs_attr['DOWNSAMP'] = (self.downsample, 'ADC downsampling period.')
        obs_attr['SAMPRATE'] = (self.samp_rate, 'Downsampled clock speed (Hz)')
        obs_attr['BW'] = (self.bandwidth, 'Bandwidth of spectra (Hz)')
        obs_attr['NCHAN'] = (self.nchan, 'Number of frequency channels')
        obs_attr['RES'] = (self.resolution, 'Frequency resolution (Hz)')
        obs_attr['FFTSHIFT'] = (self.fft_shift, 'FFT Shifting instructions')
        obs_attr['ACCLEN'] = (self.acc_len, 'Number of clock cycles')
        obs_attr['INTTIME'] = (self.int_time, 'Integration time of spectra')
        obs_attr['SCALE'] = (self.scale, 'Average instead of sum on ROACH')

        # Set the coordinates. Both RA/Dec and galactic will be stored.
        obs_start_seconds = _time.time()
        obs_start = get_epoch(obs_start_seconds)
        obs_start_jd = julian_date(obs_start_seconds)
        if system == 'ga':
            lon, lat   = coords_deg2rad(coords)
            galactic   = _ephem.Galactic(lon, lat, epoch=obs_start)
            equatorial = _ephem.Equatorial(galactic)
        else:
            ra, dec    = coords_deg2rad(coords)
            equatorial = _ephem.Equatorial(ra, dec, epoch=obs_start)
            galactic   = _ephem.Galactic(equatorial)

        # Pack the coordinates into the FITS header.
        obs_attr['L']    = (ephem2deg(galactic.lon), 'Galactic longitude')
        obs_attr['B']    = (ephem2deg(galactic.lat), 'Galactic latitude')
        obs_attr['RA']   = (ephem2deg(equatorial.ra), 'Right Ascension')
        obs_attr['DEC']  = (ephem2deg(equatorial.dec), 'Declination')
        obs_attr['JD']   = (obs_start_jd, 'Julian date of start time')
        obs_attr['UTC']  = (obs_start, 'Starting date of accumulation')
        obs_attr['TIME'] = (obs_start_seconds, 'Seconds since epoch')
        return _fits.PrimaryHDU(header=obs_attr)

    def init_spec(self, scale=False, force_restart=False):
        """
        This function starts the bof process on the ROACH. First, it
        checks to see if the spectrometer is already running, then
        initializes it if it isn't.

        Input:

        - ``scale``: Whether or not to scale down each integration by \
                the total number of spectra per integration time.
        - ``force_restart``: Restart the bof process even if it is \
                already running.
        """
        # Detect a running spectrometer
        prog_bof = True
        if force_restart:
            print 'WARNING: Forcing a possible restart of the spectrometer.'
            self.progdev('')
        else:
            prog_bof = not self.check_running()

        if prog_bof:
            print 'Starting the spectrometer...'
            self.scale = int(scale)
            self.progdev(self.boffile)
            self.write_int('fft_shift', self.fft_shift)
            self.write_int('scale', self.scale)

            # Sync pulse lets the spectrometer know when to start.
            for i in (0, 1, 0):
                self.write_int('sync_pulse', i)

            # This starts the accumulator
            self.write_int('enable', 1)
            while self.read_int('acc_num') < 2: # throw away 1st spectrum
                _time.sleep(0.01)

        self.count = self.read_int('acc_num')
        print 'Spectrometer is ready.'

    def poll(self):
        """
        This function waits until the integration count has been
        incrimented and returns the date of the integration in seconds
        since Jan 1, 1970 UTC.

        Return:

        - ``obs_date``: Unix time of the integration.
        """
        self.count = self.read_int('acc_num')
        while self.read_int('acc_num') == self.count:
            _time.sleep(0.001)
        obs_date = _time.time() - 0.5*self.int_time
        self.count = self.read_int('acc_num')
        return obs_date

    def read_bram(self, bram):
        """
        This function reads out data from a ROACH BRAM. The data is
        stored in the ROACH as 32-bit fixed point numbers with the
        binary point at the 30th bit.

        Input:

        - ``bram``: The name of the BRAM to read data from.

        Output:

        - ``bram_fp``: Array of floats of the ROACH BRAM values.
        """
        bram_size = 4 * self.nchan
        bram_ints = _np.fromstring(self.read(bram, bram_size), '>i4')

        # Remove DC offset.
        bram_ints[0] = 0
        bram_ints[1] = 0
        bram_ints[-1] = 0
        bram_ints[-2] = 0

        # Create floats with the fixed-point value of each channel.
        bram_fp = bram_ints / float(1<<30)
        return bram_fp

    def read_spec(self, filename, nspec, coords, system='ga', bandwidth=12e6):
        """
        This function recieves data from the Leuschner spectrometer and
        saves it to a FITS file. The first HDU of the FITS file contains
        information about the observation, such as the coordinates, the
        number of integrations accumulated, and attributes about the
        spectrometer used to collect the data. Each set of spectra is
        stored in its own FITS table in the FITS file. The columns in
        each FITS table are ``auto0_real``, ``auto1_real``,
        ``cross_real``, and ``cross_imag``, and all of the columns
        contain  double-precision floating-point numbers.

        Inputs:

        - ``filename``: Name of the output FITS file.
        - ``nspec``: Number of spectra to collect.
        - ``coords``: Coordinates of the target of observation. \
                Format: (lon/ra, lat/dec). Units: degrees.
        - ``system``: Coordinate system of ``coords`` (eq, ga).
        """
        # Check that the user isn't a dingus
        if system != 'ga' and system != 'eq':
            raise ValueError('Invalid coordinate system: ' + system)

        # Make sure the spectrometer is actually running.
        if not self.check_running():
            self.init_spec()
        self.spec_props(bandwidth)

        # BRAM device names.
        bram_names   = ['auto0_real', 'auto1_real', 'cross_real', 'cross_imag']
        bram_devices = map(lambda s: 'spec_' + s, bram_names)

        # Create a primary FITS HDU for a table file.
        hdulist = [self.fits_create(nspec, coords, system)]

        # Read some number of spectra to a FITS file
        print 'Reading', nspec, 'spectra from the ROACH.'
        ninteg = 0
        while ninteg < nspec:
            # Update the counter and read the spectra from the ROACH.
            spec_date = self.poll()
            try:
                spectra = map(self.read_bram, bram_devices)
            except RuntimeError:
                print 'WARNING: Cannot reach the ROACH. Skipping integration.'
                self.reconnect()
                continue

            # Create FITS columns with the data.
            fcols = map(mk_flt_col, bram_names, spectra)
            hdulist.append(_fits.BinTableHDU.from_columns(fcols))

            # Add the accumulation date in several formats to the header.
            spec_jd  = julian_date(spec_date)
            spec_utc = utc_string(spec_date)
            hdulist[-1].header['JD'] = (spec_jd, 'Julian date of observation.')
            hdulist[-1].header['UTC'] = (spec_utc, 'UTC time of observation.')
            hdulist[-1].header['TIME'] = (spec_date, 'Seconds since epoch.')

            ninteg += 1
            integ_time = ninteg * self.int_time
            print 'Integration count:', ninteg, '(' + str(integ_time), 's)'

        # Save the output file
        print 'Saving spectra to output file:', filename
        _fits.HDUList(hdulist).writeto(filename, clobber=True)

    def reconnect(self):
        """
        This function can be run if the spectrometer can't be reached
        in the middle of data collection. This should only be run if
        the bof process for the spectrometer has been already started.
        """
        while True:
            try:
                self.read_int('mode')
                break
            except:
                _time.sleep(0.1)

    def set_fft_shift(self, fft_shift):
        """
        This function allows the user to change the FFT shifting
        instructions on the ROACH.

        Input:

        - ``fft_shift``: FFT shifting instructions for the ROACH.
        """
        self.fft_shift = int(fft_shift)
        self.write_int('fft_shift', self.fft_shift)
        for i in range(2):
            self.poll()

    def set_scale(self, scale):
        """
        This function allows the user to change whether or not to
        scale spectra by the number of spectra integrated per
        accumulation.

        Input:

        - ``scale``: Whether or not to downscale the spectra.
        """
        self.scale = int(scale)
        self.write_int('scale', self.scale)
        for i in range(2):
            self.poll()

    def spec_props(self, bandwidth):
        """
        This function takes in a sample rate and stores parameters
        computed from it (bandwidth, resolution, etc...)

        Input:

        - ``clock_rate``: The FPGA clock speed.
        """
        self.bandwidth = bandwidth
        self.samp_rate = self.bandwidth * 2
        self.clock_rate = self.downsample * self.samp_rate
        self.iadc_rate = 4 * self.clock_rate # Speed of iADC clock
        self.int_time = self.acc_len / self.clock_rate
        self.resolution = self.bandwidth / self.nchan


def coords_deg2rad(coords):
    """
    This function unpacks coordinates from a tuple and converts them
    from degrees to radians.

    Input:

    - ``coords``: Coordinate pair in degrees.
    """
    c1, c2 = coords
    c1 = _np.radians(c1)
    c2 = _np.radians(c2)
    return (c1, c2)

def ephem2deg(angle):
    """
    This function converts an ephem angle into degrees.

    Input:

    - ``angle``: Ephem angle object.
    """
    return _np.degrees(float(angle))

def ephem_time(date=None):
    """
    This function creates and ephem date object out of a unix time.

    Input:

    - ``date``: Date in seconds since the Epoch (Jan 1, 1970 UTC).
    """
    return _ephem.Date(get_epoch(date))

def get_epoch(date=None):
    """
    This function converts a unix-time into a string in a format that
    can be used as an ephem epoch.

    Input:

    - ``date``: Date in seconds since the Epoch (Jan 1, 1970 UTC).
    """
    return _time.strftime('%Y/%m/%d %H:%M:%S', _time.gmtime(date))

def julian_date(date=None):
    """
    This function converts seconds since the epoch to a julian date.

    Input:

    - ``date``: Date in seconds since the Epoch (Jan 1, 1970 UTC).
    """
    return _ephem.julian_date(ephem_time(date))

def mk_flt_col(name, data):
    """
    Create a FITS column of double-precision floating data.

    Input:

    - ``name``: Name of the FITS column.
    - ``data``: Array of data for the FITS column.
    """
    return _fits.Column(name, 'D', array=data)

def mode_int2str(num):
    """
    This converts a mode number into 4-letter human readable string.

    Input:

    - ``num``: Number less than 2^32 encoding the spectrometer mode.

    Return:

    - ``mode``: String containing the mode information.
    """
    return ''.join(map(lambda n: chr(num/256**n % 256), range(4)))

def mode_str2int(mode):
    """
    This converts a 4-digit mode string into an integer encoding it.

    Input:

    - ``mode``: String containing the mode information.

    Return:

    - ``num``: Number less than 2^32 encoding the spectrometer mode.
    """
    assert len(mode) == 4, 'ERROR: Mode must be 4 characters.'
    return sum(map(lambda c, n: c << 8*n, map(ord, mode), range(4)))

def utc_string(date=None):
    """
    Convert unix time to UTC string.

    Input:

    - ``date``: Date in seconds since the Epoch (Jan 1, 1970 UTC).
    """
    return _time.asctime(_time.gmtime(date))
