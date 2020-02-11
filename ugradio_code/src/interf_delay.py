'''A module providing control access to the UGRadio Interferometer
delay lines.  These delay lines can be used to remove the geometric
delay between the signals entering two antennas, enable a wider
simultaneous bandwidth to be used for better sensitivity.'''

from __future__ import print_function
import socket

try:
    import thread
except ImportError as error:
    import _thread


PORT = 1421
HOST = '10.32.92.121'    # Raspberry Pi connected to delay line control
MAX_DELAY = 64.8 # calibrated 3/21/19 by Frank Latora and Aaron Parsons

def encode_delay(time_ns, N=8):
    '''Convert a desired delay in nanoseconds into a relay configuration.

    Parameters
    ----------
    time_ns : float nanoseconds, the time delay to implement
    N       : default 8, optional, the number of switches in the delay line

    Returns
    -------
    relay_config : a string of 0's and 1's encoding the relay configuration
    delay_rnd    : float nanoseconds, the time delay actually encoded'''
    assert(-MAX_DELAY <= time_ns <= MAX_DELAY)
    # Conversion Explanation:
    # the number of bits are 128 (2 to the power of 7)
    # Range is +-32 nano seconds = 64 nano seconds total
    # bits/ns = 64/128 = 0.5ns/bit
    # number of bits = delay_total/0.5
    # The delay value is referenced to +32ns delay
    # After the number of bits have been calculated, convert the decimal number of bits into a
    # a binary number.  Take the seven bit binary number and using a shift
    # register function, shift all seven bits to the left.  Then, Xor the original 7 bit binary number to the
    # new 8 bit binary number (8 bits produced by the left shift register function)
    # The 8 bit Xor result will be applied to the individual relay circuits.
    dt = MAX_DELAY / 2**(N-2)
    delay_total = MAX_DELAY - time_ns
    dly_cnts = int(round(delay_total / dt))
    delay_rnd = MAX_DELAY - (dly_cnts * dt) # Rounded delay actually written
    c = min(dly_cnts, 2**(N-1) - 1)
    c = bin(c ^ (2 * c))[2:] # bitwise xor with left-shifted numbers
    relay_config = '0' * (N - len(c)) + c # pad out to 8 characters
    return relay_config, delay_rnd # reverse to make string indexable

def decode_delay(relay_config, N=8):
    '''Convert a relay configuration into the expected delay in nanoseconds.

    Parameters
    ----------
    relay_config : a string of 0's and 1's encoding the relay configuration
    N       : default 8, optional, the number of switches in the delay line

    Returns
    -------
    time_ns : float nanoseconds, the time delay to implement'''
    dt = MAX_DELAY / 2**(N-2)
    delay_total = MAX_DELAY - time_ns
    dly_cnts = int(round(delay_total / dt))
    dly_cnts = int(relay_config, 2)
    delay_total = dly_cnts * dt
    time_ns = MAX_DELAY - delay_total
    c = min(dly_cnts, 2**(N-1) - 1)
    c = bin(c ^ (2 * c))[2:] # bitwise xor with left-shifted numbers
    relay_config = '0' * (N - len(c)) + c # pad out to 8 characters
    return relay_config # reverse to make string indexable

class DelayClient:
    '''Interface for controlling the delay line from a lab computer.'''
    def __init__(self, host=HOST, port=PORT):
        self.hostport = (host, port)

    #def delay_ns(self, data, verbose=False):
    def _command(self, cmd, bufsize=1024, timeout=10, verbose=False):
        '''Communicate with host server and return response as string.'''
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)
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
 
    def write_relays(self, relay_config, verbose=False):
        '''Low-level interface to directly set switch states.  Not for general use.'''
        self._command(relay_config, verbose=verbose)

    def delay_ns(self, time_ns, verbose=False):
        relay_config, delay_rnd = encode_delay(time_ns)
        if verbose: print('Converted %f ns ->', relay_config)
        self._command(relay_config, verbose=verbose)
        return delay_rnd
    

SWITCH_LAYOUT = {
    0: 27, # pin 13
    1: 22, # pin 15
    2:  5, # pin 29
    3:  6, # pin 31
    4: 13, # pin 33
    5: 26, # pin 37
    6: 18, # pin 12
    7: 23, # pin 16
}

class DelayDirect:
    '''Low-level interface for controlling delay lines from a Raspberry
    Pi with a direction connection to the delay-line switches.'''
    def __init__(self, verbose=True):
        import RPi.GPIO as GPIO
        self._gpio = GPIO
        self._gpio.setmode(self._gpio.BCM)
        self._gpio.setwarnings(False)
        for sw in self.switches():
            self._gpio.setup(SWITCH_LAYOUT[sw], self._gpio.OUT)
        self.verbose = verbose

    def log(self, *args):
        if self.verbose:
            print(*args)

    def switches(self):
        return SWITCH_LAYOUT.keys()

    def write_relays(self, relay_config):
        self.log('Setting Relay Config: ', relay_config)
        assert(len(relay_config) == 8) # make sure all relay states are encoded
        assert(set(relay_config).issubset(set('01'))) # make sure only 1s or 0s are sent
        for sw in self.switches():
            self.switch_relays(sw, bool(int(relay_config[-1-sw])))

    def switch_relays(self, sw_num, state):
        gpio_index = SWITCH_LAYOUT[sw_num]
        self._gpio.output(gpio_index, state)
        self.log('<GPIO %d Switch to %s>' % (gpio_index, state))


class DelayServer(DelayDirect):
    '''A higher-level interface running on a Raspberry Pi for handling
    network requests to control the delay-line switches.'''
    def run(self, host='', port=PORT, verbose=False, timeout=10):
        self.verbose = verbose
        if self.verbose:
            self.log('Initializing delay switches..')
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
        cmd = cmd.strip()
        self.write_relays(cmd)
        resp = 'success'
        if self.verbose: print('Returning:', [resp])
        conn.sendall(resp.encode('ascii'))
