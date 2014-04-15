'''This module provides the operational interface to the Leuschner dish used in Lab 4.'''
import socket, time, math
import pointing

IP_ADDR = '128.32.197.194' # IP Address of the NETEON serial to ethernet adapter
PORT = 4660 # PORT on which the NETEON serial adapter is awaiting a connection
MAXLEN = 4096
MAX_HM_TRIES = 120
MAX_SET_TRIES = 3
MAX_MV_TRIES = 120

CTRL_STATUS = {
  'R': 'ready',
  'S': 'ready, needs attention',
  'B': 'busy',
  'C': 'busy, needs attention',
}

class Dish:
    '''Interface to the Leuschner dish.'''
    def __init__(self, ip=IP_ADDR, port=PORT, verbose=False):
        self.ip_port = (ip, port)
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect(self.ip_port)
        self.sock.settimeout(1)
        self.verbose = verbose
    def rx(self):
        '''Receive a TCP packet over (ip,port) interface of the dish.'''
        rv = []
        try:
            while True:
                rv.append(self.sock.recv(MAXLEN))
                if len(rv[-1]) == 0: break
        except(socket.timeout): pass
        return ''.join(rv)
    def __del__(self):
        self.sock.close()
    def noise_on(self):
        '''Turn on the noise diode for calibration.'''
        self._noise(0)
    def noise_off(self):
        '''Turn off the noise diode for calibration.'''
        self._noise(1)
    def _noise(self, state):
        '''Lower-level interface to noise diode.'''
        if self.verbose:
            # Yes, this is the opposite of what you'd think.
            if not state: print 'Turning ON noise source...'
            else: print 'Turning OFF noise source...'
        time.sleep(1)
        state = 1 if state else 0
        self.sock.send('\r\r1O%dX\r\r1IS\r' % state)
        oem_reply = self.rx()
        oem_reply = oem_reply.split('*')[1]
        oem_reply = oem_reply[:4]
        oem_reply = int(oem_reply[-1:])
        if state != oem_reply: raise RuntimeError('Set noise %s failed' % state)
    def drive_on(self):
        '''Turn the telescope drives on.'''
        if self.verbose: print 'Energizing Drives'
        self.sock.send('\r\rON\r')
        oem_reply = self.rx()
        time.sleep(.5) #WAIT,.5
    def drive_off(self):
        '''Turn the telescope drives off.'''
        if self.verbose: print 'De-Energizing Drives'
        time.sleep(1) #WAIT,1
        self.sock.send('\r\rOFF\r')
        oem_reply = self.rx()
    def _home(self):
        '''Send low-level home command to telescope.'''
        if self.verbose: print 'Searching for Home Position...'
        time.sleep(1) #WAIT,1
        self.sock.send('\r\rGH-45\r')
        oem_reply = self.rx()
    def set_dist(self, axis, distance):
        '''Set the distance of the drive on the specified telescope axis ('1' or '2')'''
        if self.verbose: print 'Setting Drive', axis, 'distance to', distance
        time.sleep(1) #WAIT,1
        self.sock.send('\r\r%sD%s\r\r%sD\r' % (axis, distance, axis))
        oem_reply = self.rx().split('*D')[1]
        oem_reply = oem_reply.split('\r')[0]
        if oem_reply != distance:
            raise RuntimeError('Set Drive %s distance to %s FAILED' % (axis, distance))
    def ctrl_stat(self, axis):
        '''Return the status of the controller for the specified telescope axis ('1' or '2')'''
        if self.verbose: print 'Controller status requested from Drive', axis
        time.sleep(1) #WAIT,1
        self.sock.send('\r\r%sR\r' % axis)
        oem_reply = self.rx().split('*')[1]
        oem_reply = oem_reply.split('\r')[0]
        if self.verbose:
            print 'Drive', axis, 'controller reply is', oem_reply,'->',CTRL_STATUS[oem_reply]
        return oem_reply
    def enc_pos(self, axis):
        '''Return the absolute encoder postion of the drive on the specified telescope axis ('1' or '2')'''
        if self.verbose: print 'Absolute encoder position requested from Drive', axis
        time.sleep(1) #WAIT,1
        self.sock.send('\r\r%sPX\r' % axis)
        oem_reply = int(self.rx().split('*')[1])
        if self.verbose: 'Absolute encoder position received from Drive %s is %d' % (axis,oem_reply)
        return oem_reply
    def set_go(self):
        '''Move the telescope.'''
        if self.verbose: print 'Drive Going, Please Wait'
        time.sleep(1)
        self.sock.send('\r\rG\r')
    def home(self):
        '''Home the telescope (to zenith) and reset the encoder positions.'''
        if self.verbose: print 'Homing (this can take a while)...'
        self.drive_off(); self.drive_on()
        time.sleep(2)
        self._home()
        axes = ['1','2']
        for axis in axes:
            for hm_tries in xrange(MAX_HM_TRIES):
                home_ready = self.ctrl_stat(axis)
                if home_ready in ['R','S']: break
                time.sleep(1)
            # XXX as written, seems like doesnt' check for success
        if self.verbose: print 'dish zeroed properly'
        self.drive_off(); self.drive_on()
        for axis,dist in zip(axes,['5450000','8200000']):
            for set_tries in xrange(MAX_SET_TRIES):
                self.set_dist(axis,dist)
        self.set_go()
        for axis in axes:
            for mv_tries in xrange(MAX_MV_TRIES):
                mv_ready = self.ctrl_stat(axis)
                if mv_ready == 'R': break
                time.sleep(1)
        if self.verbose: print 'dish finished moving to zenith'
        enc_1_pos, enc_2_pos = [self.enc_pos(ax) for ax in axes]
        if self.verbose:
            print 'encoder 1 position',enc_1_pos
            print 'encoder 2 position',enc_2_pos
        self.drive_off()
    def point(self, alt, az, validate=None):
        '''Point the telescope to the specified alt,az.  If validate is True, return whether the
        specified pointing is valid.  Pointing (without validating) to a prohibited direction
        raises a ValueError.'''
        # ; Changed kburns 04/11/2011, noise on and off switched during feed upgrade Spring 2011
        # Beginning of ALT-AZ move OR move checking
        self.drive_off(); self.drive_on()
        time.sleep(1)
	x_step,y_step = pointing.az_alt_to_xy(az, alt, validate=validate)
        axes = ['1','2']

        for axis,dist in zip(axes,[str(x_step),str(y_step)]):
            for set_tries in xrange(MAX_SET_TRIES):
                try:
                    self.set_dist(axis,dist)
                    break
                except(RuntimeError): pass # XXX don't like this
        self.set_go()

        for axis in axes:
            for mv_tries in xrange(MAX_MV_TRIES):
                mv_ready = self.ctrl_stat(axis)
                if mv_ready in ['R','S']: break
                time.sleep(1)
        enc_1_pos, enc_2_pos = [self.enc_pos(ax) for ax in axes]
	if self.verbose:
            print 'encoder 1 position',enc_1_pos
            print 'encoder 2 position',enc_2_pos
        self.drive_off()
    
