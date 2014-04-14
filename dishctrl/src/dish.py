import socket, time, math

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

DEG2RAD = math.pi / 180.

ppr=115600 #pulses per one revolution of geardrive output shaft 
slead=.2 #screw lead in inches
ppi=ppr/slead #actuator encoder pulses per inch of travel
az_off = 0
az_off = az_off*DEG2RAD

a_x=37.75 #below values not taken from memo4 and in inches unless specified
b_x=15.125
C_x=1.2687 #radians
m_x=2.0
a_y=17.5625
b_y=14.96
C_y=1.3461 #radians
m_y=2.0


c_x_min=27
c_x_zen=36.25
c_x_max=49.25
c_y_min=6.5
c_y_zen=20.375
c_y_max=28.75

x_min = math.sqrt((c_x_min**2-m_x**2))
x_zen = math.sqrt((c_x_zen**2-m_x**2))
x_max = math.sqrt((c_x_max**2-m_x**2))
y_min = math.sqrt((c_y_min**2-m_y**2))
y_zen = math.sqrt((c_y_zen**2-m_y**2))
y_max = math.sqrt((c_y_max**2-m_y**2))

a_min = math.acos((a_x**2+b_x**2-c_x_min**2)/(2*a_x*b_x))
C_x_meas = math.acos((a_x**2+b_x**2-c_x_zen**2)/(2*a_x*b_x))
a_max = math.acos((a_x**2+b_x**2-c_x_max**2)/(2*a_x*b_x))

alpha_min = a_min-C_x_meas
alpha_max = a_max-C_x_meas

b_min = math.acos((a_y**2+b_y**2-c_y_min**2)/(2*a_y*b_y))
C_y_meas = math.acos((a_y**2+b_y**2-c_y_zen**2)/(2*a_y*b_y))
b_max = math.acos((a_y**2+b_y**2-c_y_max**2)/(2*a_y*b_y))

beta_min = b_min - C_y_meas
beta_max = b_max - C_y_meas

