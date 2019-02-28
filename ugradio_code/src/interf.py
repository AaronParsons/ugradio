"""Module for controlling the X-band antennas in the interferometer."""

# XXX tracking mode?

from __future__ import print_function
import socket, serial, time, thread

MAX_SLEW_TIME = 60 # seconds

ALT_MIN, ALT_MAX = 5., 175. # Pointing bounds, degrees
AZ_MIN, AZ_MAX  = 90., 300. # Pointing bounds, degrees

ALT_STOW = 90. # Position for stowing antenna
AZ_STOW = 180. # Position for stowing antenna

ALT_MAINT = 20. # Position for antenna maintenance
AZ_MAINT = 180. # Position for antenna maintenance

class TelescopeClient:
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
    def _command(self, cmd, bufsize=1024, timeout=10, verbose=False):
        '''Communicate with host server and return response as string.'''
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout) # seconds
        s.connect(self.hostport)
        if verbose: print('Sending', [cmd])
        s.sendall(cmd)
        response = []
        while True: # XXX don't like while-True
            r = s.recv(bufsize)
            response.append(r)
            if len(r) < bufsize: break
        response = ''.join(response)
        if verbose: print('Got Response:', [response])
        return response
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
        resp1 = self._command(CMD_MOVE_AZ+'\n%s\r' % (az - self._delta_az), verbose=verbose)
        resp2 = self._command(CMD_MOVE_EL+'\n%s\r' % (alt - self._delta_alt), verbose=verbose)
        assert((resp1 == 'ok') and (resp2 == 'ok')) # fails if server is down or rejects command
        if verbose: print('Pointing Initiated')
        if wait: self.wait(verbose=verbose)
    def wait(self, verbose=False):
        '''Wait until telescope slewing is complete

        Parameters
        ----------
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        resp1 = self._command(CMD_WAIT_AZ,  timeout=MAX_SLEW_TIME, verbose=verbose)
        resp2 = self._command(CMD_WAIT_EL, timeout=MAX_SLEW_TIME, verbose=verbose)
        assert((resp1 == '0') and (resp2 == '0')) # fails if server is down or rejects command
        if verbose: print('Pointing Complete')
    def get_pointing(self, verbose=False):
        '''Return the current telescope pointing

        Parameters
        ----------
        verbose : bool, be verbose, default=False

        Returns
        -------
        alt     : float degrees, altitude angle 
        az      : float degrees, azimuthal angle'''
        az = float(self._command(CMD_GET_AZ, verbose=verbose))
        alt = float(self._command(CMD_GET_EL, verbose=verbose))
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
    '''Interface for controlling the two UGRadio interferometer telescopes together.'''
    def __init__(self, host_ant_w=HOST_ANT_W, host_ant_e=HOST_ANT_E, port=PORT, 
            delta_alt_ant_w=DELTA_ALT_ANT_W, delta_az_ant_w=DELTA_AZ_ANT_W,
            delta_alt_ant_e=DELTA_ALT_ANT_E, delta_az_ant_e=DELTA_AZ_ANT_E):
        self.ant_w = TelescopeClient(host_ant_w, port, delta_alt=delta_alt_ant_w, delta_az=delta_az_ant_w)
        self.ant_e = TelescopeClient(host_ant_e, port, delta_alt=delta_alt_ant_e, delta_az=delta_az_ant_e)
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
        self.ant_w.stow(wait=False, verbose=verbose)
        self.ant_e.stow(wait=False, verbose=verbose)
        if wait: self.wait(verbose=verbose)
    def maintenance(self, wait=True, verbose=False):
        '''Point both antennas to the maintenance position

        Parameters
        ----------
        wait    : bool, pause until antenna has completed pointing, default=True
        verbose : bool, be verbose, default=False

        Returns
        -------
        None'''
        self.ant_w.maintenance(wait=False, verbose=verbose)
        self.ant_e.maintenance(wait=False, verbose=verbose)
        if wait: self.wait(verbose=verbose)

AZ_ENC_OFFSET = 0
AZ_ENC_SCALE = 11.5807213
EL_ENC_OFFSET = 4096
EL_ENC_SCALE = 11.566584697
DRIVE_ENCODER_STATES = float(2**14)
DRIVE_DEG_PER_CNT = 360. / DRIVE_ENCODER_STATES

class TelescopeDirect:
    '''Low-level interface for controlling telescope pointing from a Raspberry
    Pi with a direction connection to the telescope.'''
    def __init__(self, serialPort='/dev/ttyUSB0', baudRate=9600, timeout=1, verbose=True,
            az_enc_offset=AZ_ENC_OFFSET, az_enc_scale=AZ_ENC_SCALE,
            el_enc_offset=EL_ENC_OFFSET, el_enc_scale=EL_ENC_SCALE):
        self._serial = serial.Serial(serialPort, baudRate, timeout=timeout)
        self.verbose = verbose
        self.az_enc_offset = az_enc_offset
        self.az_enc_scale = az_enc_scale
        self.el_enc_offset = el_enc_offset
        self.el_enc_scale = el_enc_scale
        self.init_dish()
    def _read(self, flush=False, bufsize=1024):
        resp = []
        while len(resp) < bufsize:
            c = self._serial.read(1)
            c = c.decode('ascii')
            if len(c) == 0: break
            if c == '\r' and not flush: break
            resp.append(c)
        resp = ''.join(resp)
        if self.verbose: print('Read:', [resp])
        return resp
    def _write(self, cmd, bufsize=1024):
        if self.verbose: print('Writing', [cmd])
        self._serial.write(cmd) #Receiving from client
        time.sleep(0.1) # Let the configuration command make the change it needs
        return self._read(bufsize=bufsize)
    def init_dish(self):
        self._read(flush=True)
        self._write(b'.a s r0xc8 257\r')
        self._write(b'.a s r0xcb 15000\r')
        self._write(b'.a s r0xcc 25\r')
        self._write(b'.a s r0xcd 25\r')
        self._write(b'.a s r0x24 21\r')
        self._write(b'.b s r0xc8 257\r')
        self._write(b'.b s r0xcb 15000\r')
        self._write(b'.b s r0xcc 25\r')
        self._write(b'.b s r0xcd 25\r')
        self._write(b'.b s r0x24 21\r')
    def reset_dish(self, sleep=10):
        self._write(b'r\r')
        time.sleep(sleep)
        self.init_dish()
    def wait_az(self, max_wait=120):
        status = '-1'
        for i in range(max_wait):
            status = self._write(b'.a g r0xc9\r').split()[1]
            if status == '0': break
            time.sleep(1)
        return status
    def wait_el(self, max_wait=120):
        status = '-1'
        for i in range(max_wait):
            status = self._write(b'.b g r0xc9\r').split()[1]
            if status == '0': break
            time.sleep(1)
        return status
    def get_az(self):
        az_cnts = float(self._write(b'.a g r0x112\r').split()[1])
        az_cnts %= DRIVE_ENCODER_STATES
        az = ((az_cnts - self.az_enc_offset) * DRIVE_DEG_PER_CNT) % 360
        return az
    def get_el(self):
        el_cnts = float(self._write(b'.b g r0x112\r').split()[1])
        el_cnts %= DRIVE_ENCODER_STATES
        el = (el_cnts - self.el_enc_offset) * DRIVE_DEG_PER_CNT
        return el
    def move_az(self, dishAz):
        azResponse = self.wait_az()
        if azResponse != '0':
            return 'e 1'
        dishAz = (dishAz + 360.) % 360
        # Enforce absolute bounds.  Comment out to override.
        if (dishAz < AZ_MIN) or (dishAz > AZ_MAX): 
            return 'e 1'
        az_cnts = int(self.get_az() / DRIVE_DEG_PER_CNT)
        azMoveCmd =  '.a s r0xca ' + str(int((dishAz / DRIVE_DEG_PER_CNT - az_cnts) * self.az_enc_scale)) + '\r'
        self._write(azMoveCmd.encode('ascii'))
        dishResponse = self._write(b'.a t 1\r')
        return dishResponse
    def move_el(self, dishEl):
        elResponse = self.wait_el()
        if elResponse != '0':
            return 'e 1'
        # Enforce absolute bounds.  Comment out to override.
        if (dishEl < ALT_MIN) or (dishEl > ALT_MAX): 
            return 'e 1'
        el_cnts = int(self.get_el() / DRIVE_DEG_PER_CNT)
        elMoveCmd =  '.b s r0xca ' + str(int((dishEl / DRIVE_DEG_PER_CNT - el_cnts) * self.el_enc_scale)) + '\r'
        self._write(elMoveCmd.encode('ascii'))
        dishResponse = self._write(b'.b t 1\r')
        return dishResponse

CMD_MOVE_AZ = 'moveAz'
CMD_MOVE_EL = 'moveEl'
CMD_WAIT_AZ = 'waitAz'
CMD_WAIT_EL = 'waitEl'
CMD_GET_AZ = 'getAz'
CMD_GET_EL = 'getEl'

class TelescopeServer(TelescopeDirect):
    '''A higher-level interface running on a Raspberry Pi for handling 
    network requests to point a telescope.'''
    def run(self, host='', port=PORT, verbose=True, timeout=10):
        self.verbose = verbose
        if self.verbose:
            print('Initializing dish...')
            self.reset_dish()
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.bind((host,port))
            s.listen(10)
            while True:
                conn, addr = s.accept()
                conn.settimeout(timeout)
                if self.verbose: print('Request from', (conn,addr))
                thread.start_new_thread(self._handle_request, (conn,))
        finally:
            s.close()
    def _handle_request(self, conn):
        '''Private thread for handling an individual connection.  Will execute
        at most one write and one read before terminating connection.'''
        cmd = conn.recv(1024)
        if not cmd: return
        if self.verbose: print('Enacting:', [cmd], 'from', conn)
        cmd = cmd.decode('ascii')
        cmd = cmd.split('\n')
        if cmd[0] == 'simple':
            resp = self._write(cmd[1].encode('ascii'))
        elif cmd[0] == CMD_MOVE_AZ:
            resp = self.move_az(float(cmd[1]))
        elif cmd[0] == CMD_MOVE_EL:
            resp = self.move_el(float(cmd[1]))
        elif cmd[0] == CMD_WAIT_AZ:
            resp = self.wait_az()
        elif cmd[0] == CMD_WAIT_EL:
            resp = self.wait_el()
        elif cmd[0] == CMD_GET_AZ:
            resp = str(self.get_az())
        elif cmd[0] == CMD_GET_EL:
            resp = str(self.get_el())
        elif cmd[0] == 'reset':
            resp = self.reset_dish()
        else:
            resp = ''
        if self.verbose: print('Returning:', [resp])
        conn.sendall(resp.encode('ascii'))
