'''Module for interaction with Agilent N9310a Frequency Synthesizer.'''

import socket, thread

DEVICE = '/dev/usbtmc0' # default mounting point
HOST, PORT = '10.32.92.95', 1341

FREQ_UNIT = ['GHz','MHz','kHz']
AMP_UNIT = ['dBm','mV','uV']

class SynthBase:
    def validate(self):
        '''Make sure this is the device we think it is.'''
        self._write('*IDN?') # query ID
        resp = self._read().strip()
        resp = resp.split(',')
        assert(resp[0] == 'Agilent Technologies')
    def get_frequency(self):
        self._write(':FREQuency:CW?')
        resp = self._read()
        fq,unit,_ = resp.split()
        return float(fq), unit
    def set_frequency(self, val, unit):
        assert(unit in FREQ_UNIT)
        cmd = ':FREQuency:CW %f %s' % (val, unit)
        self._write(cmd)
    def get_amplitude(self):
        self._write(':AMPLitude:CW?')
        resp = self._read()
        amp,unit,_ = resp.split()
        return float(amp), unit
    def set_amplitude(self, val, unit):
        assert(unit in AMP_UNIT)
        cmd = ':AMPLitude:CW %f %s' % (val, unit)
        self._write(cmd)

class SynthDirect(SynthBase):
    def __init__(self, device=DEVICE):
        #SynthBase.__init__(self)
        self.dev = open(device, 'r+')
        self.validate()
    def _write(self, cmd):
        self.dev.write(cmd)
        self.dev.flush()
    def _read(self):
        return self.dev.read()

class SynthClient(SynthBase):
    def __init__(self, host=HOST, port=PORT):
        #SynthBase.__init__(self)
        self.hostport = (host,port)
    def _write(self, cmd):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect(self.hostport)
        self.sock.sendall(cmd)
        if not cmd.endswith('?'): self.sock.close()
    def _read(self):
        resp = self.sock.recv(1024)
        self.sock.close()
        return resp

class SynthServer(SynthDirect):
    def __init__(self):
        SynthDirect.__init__(self)
    def run(self, host='', port=PORT, verbose=True):
        self.verbose = verbose
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.bind((host,port)) # Errors if binding failed (port in use)
            s.listen(10)
            while True:
                conn, addr = s.accept()
                if self.verbose: print 'Request from ' + addr[0] + ':' + str(addr[1])
                thread.start_new_thread(self._handle_request, (conn,))
        finally:
            s.close()
    def _handle_request(self, conn):
        cmd = conn.recv(1024)
        if not cmd: return
        if self.verbose: print 'Received:', [cmd]
        self._write(cmd)
        if cmd.endswith('?'):
            resp = self._read()
            conn.sendall(resp)