class Dish:
    def __init__(self, ip=IP_ADDR, port=PORT, verbose=False):
        self.ip_port = (ip, port)
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect(self.ip_port)
        self.sock.settimeout(1)
        self.verbose = verbose
    def rx(self):
        rv = []
        try:
            while True:
                rv.append(self.sock.recv(MAXLEN))
                if len(rv[-1]) == 0: break
        except(socket.timeout): pass
        return ''.join(rv)
    def __del__(self):
        self.sock.close()
    def set_noise(self, state):
        if self.verbose:
            if not state: print 'Turning ON noise source...'
            else: print 'Turning OFF noise source...'
        #OEM_REPLY='1234567890123456789012' # don't know what line above is for
        time.sleep(1) #WAIT,1 # is waiting necessary?
        # NOISE_ARG=STRCOMPRESS(STRING(NOISE),/REMOVE_ALL) # potentially need to strip off whitespace in noise
        state = 1 if state else 0
        self.sock.send('\r\r1O%dX\r\r1IS\r' % state)
        oem_reply = self.rx()
        oem_reply = oem_reply.split('*')[1]
        oem_reply = oem_reply[:4]
        oem_reply = int(oem_reply[-1:])
        if state != oem_reply: raise RuntimeError('Set noise %s failed' % state)
    def drive_on(self):
        if self.verbose: print 'Energizing Drives'
        self.sock.send('\r\rON\r')
        oem_reply = self.rx()
        time.sleep(.5) #WAIT,.5
    def drive_off(self):
        if self.verbose: print 'De-Energizing Drives'
        time.sleep(1) #WAIT,1
        self.sock.send('\r\rOFF\r')
        oem_reply = self.rx()
    def go_home(self):
        if self.verbose: print 'Searching for Home Position...'
        time.sleep(1) #WAIT,1
        self.sock.send('\r\rGH-45\r')
        oem_reply = self.rx()
    def set_dist(self, axis, distance):
        if self.verbose: print 'Setting Drive', axis, 'distance to', distance
        time.sleep(1) #WAIT,1
        self.sock.send('\r\r%sD%s\r\r%sD\r' % (axis, distance, axis))
        oem_reply = self.rx().split('*D')[1]
        oem_reply = oem_reply.split('\r')[0]
        if oem_reply != distance:
            raise RuntimeError('Set Drive %s distance to %s FAILED' % (axis, distance))
    def ctrl_stat(self, axis):
        if self.verbose: print 'Controller status requested from Drive', axis
        time.sleep(1) #WAIT,1
        self.sock.send('\r\r%sR\r' % axis)
        oem_reply = self.rx().split('*')[1]
        oem_reply = oem_reply.split('\r')[0]
        if self.verbose:
            print 'Drive', axis, 'controller reply is', oem_reply,'->',CTRL_STATUS[oem_reply]
        return oem_reply
    def enc_pos(self, axis):
        if self.verbose: print 'Absolute encoder position requested from Drive', axis
        time.sleep(1) #WAIT,1
        self.sock.send('\r\r%sPX\r' % axis)
        oem_reply = int(self.rx().split('*')[1])
        if self.verbose: 'Absolute encoder position received from Drive %s is %d' % (axis,oem_reply)
        return oem_reply
    def set_go(self):
        if self.verbose: print 'Drive Going, Please Wait'
        time.sleep(1)
        self.sock.send('\r\rG\r')
    def point(self, alt=None, az=None, home=None, noise=None, move_check=None):
        # ; Changed kburns 04/11/2011, noise on and off switched during feed upgrade Spring 2011
        if not noise is None: self.set_noise(noise)
        if not home is None:
            if self.verbose: print 'Homing (this can take a while)...'
            self.drive_off(); self.drive_on()
            time.sleep(2)
            self.go_home()
            for axis in ['1','2']:
                for hm_tries in xrange(MAX_HM_TRIES):
                    home_ready = self.ctrl_stat('1')
                    if home_ready in ['R','S']: break
                    time.sleep(1)
                # XXX as written, seems like doesnt' check for success
            if self.verbose: print 'dish zeroed properly'
            self.drive_off(); self.drive_on()
            for axis,dist in zip(['1','2'],['5450000','8200000']):
                for set_tries in xrange(MAX_SET_TRIES):
                    self.set_dist(axis,dist)
            self.set_go()
            for axis in ['1','2']:
                for mv_tries in xrange(MAX_MV_TRIES):
                    mv_ready = self.ctrl_stat(axis)
                    if mv_ready == 'R': break
                    time.sleep(1)
            if self.verbose: print 'dish finished moving to zenith'
            enc_1_pos = self.enc_pos('1')
            enc_2_pos = self.enc_pos('2')
            if self.verbose:
                print 'encoder 1 position',enc_1_pos
                print 'encoder 2 position',enc_2_pos
            self.drive_off()
        # Beginning of ALT-AZ move OR move checking
        if not alt is None and not az is None:
            #  Begining of kinematic calculations
            alt_rad = alt * DEG2RAD
            az_rad = az * DEG2RAD
            alpha = math.atan((-math.cos((az_rad-az_off)))/(math.tan(alt_rad)))
            beta = math.asin((math.sin((az_rad-az_off))*math.cos(alt_rad)))
            mv_skip = 0
            # check from min/max extensions of actuators
            if alpha < alpha_min or alpha > alpha_max: mv_skip = 1
            if beta < beta_min or beta > beta_max: mv_skip = 1
            x_ang=alpha+C_x_meas
            y_ang=beta+C_y_meas

            x_in=math.sqrt(a_x**2+b_x**2-2*a_x*b_x*math.cos(alpha+C_x_meas)-m_x**2)
            print "x_in",x_in
            y_in=math.sqrt(a_y**2+b_y**2-2*a_y*b_y*math.cos(beta+C_y_meas)-m_y**2)
            print "y_in",y_in

            x_max_mv=x_max-x_min
            y_max_mv=y_max-y_min

            x_mv=x_in-x_min
            y_mv=y_in-y_min

            if (x_mv < 0) or (x_mv > x_max_mv): mv_skip=1
            if (y_mv < 0) or (y_mv > y_max_mv): mv_skip=1
            if (mv_skip == 0) and (move_check is None):

                x_step=int(x_mv*ppi)
                y_step=int(y_mv*ppi)

                mv_dist_x = str(x_step)
                mv_dist_y = str(y_step)


                self.drive_off(); self.drive_on()
                time.sleep(1)

                for axis,dist in zip(['1','2'],[mv_dist_x, mv_dist_y]):
                    for set_tries in xrange(MAX_SET_TRIES):
                        try:
                            self.set_dist(axis,dist)
                            break
                        except(RuntimeError): pass # XXX don't like this
                self.set_go()

                for axis in ['1','2']:
                    for mv_tries in xrange(MAX_MV_TRIES):
                        mv_ready = self.ctrl_stat('1')
                        if mv_ready in ['R','S']: break
                        time.sleep(1)
                enc_1_pos = self.enc_pos('1')
                enc_2_pos = self.enc_pos('2')
                print 'encoder 1 position',enc_1_pos
                print 'encoder 2 position',enc_2_pos

                self.drive_off()


            elif move_check is None:
                print "alt-az out of range, skipping move"
                #;  ACTUAL MOVE ENDS HERE, BELOW ARE ITEMS RELATED TO CHECKING THE MOVE

            else: # move_check is not None
                if mv_skip == 0:
                    print 'can move there'
                    return 1
                elif mv_skip == 1:
                    print 'cant move there'
                    return -1


        
            
                
        
            
    
        
    
        
    

    
