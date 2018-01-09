import socket, thread, numpy as np

VOLT_RANGE = ['50mV', '100mV', '200mV', '500mV',
    '1V', '2V', '5V', '10V', '20V']
HOST, PORT = '10.32.92.95', 1340

def read_socket(volt_range, divisor=2, dual_mode=False, 
        nsamples=16000, nblocks=5, host=HOST, port=PORT):
    '''
    Read data from picosampler via socket interface provided
    by picoserver.py in the PicoPy repository.
    Arguments:
        volt_range: (type string)
            Choose from options in the variable VOLT_RANGE
        divisor: (type int)
            Divide the 62.5 MHz sample clock by this number for sampling.
        dual_mode: (type bool)
            Sample from A and B ports if True.  Otherwise, only port A.
        nsamples: (type int)
            The number of samples acquired per block.
        nblocks: (type int)
            The number of blocks (each with nsample data points) to acquire.
        host: (type str)
            IP address of picoserver.py host.
        port: (type int)
            Port number picoserver.py is listening to.
    Returns:
        numpy array (dtype int16) of all data.
    '''
    assert(volt_range in VOLT_RANGE)
    assert(nblocks >= 1 and nblocks < 100)
    cmd = '1 %d %s %d %d %d' % (dual_mode, volt_range, divisor, nsamples, nblocks)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    print [cmd]
    s.sendall(cmd)
    data = ''
    while True:
        d = s.recv(1024)
        if not d: break
        data += d
    s.close()
    print len(data)
    return np.fromstring(data, dtype=np.int16)

# Below here is server-side code

def picoserver(host='', port=PORT)
    import picopy # Must be installed on computer hosting picosampler
    sampler = picopy.Pico2k()
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((host, port)) # Errors if binding failed (port in use)
    s.listen(10) # Start listening to socket
    #now keep talking with the client
    while True:
        conn, addr = s.accept() #wait to accept a connection - blocking call
        print 'Request from ' + addr[0] + ':' + str(addr[1])
        #start new thread takes 1st argument as a function name to be run, second is the tuple of arguments to the function.
        thread.start_new_thread(sample_pico,(conn,))
    s.close()

def sample_pico(conn):
    cmd = conn.recv(1024).split()
    if not cmd: return
    print 'Received command:', [cmd]
       if not cmd:
        return
    enableChanA = bool(int(cmd[0]))
    enableChanB = bool(int(cmd[1]))
    voltRange = cmd[2]
    sampInterval = int(cmd[3])
    nSample = int(cmd[4])
    nBlocks = int(cmd[5])
    #sampFreq = 
    sampler.configure_channel('A', enable=1, channel_type='AC', voltage_range=voltRange)
    time.sleep(0.25) # Let the configuration command make the change it needs
    sampler.configure_channel('B', enable=1, channel_type='AC', voltage_range=voltRange)
    time.sleep(0.25) # Let the configuration command make the change it needs

    sampData = sampler.capture_block2(sampInterval,nSample,return_scaled_array=False)

    for idx in range(1,nBlocks):
        blockData = sampler.capture_block2(sampInterval,nSample,return_scaled_array=False)
        for channel in sampData:
            sampData[channel] = np.concatenate([sampData[channel],blockData[channel]])
    fullData = []
    if enableChanA:
        fullData = np.concatenate([fullData,sampData['A']])
    if enableChanB:
        fullData = np.concatenate([fullData,sampData['B']])
    data = fullData.astype(np.int16).tostring()
    conn.sendall(data)
    #timeStamp = calendar.timegm(time.gmtime())
    #fileName = str(timeStamp) + '-' + voltRange + '-' + str(sampInterval) + 'sInt'  + '-' + str(nBlocks) + 'nSpec'  + '-' + str(enableChanA + enableChanB) + 'chan.int16.bin'

    #conn.sendall('/home' + dataDir + fileName)
    #fullData.astype('int16').tofile(dataDir + fileName,sep="")
    #came out of loop
    conn.close()

 

