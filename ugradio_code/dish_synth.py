'''This module provides the operational interface to the Leuschner dish used in Lab 4.'''
import socket, time, math
import dish_pointing as pointing

IP_ADDR = '128.32.197.194' # IP Address of the NETEON serial to ethernet adapter
PORT = 1234 # PORT for getting to the HP synthesizer
MAXLEN = 4096

class Synth:
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
    def set_freq(self, freq):
        '''Interface to setting the dish LO.'''
        if self.verbose:
            print 'Setting frequency to %f MHz' % freq
        self._tx('freq %f mhz' % freq)
    def set_amp(self, amp):
        if self.verbose:
            print 'Setting amplitude to %f dBm' % (amp)
        self._tx('ampl %f dbm' % amp)
    def _tx(self, arg):
        time.sleep(1)
        self.sock.send(arg + '\r\n')
