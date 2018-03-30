# New Leuschner class definitions

"""Module for controlling the Leuschner radio telescope."""

from __future__ import print_function
import socket, serial, time, thread, math
try:
    import RPi.GPIO as GPIO # necessary for LeuschNoiseServer
except(ImportError):
    pass

MAX_SLEW_TIME = 220 # seconds

ALT_MIN, ALT_MAX = 15., 85. # Pointing bounds, degrees
AZ_MIN, AZ_MAX  = 5., 350. # Pointing bounds, degrees

ALT_STOW = 85. # Position for stowing antenna
AZ_STOW = 180. # Position for stowing antenna

ALT_MAINT = 20. # Position for antenna maintenance
AZ_MAINT = 180. # Position for antenna maintenance

HOST_ANT = '192.168.1.156' # RPI host for antenna
PORT = 1420

# Offsets to subtract from crd to get encoder value to write
DELTA_ALT_ANT = 0.165  # (true - encoder) offset
DELTA_AZ_ANT = -0.34  # (true - encoder) offset

class LeuschTelescope:
    '''Interface for controlling a single antenna.  Use Interferometer to
    control the pair with default settings.'''
    def __init__(self, host=HOST_ANT, port=PORT,
            delta_alt_ant=DELTA_ALT_ANT, delta_az_ant=DELTA_AZ_ANT):
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

AZ_ENC_OFFSET = -3035.0 # -4901
AZ_ENC_SCALE = 1800.342065
EL_ENC_OFFSET = -0.02181661564#-0.3774466558186913
DISH_EL_OFFSET = -3.556300401687622E-01
DRIVE_ENCODER_STATES = float(2**14)
DRIVE_DEG_PER_CNT = 360. / DRIVE_ENCODER_STATES
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
        self.verbose = verbose
        self.az_enc_offset = az_enc_offset
        self.az_enc_scale = az_enc_scale
        self.el_enc_offset = el_enc_offset
        self.dish_el_offset = dish_el_offset
        self.stub_len = stub_len
        self.drive_enc_scale = drive_enc_scale
        self.drive_clength = drive_clength
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
    def init_dish(self): # The following definitions are specific to the Copley BE2 model
        self._read(flush=True)
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
            if self.verbose: print ("wait_az status=", status)
            if status == '0': break
            time.sleep(1)
        return status
    def wait_el(self, max_wait=220):
        status = '-1'
        for i in range(max_wait):
            status = self._write(b'.b g r0xc9\r').split()[1]
            if self.verbose: print("wait_el status=", status)
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
        #el_cnts %= DRIVE_ENCODER_STATES
        #el = 90 - ((float(el_cnts)*DRIVE_DEG_PER_CNT)+(self.el_enc_offset*180.0/math.pi))
        #el = ((el_cnts-(self.dish_el_offset*DRIVE_ENCODER_STATES/(2.0*math.pi))+DRIVE_ENCODER_STATES) % DRIVE_ENCODER_STATES)*(2.0*math.pi)/(DRIVE_ENCODER_STATES)        
        el = ((el_cnts - self.dish_el_offset/DEG2RAD/DRIVE_DEG_PER_CNT) % DRIVE_ENCODER_STATES) * DRIVE_DEG_PER_CNT
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
        curEl_rad = self.get_el() * DEG2RAD
        curElVal = self._el_to_drive_enc(curEl_rad)
        #curElVal = (math.sqrt(1.0 + self.drive_clength**2 - (2.0*self.drive_clength*math.cos(curEl_rad))) - self.stub_len) / self.drive_enc_scale
        nextElVal = self._el_to_drive_enc(math.pi/2 - dishEl_rad - self.el_enc_offset - self.dish_el_offset)
        #nextElVal = (math.sqrt(1.0 + self.drive_clength**2 - (2.0*self.drive_clength*math.cos((0.5*math.pi-dishEl_rad)-self.el_enc_offset-self.dish_el_offset))) - self.stub_len) / self.drive_enc_scale
        elMoveCmd =  '.b s r0xca ' + str(int(nextElVal-curElVal)) + '\r'
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
        if self.verbose: print ("the cmd is: ", cmd)
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
           
class LeuschNoiseServer:
    '''Class for providing remote control over the noise diode on Leuschner dish.
    Runs on a RPI with a direct connection to the noise diode via GPIO pins.'''
    def __init__(self):
        self.prev_cmd = None
    def run(self, host='', port=PORT, verbose=True, timeout=10):
        '''Begin hosting server allowing remote control of noise diode on specified port.'''
        self.verbose = verbose
        if self.verbose:
            print('Initializing noise_server..')
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
        # only execute digital I/O write code if a change of state
        # command is received over the socket.  I will avoid multiple of
        # overwrite commands to the Raspberry
        if self.prev_cmd != cmd:
            self.prev_cmd = cmd                       
            GPIO.setmode(GPIO.BCM) # Errors out if import RPi.GPIO failed
            GPIO.setwarnings(False)
            GPIO.setup(05, GPIO.OUT) # pin 29
            # switch pin 29 of Raspberry Pi to TTL level low           
            if cmd == CMD_NOISE_OFF:
                if self.verbose: print('write digital I/O low')
                GPIO.output(05, False)   # pin 29                
            # switch pin 29 of Raspberry Pi to TTL level high    
            elif cmd == CMD_NOISE_ON:
                if self.verbose: print('write digital I/O high')         
                GPIO.output(05, True)   # pin 29

HOST_NOISE_SERVER = '192.168.1.90'
CMD_NOISE_OFF = 'off'
CMD_NOISE_ON = 'on'

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
        assert(cmd in (CMD_NOISE_OFF, CMD_NOISE_OFF)) # check if valid command
        if self.verbose:
            print('LeuschNoise sending command:', [cmd])
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(self.hostport)
        s.sendall(cmd)
