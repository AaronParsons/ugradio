'''A module providing control access to the UGRadio Interferometer
delay lines.  These delay lines can be used to remove the geometric
delay between the signals entering two antennas, enable a wider
simultaneous bandwidth to be used for better sensitivity.'''

from __future__ import print_function
import socket, thread
import time # XXX I think this is unused.

PORT = 1421
HOST = '10.32.92.121'    # Raspberry Pi connected to delay line control
MAX_DELAY = 32
MIN_DELAY = -32

def encode_delay(time_ns):
    '''Convert a desired delay in nanoseconds into a relay configuration.

    Parameters
    ----------
    time_ns : float nanoseconds, the time delay to implement

    Returns
    -------
    relay_config : a string of 0's and 1's encoding the relay configuration'''
    assert(MIN_DELAY <= time_ns <= MAX_DELAY)
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

    time_delay = time_ns

    # Determin the sign of the delay
    if  time_delay < 0:
        sign = False
    else:
        sign = True

    if sign == True:
        delay_total = 32 - time_delay
    if sign == False:
        delay_total = abs(time_delay) +32
    number_of_bits = int(delay_total/0.5)
    if number_of_bits == 128: number_of_bits = 127
    binary_value = bin(number_of_bits)
# Remove the b character embedded with the binary work produced in the bin() function
    binary_value =  binary_value.replace('b', '0')
# process binary number to a usable relay drive configuration
#setregisters
    R0= '0' ; R1 = '0' ; R2 = '0' ; R3= '0' ; R4 = '0' ; R5 = '0' ; R6 = '0' ; R7 = '0'
    binary_num_index = (len (binary_value))
    index = 1
    if binary_num_index >= index:
        R0 = binary_value[-1]
        index = index +1
    if binary_num_index >= index:
        R1 = binary_value[-2] 
        index = index +1
    if binary_num_index >=   index:
        R2 = binary_value[-3]  
        index = index +1
    if binary_num_index >= index:
        R3 = binary_value[-4]
        index = index +1
    if binary_num_index >=  index:
        R4 = binary_value[-5]
        index = index +1
    if binary_num_index >= index:
        R5 = binary_value[-6] 
        index = index +1
    if binary_num_index >= index:
        R6 = binary_value[-7] 
        index = index +1
# Proform a left shift register function
    R7_post_shift = R6 ; R6_post_shift = R5 ; R5_post_shift = R4 ; R4_post_shift = R3
    R3_post_shift = R2 ; R2_post_shift = R1 ;R1_post_shift = R0 
    R0_post_shift = '0'

# type R0 through R7 and R0_post_shift through R7_post_shift from str to bool
#This is needed in order for the Xor function to work properly
    R0=bool(int(R0)) ; R1=bool(int(R1)) ; R2=bool(int(R2)) ; R3=bool(int(R3)) ; R4=bool(int(R4))
    R5=bool(int(R5)) ; R6=bool(int(R6)) ; R7=bool(int(R7)) 

    R0_post_shift = bool(int(R0_post_shift)) ; R1_post_shift = bool(int(R1_post_shift))
    R2_post_shift = bool(int(R2_post_shift))  ; R3_post_shift = bool(int(R3_post_shift)) 
    R4_post_shift = bool(int(R4_post_shift))  ; R5_post_shift = bool(int(R5_post_shift))  
    R6_post_shift = bool(int(R6_post_shift)) ; R7_post_shift = bool(int(R7_post_shift)) 
# Perform Xor function
    k0 = R0 ^ R0_post_shift ; k1 = R1 ^ R1_post_shift ; k2 = R2 ^ R2_post_shift 
    k3 = R3 ^ R3_post_shift ; k4 = R4 ^ R4_post_shift ; k5 = R5 ^ R5_post_shift  
    k6 = R6 ^ R6_post_shift ; k7 = R7 ^ R7_post_shift
#convert k0 through k7 from bool to int
    k0 = int(k0); k1 = int(k1); k2 = int(k2); k3 = int(k3); k4 = int(k4); 
    k5 = int(k5); k6 = int(k6); k7 = int(k7)
#convert k0 through k7 from int to string
    k0 = str(k0); k1 = str(k1); k2 = str(k2); k3 = str(k3); k4 = str(k4); 
    k5 = str(k5); k6 = str(k6); k7 = str(k7)
# concatenate k1 through k7 into a binary represented string word
    relay_config = k7 + k6 + k5 + k4 + k3 + k2 + k1 + k0
    resp = self.write_relays(relay_config)
    return relay_config

class DelayClient:
    '''Interface for controlling the delay line from a lab computer.'''
    def __init__(self, host=HOST, port=PORT):
        self.hostport = (host, port)

    def delay_ns(self, data, verbose=False):
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
            reponse.append(r)
            if len(r) < bufsize: break
        reponse = ''.join(response)
        if verbose: print('Got Response:', [response])
        return response
 
    def write_relays(self, relay_config, verbose=False):
        '''Low-level interface to directly set switch states.  Not for general use.'''
        self._command(relay_config, verbose=verbose)

    def delay_ns(self, time_ns, verbose=False):
        relay_config = encode_delay(time_ns)
        if verbose: print('Converted %f ns ->', relay_config)
        self._command(relay_config, verbose=verbose)
    

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
        assert(set(relay_config) == set('01')) # make sure only 1s or 0s are sent
        for sw in self.switches():
            self.switch_relays(sw, bool(int(relay_config[sw])))

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
        cmd = cmd.split('\n')   
        self.write_relays(cmd)
        resp = 'success'
        if self.verbose: print('Returning:', [resp])
        conn.sendall(resp.encode('ascii'))
