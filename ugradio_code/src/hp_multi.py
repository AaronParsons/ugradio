import socket, time, threading

HOST = '10.32.92.86' # IP address of HP 3478A Multimeter GPIB microcontroller
PORT = 1234 # XXX check this

# from http://www.qsl.net/n9zia/test/HP3478_Operation_Manual.pdf
# N4 Selects the 4 1/2 digit display. 1 PLC integration. 
# T3 Single Trigger. This causes a single measurement to commence. Further readings
# may be initiated by an HP-IB GET command, but not an external trigger pulse. 

CMD_TELNET = '\xff\n' # configures multimeter to accept telnet text commands
CMD_ADDR = '++addr       17\n' # XXX don't really know what this does
CMD_TRIGGER = 'N4T3\n' # N4 Selects 4 1/2 digit display.  T3 Single Trigger.

class HP_Multimeter:
    '''Client for reading from the HP 3478A Multimeter used to integrate
    baseband voltages in the UGRadio Interferometer.  Sends commands over
    the network to a microcontroller that translates commands to the GPIB
    bus on the back of the multimeter.'''
    def __init__(self, host=HOST, port=PORT):
        self.hostport = (host,port)
        self.clear_buffers()
    def clear_buffers(self):
        self._volts = []
        self._times = []
        self._running = False
        self._thread = None
    def read_voltage(self, bufsize=1024, return_time=False):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(self.hostport)
        s.sendall(CMD_TELNET + CMD_ADDR + CMD_TRIGGER)
        t = time.time()
        resp = s.recv(bufsize)
        s.close()
        if return_time:
            return float(resp), t
        else:
            return float(resp)
    def start_recording(self, dt=10.):
        self.clear_buffers()
        self._running = True
        def read_thread():
            while self._running:
                v,t = self.read_voltage(return_time=True)
                self._volts.append(v)
                self._time.append(t)
                time.sleep(dt - (time.time() - t)) # sleep remainder of time 
        self._thread = threading.Thread(target=read_thread)
        self._thread.daemon = True
        self.thread.start()
    def end_recording(self):
        assert(self._thread != None) # Can't end a recording that was never started
        self._running = False # initiate shutdown
        self._thread.join() # wait for thread to exit
        return self.get_recording_data()
    def get_recording_data(self):
        return np.array(self._volts), np.array(self._times)
    def get_recording_status(self):
        d = {'still recording':False, 'start time':None, 'last reading':None, 'last time':None}
        d['recording initiated'] = (self._thread != None)
        try:
            d['still recording'] = self._thread.is_alive()
        except(AttributeError): pass
        d['number of records'] = len(self._times)
        try:
            d['start time'] = self._times[0]
            d['last reading'] = self._volts[-1]
            d['last time'] = self._times[-1]
        except(IndexError): pass
        return d
        
