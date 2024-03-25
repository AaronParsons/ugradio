'''Module for interaction with Agilent N9310a Frequency Synthesizer.'''

import socket
import time
try: import thread
except(ImportError): import _thread as thread

DEVICE = '/dev/usbtmc0' # default mounting point
HOST, PORT = '192.168.1.90', 1341
WAIT = 0.3 # s

FREQ_UNIT = ['GHz','MHz','kHz']
AMP_UNIT = ['dBm','mV','uV']

class SynthBase:
    '''This base class is not intended to be instantiated by itself.
    Its attributes are inherited by SynthDirect, SynthServer, and SynthClient.'''
    def validate(self):
        '''Make sure this is the device we think it is.'''
        self._write(b'*IDN?') # query ID
        resp = self._read().strip()
        resp = resp.split(b',')
        assert(resp[0] == b'Agilent Technologies')
    def get_frequency(self):
        '''Get the current frequency setting for the CW (continuous wave) output
        mode of the synthesizer.

        Returns
        -------
        fq   : float, numerical frequency setting
        unit : string, units of fq (GHz, MHz, or kHz)'''
        self._write(b':FREQuency:CW?')
        resp = self._read()
        fq,unit,_ = resp.split()
        return float(fq), unit.decode('utf-8')
    def set_frequency(self, val, unit):
        '''Set the frequency of the CW (continuous wave) output
        mode of the synthesizer.

        Parameters
        ----------
        val  : float, numerical frequency setting
        unit : string, units of val ('GHz','MHz', or 'kHz')

        Returns
        -------
        None'''
        assert(unit in FREQ_UNIT)
        unit = bytes(unit, encoding='utf-8')
        cmd = b':FREQuency:CW %f %s' % (val, unit)
        self._write(cmd)
    def get_amplitude(self):
        '''Get the current amplitude setting for the CW (continuous wave) output
        mode of the synthesizer.

        Returns
        -------
        amp  : float, numerical amplitude setting
        unit : string, units of amp (dBm, mV, or uV)'''
        self._write(b':AMPLitude:CW?')
        resp = self._read()
        amp,unit,_ = resp.split()
        return float(amp), unit.decode('utf-8')
    def set_amplitude(self, val, unit):
        '''Set the amplitude of the CW (continuous wave) output
        mode of the synthesizer.

        Parameters
        ----------
        val  : float, numerical amplitude setting
        unit : string, units of val ('dBm','mV', or 'uV')

        Returns
        -------
        None'''
        assert(unit in AMP_UNIT)
        unit = bytes(unit, encoding='utf-8')
        cmd = b':AMPLitude:CW %f %s' % (val, unit)
        self._write(cmd)
    def get_RFout_status(self):
        '''Get the RFout status of the synthesizer. 
        
        Parameters
        ----------
        None

        Returns
        -------
        A '1' if the RFout is on; a '0' if the RFout is off.'''
        self._write(':RFOutput:STATe?')
        status = self._read()[0] # read first bit
        if status == '1': return 1
        elif status == '0': return 0
    def RFout_on(self):
        '''Turn RFout on.'''
        self._write(':RFOutput:STATe ON')
    def RFout_off(self):
        '''Turn RFout off.'''
        self._write(':RFOutput:STATe OFF')

class SynthDirect(SynthBase):
    '''Implements a direct connection to the synthesizer via a
    USB connection (typically device='/dev/usbtmc0' or similar).'''
    def __init__(self, device=DEVICE):
        '''Parameters
        ----------
        device : string, the file-like object representing the USB connection.
                 default="/dev/usbtmc0"'''
        self._device = device
        self._open_device()
    def _open_device(self):
        '''Open low-level device interface.  Not intended direct use.'''
        try:
            self.dev.close()
        except(AttributeError):
            pass
        self.dev = open(self._device, 'rb+')
        self.validate()
    def _write(self, cmd):
        '''Low-level writing interface to device.  Not intended direct use.'''
        if type(cmd) is str:
            cmd = bytes(cmd, encoding='utf-8')
        self.dev.write(cmd)
        self.dev.flush()
        time.sleep(WAIT) # slow down writing to avoid spam attacks
    def _read(self):
        '''Low-level reading interface to device.  Not intended direct use.'''
        rv = []
        while True:
            try:
                rv.append(self.dev.read(1))
            except(TimeoutError):
                break
        rv = b''.join(rv)
        return rv

class SynthClient(SynthBase):
    '''Implements a network connection to a synthesizer which is being hosted
    on another computer.'''
    def __init__(self, host=HOST, port=PORT):
        '''Parameters
        ----------
        host : string, the IP address or network resolvable name of the
               computer hosting the synthesizer (which runs SynthServer)
               default=10.32.92.95
        port : int, the port over which the synthesizer is being hosted.
               default=1341'''
        self.hostport = (host,port)
    def _write(self, cmd):
        '''Low-level writing interface to device.  Not intended direct use.'''
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.settimeout(10) # seconds
        self.sock.connect(self.hostport)
        if type(cmd) is str:
            cmd = bytes(cmd, encoding='utf-8')
        self.sock.sendall(cmd)
        if not cmd.endswith(b'?'): self.sock.close()
    def _read(self):
        '''Low-level reading interface to device.  Not intended direct use.'''
        resp = self.sock.recv(1024)
        self.sock.close()
        return resp

class SynthServer(SynthDirect):
    '''Host a direct connection to a synthesizer over the network so that
    SynthClients can connect to it.'''
    def __init__(self):
        SynthDirect.__init__(self)
        self._device_failure = False
    def run(self, host='', port=PORT, verbose=True):
        '''Start hosting the synthesier at the specified port.
        Parameters
        ----------
        host    : string, the IP address or network resolvable name of the
                  for hosting the synthesizer. default=''
        port    : int, the port over which the synthesizer is being hosted.
                  default=1341
        verbose : bool, print lots of things about connections and such.'''
        self.verbose = verbose
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.bind((host,port)) # Errors if binding failed (port in use)
            s.listen(10)
            while True:
                conn, addr = s.accept()
                if self.verbose:
                    print('Request from ' + addr[0] + ':' + str(addr[1]))
                if self._device_failure:
                    self._open_device()
                    self._device_failure = False
                thread.start_new_thread(self._handle_request, (conn,))
        finally:
            s.close()
    def _handle_request(self, conn):
        '''Private thread for handling an individual connection.  Will execute
        at most one write and one read before terminating connection.'''
        cmd = conn.recv(1024)
        if not cmd: return
        if self.verbose:
            print('Received:', [cmd])
        try:
            self._write(cmd)
        except(IOError):
            self._device_failure = True
            return
        if cmd.endswith(b'?'):
            resp = self._read()
            conn.sendall(resp)
