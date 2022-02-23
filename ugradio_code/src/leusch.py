# New Leuschner class definitions

"""Module for controlling the Leuschner radio telescope."""

from __future__ import print_function
import socket, serial, time, math, sys
import subprocess
try: import thread
except(ImportError): import _thread as thread
try:
    import RPi.GPIO as GPIO # necessary for LeuschNoiseServer
except(ImportError):
    pass

MAX_SLEW_TIME = 220 # seconds

ALT_MIN, ALT_MAX = 15., 85. # Pointing bounds, degrees
AZ_MIN, AZ_MAX  = 5., 350. # Pointing bounds, degrees

ALT_STOW = 80. #85. # Position for stowing antenna
AZ_STOW = 180. # Position for stowing antenna

ALT_MAINT = 20. # Position for antenna maintenance
AZ_MAINT = 180. # Position for antenna maintenance

HOST_ANT = '192.168.1.156' # RPI host for antenna
HOST_NOISE_SERVER = '192.168.1.90' # RPI host for noise diode
PORT = 1420

HOST_SPECTROMETER = '10.0.1.2' # IP address of ROACH spectrometer

# Offsets (in deg) to subtract from crd to get encoder value to write
DELTA_ALT_ANT = -0.30  # (true - encoder) offset
DELTA_AZ_ANT  = -0.13  # (true - encoder) offset

