'''Module for interacting with the HP 3478A Multimeter used to record
integrated voltages at the output of the UGRadio interferometer.'''

import socket, time, threading
import numpy as np

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
        self._clear_buffers()
    def _clear_buffers(self):
        '''Re-initialize recording buffers.  Not for outside use.'''
        self._volts = []
        self._times = []
        self._running = False
        self._thread = None
        self._start_time = None
        self._errors = 0
    def read_voltage(self, bufsize=1024, return_time=False):
        '''Take a one-time reading from the multimeter.

        Parameters
        ----------
        bufsize     : integer, size of receiving buffer in bytes, default 1024
        return_time : bool, return unix time when read occurs, default False

        Returns
        -------
        volts[, time]
        volts       : float, voltage reading from multimeter
        time        : float, unix time when read occurs, if return_time=True'''
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(self.hostport)
        s.sendall(CMD_TELNET + CMD_ADDR + CMD_TRIGGER)
        t = time.time()
        resp = s.recv(bufsize)
        s.close()
        try: 
            resp = float(resp)
        except(ValueError):
            raise ValueError('Error reading multimeter: float("%s") failed.' % resp)
        if return_time:
            return resp, t
        else:
            return resp
    def _read_thread(self):
        '''Used by start_recording to acquire data.  Not for end use.'''
        while self._running:
            for i in xrange(tries):
                try:
                    v,t = self.read_voltage(return_time=True)
                    break
                except(ValueError): # this happens when read_voltage gets an invalid response
                    self._errors += 1
                    if i == tries - 1: # we've exhausted our last try
                        raise RuntimeError('HP Multimeter recording failed after %d tries.' % tries)
                    time.sleep(.75*float(dt)/tries) # sleep as long we can before reading again
            self._volts.append(v)
            self._times.append(t)
            time.sleep(dt - ((time.time() - self._start_time) % dt)) # sleep remainder of time 
    def start_recording(self, dt, tries=10):
        '''Initiate continuous reading from multimeter every dt seconds.

        Parameters
        ----------
        dt : float seconds, time between voltage readings.

        Returns
        -------
        None'''
        self._clear_buffers()
        self._running = True
        self._thread = threading.Thread(target=self._read_thread)
        self._thread.daemon = True
        self._start_time = time.time()
        self._thread.start()
    def end_recording(self):
        '''Terminate continuous reading from multimeter and return recording.
        May take up to dt seconds (as set in start_recording call) to complete
        final read.

        Parameters
        ----------
        None

        Returns
        -------
        volts : numpy array, voltages read during recording.
        times : numpy array, times corresponding to each voltage reading.'''
        assert(self._thread != None) # Can't end a recording that was never started
        self._running = False # initiate shutdown
        self._thread.join() # wait for thread to exit
        return self.get_recording_data()
    def get_recording_data(self):
        '''Return all data that has been recorded so far.

        Parameters
        ----------
        None

        Returns
        -------
        volts : numpy array, voltages read during recording.
        times : numpy array, times corresponding to each voltage reading.'''
        return np.array(self._volts), np.array(self._times)
    def get_recording_status(self):
        '''Query current status of recording.

        Parameters
        ----------
        None

        Returns
        -------
        d : dict, status report on recording progress.'''
        d = {'still recording':False, 'start time':None, 'last reading':None, 'last time':None}
        d['recording initiated'] = (self._thread != None)
        try:
            d['still recording'] = self._thread.is_alive()
        except(AttributeError): pass
        d['number of records'] = len(self._times)
        d['number of errors'] = self._errors
        try:
            d['start time'] = self._start_time
            d['last reading'] = self._volts[-1]
            d['last time'] = self._times[-1]
        except(IndexError): pass
        return d
        
