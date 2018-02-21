"""Module for controlling the X-band antennas in the interferometer."""

# XXX tracking mode?

import socket

MAX_SLEW_TIME = 60 # seconds

ALT_MIN, ALT_MAX = 5., 175. # Pointing bounds, degrees
AZ_MIN, AZ_MAX  = 90., 300. # Pointing bounds, degrees

ALT_STOW = 90. # Position for stowing antenna
AZ_STOW = 180. # Position for stowing antenna

ALT_MAINT = 20. # Position for antenna maintenance
AZ_MAINT = 180. # Position for antenna maintenance

class Telescope:
    '''Interface for controlling a single antenna.  Use Interferometer to 
    control the pair with default settings.'''
    def __init__(self, host, port, delta_alt, delta_az):
        self._delta_alt = delta_alt
        self._delta_az = delta_az
        self.hostport = (host,port)
    def _check_pointing(self, alt, az):
        '''Ensure pointing is within bounds.  Raises AssertionError if not.'''
        assert(ALT_MIN < alt < ALT_MAX) # range is nominally 5 to 175 degrees
        assert(AZ_MIN < az < AZ_MAX)    # range is nominally 90 to 300 degrees
    def _command(self, s, bufsize=1024, timeout=10, verbose=False):
        '''Communicate with host server and return response as string.'''
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout) # seconds
        s.connect(self.hostport)
        if verbose: print [s]
        s.sendall(s)
        response = []
        while True: # XXX don't like while-True
            r = s.recv(bufsize)
            if not r: break
            response.append(r)
        if verbose: print reponse
        return ''.join(response)
    def point(self, alt, az, wait=True, verbose=False):
        '''Point to the specified alt/az.

        Parameters
        ----------
        alt     : float degrees, altitude angle to point to
        az      : float degrees, azimuthal angle to point to
        wait    : bool, pause until antenna has completed pointing, default=True
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self._check_pointing(alt, az) # AssertionError if out of bounds
        # Request encoded alt/az with calibrated offset 
        resp1 = self._command('moveAz\n%s\r' % (az - self._delta_az), verbose=verbose)
        resp2 = self._command('moveEl\n%s\r' % (alt - self._delta_alt), verbose=verbose)
        assert((resp1 == 'ok') and (resp2 == 'ok')) # fails if server is down or rejects command
        if verbose: print 'Pointing Initiated'
        if wait: self.wait(verbose=verbose)
    def wait(self, verbose=False):
        '''Wait until telescope slewing is complete

        Parameters
        ----------
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        resp1 = self._command('waitAz',  timeout=MAX_SLEW_TIME, verbose=verbose)
        resp2 = self._command('waitAlt', timeout=MAX_SLEW_TIME, verbose=verbose)
        assert((resp1 == '0') and (resp2 == '0')) # fails if server is down or rejects command
        if verbose: print 'Pointing Complete'
    def get_pointing(self, verbose=False):
        '''Return the current telescope pointing

        Parameters
        ----------
        verbose : bool, be verbose, default=False

        Returns
        -------
        alt     : float degrees, altitude angle 
        az      : float degrees, azimuthal angle'''
        az = float(self._command('getAz', verbose=verbose))
        alt = float(self._command('getEl', verbose=verbose))
        # Return true alt/az corresponding to encoded position
        return alt + self._delta_alt, az + self._delta_az
    def stow(self, wait=True, verbose=False):
        '''Point to the stow position

        Parameters
        ----------
        wait    : bool, pause until antenna has completed pointing, default=True
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self.point(ALT_STOW, AZ_STOW, wait=wait, verbose=verbose)
    def maintenance(self, wait=True, verbose=False):
        '''Point to the maintenance position

        Parameters
        ----------
        wait    : bool, pause until antenna has completed pointing, default=True
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self.point(ALT_MAINT, AZ_MAINT, wait=wait, verbose=verbose)

HOST_ANT_W = '10.32.92.117' # RPI host for western interferometer antenna
HOST_ANT_E = '10.32.92.118' # RPI host for eastern interferometer antenna
PORT = 1420

# Offsets to subtract from crd to get encoder value to write
DELTA_ALT_ANT_W = -0.5  # (true - encoder) offset
DELTA_AZ_ANT_W  = -9.2  # (true - encoder) offset
DELTA_ALT_ANT_E =  0.   # (true - encoder) offset
DELTA_AZ_ANT_E  = -8.5  # (true - encoder) offset

    
class Interferometer:
    '''Documentation'''
    def __init__(self, host_ant_w=HOST_ANT_W, host_ant_e=HOST_ANT_E, port=PORT, 
            delta_alt_ant_w=DELTA_ALT_ANT_W, delta_az_ant_w=DELTA_AZ_ANT_W,
            delta_alt_ant_e=DELTA_ALT_ANT_E, delta_az_ant_e=DELTA_AZ_ANT_E):
        self.ant_w = Telescope(host_ant_w, port, delta_alt=delta_alt_ant_w, delta_az=delta_az_ant_w)
        self.ant_e = Telescope(host_ant_e, port, delta_alt=delta_alt_ant_e, delta_az=delta_az_ant_e)
    def point(self, alt, az, wait=True, verbose=False):
        '''Point both antennas to the specified alt/az.

        Parameters
        ----------
        alt     : float degrees, altitude angle to point to
        az      : float degrees, azimuthal angle to point to
        wait    : bool, pause until both antennas have completed pointing, default=True
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self.ant_w.point(alt, az, wait=False, verbose=verbose)
        self.ant_e.point(alt, az, wait=False, verbose=verbose)
        if wait: self.wait(verbose=verbose)
    def wait(self, verbose=False):
        '''Wait until both telescopes' slewing is complete

        Parameters
        ----------
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self.ant_w.wait(verbose=verbose)
        self.ant_e.wait(verbose=verbose)
    def get_pointing(self, verbose=False):
        '''Return the current telescope pointing

        Parameters
        ----------
        verbose : bool, be verbose, default=False

        Returns
        -------
        pointing: dict with {'ant_w':(alt,az), 'ant_e':(alt,az)} for the two antennas'''
        pnt_w = self.ant_w.get_pointing(verbose=verbose)
        pnt_e = self.ant_e.get_pointing(verbose=verbose)
        return {'ant_w': pnt_w, 'ant_e': pnt_e}
    def stow(self, wait=True, verbose=False):
        '''Point both antennas to the stow position

        Parameters
        ----------
        wait    : bool, pause until antenna has completed pointing, default=True
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self.ant_w.stow(wait=wait, verbose=verbose)
        self.ant_e.stow(wait=wait, verbose=verbose)
    def maintenance(self, wait=True, verbose=False):
        '''Point both antennas to the maintenance position

        Parameters
        ----------
        wait    : bool, pause until antenna has completed pointing, default=True
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self.ant_w.maintenance(wait=wait, verbose=verbose)
        self.ant_e.maintenance(wait=wait, verbose=verbose)

        