class LeuschTelescope:
    '''Interface for controlling the Leuschner Telescope.'''
    def __init__(self, host=HOST_ANT, port=PORT,
            delta_alt=DELTA_ALT_ANT, delta_az=DELTA_AZ_ANT):
        self._delta_alt = delta_alt
        self._delta_az = delta_az
        self.hostport = (host,port)

    def _check_pointing(self, alt, az):
        '''Ensure pointing is within bounds.  Raises AssertionError if not.'''
        assert(ALT_MIN < alt < ALT_MAX) # range is nominally 15 to 85 degrees
        assert(AZ_MIN < az < AZ_MAX)    # range is nominally 5 to 350 degrees

    def _command(self, cmd, bufsize=1024, timeout=10, verbose=False):
        '''Communicate with host server and return response as string.'''
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout) # seconds
        s.connect(self.hostport)
        if verbose: print('Sending', [cmd])
        s.sendall(bytes(cmd, encoding='utf8'))
        response = []
        while True: # XXX don't like while-True
            r = s.recv(bufsize)
            response.append(r)
            if len(r) < bufsize: break
        response = b''.join(response)
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
        assert((resp1 == b'ok') and (resp2 == b'ok')) # fails if server is down or rejects command
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
        assert((resp1 == b'0') and (resp2 == b'0')) # fails if server is down or rejects command
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
        '''Point to the stow position.

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

class LeuschNoise:
    '''Interface for controlling noise diode on Leuschner dish.'''
    def __init__(self, host=HOST_NOISE_SERVER, port=PORT, verbose=False):
        self.hostport = (host,port)
        self.verbose = verbose

    def on(self):
        '''Turn Leuschner noise diode on.'''
        self._cmd(CMD_NOISE_ON)

    def off(self):
        '''Turn Leuschner noise diode off.'''
        self._cmd(CMD_NOISE_OFF)


    def _cmd(self, cmd):
        '''Low-level interface for sending command to LeuschNoiseServer.'''
        assert(cmd in (CMD_NOISE_ON, CMD_NOISE_OFF)) # check if valid command
        if self.verbose:
            print('LeuschNoise sending command:', [cmd])
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(self.hostport)
        s.sendall(bytes(cmd, encoding='utf8'))

AZ_ENC_OFFSET = -3035.0 # -4901
AZ_ENC_SCALE = 1800.342065
EL_ENC_OFFSET = -0.02181661564 #-0.3774466558186913
DISH_EL_OFFSET = -0.3556300401687622
DRIVE_ENCODER_STATES = float(2**14)
DRIVE_DEG_PER_CNT = 360. / DRIVE_ENCODER_STATES
DRIVE_RAD_PER_CNT = (2*math.pi) / DRIVE_ENCODER_STATES
DEG2RAD = math.pi / 180.
DRIVE_STUB_LEN = 1.487911343574524
DRIVE_ENC_SCALE = 6.173610955784170E-08
DRIVE_CLENGTH = 9.587619900703430E-01

class TelescopeDirect:

    def __init__(self, serialPort='/dev/ttyUSB0', baudRate=9600, timeout=1, verbose=True,
            az_enc_offset=AZ_ENC_OFFSET, az_enc_scale=AZ_ENC_SCALE,
            el_enc_offset=EL_ENC_OFFSET, dish_el_offset=DISH_EL_OFFSET,
            stub_len=DRIVE_STUB_LEN, drive_enc_scale=DRIVE_ENC_SCALE, drive_clength=DRIVE_CLENGTH):
        self._serial = serial.Serial(serialPort, baudRate, timeout=timeout)
        self._lock = thread.allocate_lock()
        self.verbose = verbose
        self.az_enc_offset = az_enc_offset
        self.az_enc_scale = az_enc_scale
        self.el_enc_offset = el_enc_offset
        self.dish_el_offset = dish_el_offset
        self.stub_len = stub_len
        self.drive_enc_scale = drive_enc_scale
        self.drive_clength = drive_clength
        self.init_dish()

    def log(self, *args):
        if self.verbose:
            print(*args)
            sys.stdout.flush()

    def _read(self, flush=False, bufsize=1024):
        resp = []
        while len(resp) < bufsize:
            c = self._serial.read(1)
            c = c.decode('ascii')
            if len(c) == 0: break
            if c == '\r' and not flush: break
            resp.append(c)
        resp = ''.join(resp)
        self.log('Read:', [resp])
        return resp

    def _write(self, cmd, bufsize=1024):
        self.log('Writing', [cmd])
        self._lock.acquire()
        self._serial.write(cmd) #Receiving from client
        time.sleep(0.1) # Let the config command make the change it needs
        rv = self._read(bufsize=bufsize)
        self._lock.release()
        return rv

    def init_dish(self):
        self._read(flush=True)
        # The following definitions are specific to the Copley BE2 model
        self._write(b'.a s r0xc8 257\r')
        self._write(b'.a s r0xcb 1500000\r')
        self._write(b'.a s r0xcc 2500\r')
        self._write(b'.a s r0xcd 2500\r')
        self._write(b'.a s r0x24 21\r')
        self._write(b'.b s r0xc8 257\r')
        self._write(b'.b s r0xcb 1500000\r')
        self._write(b'.b s r0xcc 2500\r')
        self._write(b'.b s r0xcd 2500\r')
        self._write(b'.b s r0x24 21\r')

    def reset_dish(self, sleep=10):
        self._write(b'r\r')
        time.sleep(sleep)
        self.init_dish()

    def wait_az(self, max_wait=220):
        status = '-1'
        for i in range(max_wait):
            status = self._write(b'.a g r0xc9\r').split()[1]
            self.log("wait_az status=", status)
            # sometimes status = 16384: set when move is aborted, see Copley Parameter Dictionary pg 45
            if int(status) >= 0:
                break
            time.sleep(1)
        return status

    def wait_el(self, max_wait=220):
        status = '-1'
        for i in range(max_wait):
            status = self._write(b'.b g r0xc9\r').split()[1]
            self.log("wait_el status=", status)
            # sometimes status = 16384: set when move is aborted, see Copley Parameter Dictionary pg 45
            if int(status) >= 0:
                break
            time.sleep(1)
        return status

    def get_az(self):
        az_cnts = float(self._write(b'.a g r0x112\r').split()[1])
        az_cnts %= DRIVE_ENCODER_STATES
        az = (az_cnts - self.az_enc_offset) * DRIVE_DEG_PER_CNT
        az %= 360 # necessary b/c encoder wraps at az=65 deg
        return az

    def get_el(self):
        el_cnts = float(self._write(b'.b g r0x112\r').split()[1])
        el_cnts %= DRIVE_ENCODER_STATES
        el = 90 - el_cnts*DRIVE_DEG_PER_CNT - self.el_enc_offset/DEG2RAD
        #el = str(90 - ((float(el_cnts)*DRIVE_DEG_PER_CNT)+(self.el_enc_offset*180.0/math.pi)))
        #el = ((el_cnts-(self.dish_el_offset*DRIVE_ENCODER_STATES/(2.0*math.pi))+DRIVE_ENCODER_STATES) % DRIVE_ENCODER_STATES)*(2.0*math.pi)/(DRIVE_ENCODER_STATES)
        #el = ((el_cnts - self.dish_el_offset/DEG2RAD/DRIVE_DEG_PER_CNT) % DRIVE_ENCODER_STATES) * DRIVE_DEG_PER_CNT
        return el

    def move_az(self, dishAz):
        azResponse = self.wait_az()
        if azResponse != '0':
            return 'e 1'
        dishAz = (dishAz + 360.) % 360 # necessary b/c encoder wraps at az=65 deg
        # Enforce absolute bounds.  Comment out to override.
        if (dishAz < AZ_MIN) or (dishAz > AZ_MAX):
            return 'e 1'
        az_cnts = int(self.get_az() / DRIVE_DEG_PER_CNT)
        # commands are sent as a delta from current position
        azMoveCmd =  '.a s r0xca ' + str(int((dishAz / DRIVE_DEG_PER_CNT - az_cnts) * self.az_enc_scale)) + '\r'
        self._write(azMoveCmd.encode('ascii'))
        dishResponse = self._write(b'.a t 1\r')
        return dishResponse

    def _el_to_drive_enc(self, el_rad):
        drive_len = math.sqrt(1 + self.drive_clength**2 - 2*self.drive_clength*math.cos(el_rad))
        enc = (drive_len - self.stub_len) / self.drive_enc_scale
        return enc

    def move_el(self, dishEl):
        elResponse = self.wait_el()
        if elResponse != '0':
            return 'e 1'
        # Enforce absolute bounds.  Comment out to override.
        if (dishEl < ALT_MIN) or (dishEl > ALT_MAX):
            return 'e 1'

        dishEl_rad = dishEl * DEG2RAD
        # Get current elevation
        curEl = float(self._write(b'.b g r0x112\r').split()[1])
        # Correct for offset and convert to radians
        dish_el_offset_cnts = self.dish_el_offset/DRIVE_RAD_PER_CNT
        curEl = (curEl-dish_el_offset_cnts)%DRIVE_ENCODER_STATES
        curEl_rad = curEl*DRIVE_RAD_PER_CNT

        curElVal = self._el_to_drive_enc(curEl_rad)
        nextElVal = self._el_to_drive_enc(math.pi/2 -dishEl_rad\
                     -self.el_enc_offset - self.dish_el_offset)
        elMoveCmd =  '.b s r0xca ' + str(int(nextElVal-curElVal)) + '\r'
        self._write(elMoveCmd.encode('ascii'))
        dishResponse = self._write(b'.b t 1\r')
        return dishResponse

        #curEl_rad = self.get_el() * DEG2RAD
        #curElVal = (math.sqrt(1.0 + self.drive_clength**2 - (2.0*self.drive_clength*math.cos(curEl_rad))) - self.stub_len) / self.drive_enc_scale
        #nextElVal = (math.sqrt(1.0 + self.drive_clength**2 - (2.0*self.drive_clength*math.cos(0.5*math.pi -dishEl_rad -self.el_enc_offset -self.dish_el_offset))) - self.stub_len) / self.drive_enc_scale

CMD_MOVE_AZ = 'moveAz'
CMD_MOVE_EL = 'moveEl'
CMD_WAIT_AZ = 'waitAz'
CMD_WAIT_EL = 'waitEl'
CMD_GET_AZ = 'getAz'
CMD_GET_EL = 'getEl'

class TelescopeServer(TelescopeDirect):
    def run(self, host='', port=PORT, verbose=True, timeout=10):
        self.verbose = verbose
        self.log('Initializing dish...')
        self.reset_dish()
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.bind((host,port))
            s.listen(10)
            while True:
                conn, addr = s.accept()
                conn.settimeout(timeout)
                self.log('Request from', (conn,addr))
                thread.start_new_thread(self._handle_request, (conn,))
        finally:
            s.close()
    def _handle_request(self, conn):
        '''Private thread for handling an individual connection.  Will execute
        at most one write and one read before terminating connection.'''
        cmd = conn.recv(1024)
        if not cmd:
            return
        self.log('Enacting:', [cmd], 'from', conn)
        cmd = cmd.decode('ascii')
        cmd = cmd.split('\n')
        self.log("the cmd is: ", cmd)
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
        self.log('Returning:', [resp])
        conn.sendall(resp.encode('ascii'))

CMD_NOISE_OFF = 'off'
CMD_NOISE_ON = 'on'

class LeuschNoiseServer:
    '''Class for providing remote control over the noise diode on Leuschner dish.
    Runs on a RPI with a direct connection to the noise diode via GPIO pins.'''
    def __init__(self, verbose=True):
        self.verbose = verbose
        self.prev_cmd = None

    def log(self, *args):
        if self.verbose:
            print(*args)
            sys.stdout.flush()

    def run(self, host='', port=PORT, timeout=10):
        '''Begin hosting server allowing remote control of noise diode on specified port.'''
        self.log('Initializing noise_server..')
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.bind((host,port))
            s.listen(10)
            while True:
                conn, addr = s.accept()
                conn.settimeout(timeout)
                self.log('Request from', (conn,addr))
                thread.start_new_thread(self._handle_request, (conn,))
        finally:
            s.close()

    def _handle_request(self, conn):
        '''Private thread for handling an individual connection.  Will execute
        at most one write and one read before terminating connection.'''
        cmd = conn.recv(1024)
        if not cmd:
            return
        self.log('Enacting:', [cmd], 'from', conn)
        cmd = cmd.decode('ascii')
        # only execute digital I/O write code if a change of state
        # command is received over the socket.  I will avoid multiple of
        # overwrite commands to the Raspberry
        pin = 5 # This was originally 05
        if self.prev_cmd != cmd:
            self.prev_cmd = cmd
            GPIO.setmode(GPIO.BCM) # Errors out if import RPi.GPIO failed
            GPIO.setwarnings(False)
            GPIO.setup(pin, GPIO.OUT) # pin 29
            # switch pin 29 of Raspberry Pi to TTL level low
            if cmd == CMD_NOISE_OFF:
                self.log('write digital I/O low')
                GPIO.output(pin, False)   # pin 29
            # switch pin 29 of Raspberry Pi to TTL level high
            elif cmd == CMD_NOISE_ON:
                self.log('write digital I/O high')
                GPIO.output(pin, True)   # pin 29

class Spectrometer:
    '''A mock interface for interacting with the Leuschner spectrometer
    via the command-line script "leusch_helper.py" which makes use of the
    leuschner python package.'''
    def __init__(self, ip=HOST_SPECTROMETER):
        '''ip: the IP address of the spectrometer'''
        self.ip = ip

    def check_connected(self):
        '''Check if the ROACH is connected. Prints connection to
        stdout, or prints an IOError if client can't reach the ROACH.'''
        cmd = ["leusch_helper.py", "cc", self.ip]
        subprocess.run(cmd)

    def read_spec(self, filename, nspec, coords, system='ga'):
        """Receives data from the Leuschner spectrometer and
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
        cmd = ["leusch_helper.py", "rs", self.ip, filename,
                str(nspec), str(coords), system]
        subprocess.run(cmd)

    def int_time(self):
        '''Print the integration time used by the spectrometer.'''
        cmd = ["leusch_helper.py", "it", self.ip]
        return float(subprocess.check_output(cmd)[:-1])
