'''This is a module for interacting with the picosampler in the UC Berkeley
Undergraduate Radio Lab.'''

from __future__ import print_function
try: import thread
except(ImportError): import _thread as thread
import socket, time, struct
import numpy as np

VOLT_RANGE = ['50mV', '100mV', '200mV', '500mV',
    '1V', '2V', '5V', '10V', '20V']
HOST, PORT = '10.32.92.95', 1340

def capture_data(volt_range, divisor=2, dual_mode=False, 
        nsamples=16000, nblocks=1, host=HOST, port=PORT, verbose=False):
    '''
    Read data from picosampler via socket interface provided
    by picoserver.py in the PicoPy repository.
    Arguments:
        volt_range: (type string)
            Choose from options in the variable VOLT_RANGE
        divisor: (type int)
            Divide the 62.5 MHz sample clock by this number for sampling.
        dual_mode: (type bool)
            Sample A and B inputs, rather than just A. Default False.
        nsamples: (type int)
            The number of samples acquired per block.
        nblocks: (type int)
            The number of blocks (each with nsample data points) to acquire.
        host: (type str)
            IP address of picoserver.py host.
        port: (type int)
            Port number picoserver.py is listening to.
    Returns:
        numpy array (dtype int16) with dimensons (inputs,nblocks,nsamples)
    '''
    assert(volt_range in VOLT_RANGE)
    assert(nblocks >= 1 and nblocks <= 1000)
    cmd = b'1 %d %s %d %d %d' % (dual_mode,
                                 bytes(volt_range, encoding='utf8'),
                                 divisor,
                                 nsamples,
                                 nblocks)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    s.sendall(cmd)
    datalen = s.recv(struct.calcsize('L'))
    datalen = struct.unpack('L', datalen)[0]
    data = b''
    while len(data) < datalen:
        d = s.recv(1024)
        if not d:
            break
        data += d
    s.close()
    if verbose:
        print('Received %d bytes (%d samples)' % (len(data), len(data)/2))
    data = np.fromstring(data, dtype=np.int16)
    data.shape = (-1, nblocks, nsamples)
    return data

# Below here is server-side code

def picoserver(host='', port=PORT, verbose=False):
    '''Serve up interface to PicoSampler on TCP Socket interface 
    at the specified port.
    Arguments:
        host: (type str)
            IP address of picoserver.py host.
        port: (type int)
            Port number picoserver.py is listening to.
        verbose:
    Returns:
        None
    '''
    import picopy # Must be installed on computer hosting picosampler
    sampler = picopy.Pico2k()
    def handle_request(conn):
        '''Function run to handle each connection.'''
        cmd = conn.recv(1024).split()
        if not cmd:
            return
        if verbose:
            print('Received command:', [cmd])
        usechanA = bool(int(cmd[0]))
        usechanB = bool(int(cmd[1]))
        volt_range = cmd[2]
        sample_interval = int(cmd[3])
        nsamples = int(cmd[4])
        nblocks = int(cmd[5])
        data = sample_pico(sampler, volt_range, sample_interval, 
                           nsamples, nblocks, usechanA, usechanB)
        if verbose:
            print('Sending', data.shape)
        data = data.tostring()
        header = struct.pack('L',len(data))
        conn.sendall(header+data)
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind((host, port)) # Errors if binding failed (port in use)
        s.listen(10) # Start listening to socket, timeout 10 seconds
        # now keep talking with the client
        while True:
            conn, addr = s.accept() #wait for connection, blocking call
            if verbose:
                print('Request from ' + addr[0] + ':' + str(addr[1]))
            # start handle_request function with connection handle
            # as argument.
            thread.start_new_thread(handle_request,(conn,))
    finally:
        s.close()

def sample_pico(sampler, volt_range, sample_interval, nsamples, 
          nblocks, usechanA, usechanB):
    '''
    Configure a picosampler interface and acquire data.
    Arguments:
        sampler: (Pico2k instance)
            An interface to a picosampler provided by the picopy module.
        volt_range: (type string)
            Choose from options in the variable VOLT_RANGE
        sample_interval: (type int)
            Divide the 62.5 MHz sample clock by this number for sampling.
        nsamples: (type int)
            The number of samples acquired per block.
        nblocks: (type int)
            The number of blocks (each with nsample data points) to acquire.
        usechanA: (type bool)
            Sample from A port if True.  
        usechanB: (type bool)
            Sample from B port if True.  
    Returns:
        numpy array (dtype int16) of all data.
    '''
    sampler.configure_channel('A', enable=1, channel_type='AC', voltage_range=volt_range)
    time.sleep(0.25) # Let the configuration command make the change it needs
    sampler.configure_channel('B', enable=1, channel_type='AC', voltage_range=volt_range)
    time.sleep(0.25) # Let the configuration command make the change it needs

    sampData = sampler.capture_block2(sample_interval,nsamples,return_scaled_array=False)

    for idx in range(1,nblocks):
        blockData = sampler.capture_block2(sample_interval,nsamples,return_scaled_array=False)
        for channel in sampData:
            sampData[channel] = np.concatenate([sampData[channel],blockData[channel]])
    fullData = []
    if usechanA:
        fullData = np.concatenate([fullData,sampData['A']])
    if usechanB:
        fullData = np.concatenate([fullData,sampData['B']])
    data = fullData.astype(np.int16)
    return data

read_socket = capture_data
