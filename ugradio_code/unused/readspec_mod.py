import numpy as np
import pdb

def readSpec(binaryFile, header = False, fits = False, binn = False):
    '''
    NAME: 
       readSpec
    
    PURPOSE: 
       Reads in a binary data file with spectra from the Leuschner
       spectrometer, and outputs an array of spectra, with the option
       to also save the spectra to a fits file.
    
    CALLING SEQUENCE: 
       outSpec = readSpec(binaryFile)
    
    INPUTS: 
       binaryFile - filename of file with binary rawData
    
    KEYWORDS:
       fits - if set, will save a fits file with the same name as the
       input file, but with the extension '.fits' instead of '.bin'
       bin  - if set, will save the floats to a binary file with the 
       same name as the as the input, but with extension '_f.bin'
    OUTPUTS: 
       outData - array of spectra in floating point format
       header (opt) - array with header info, still in binary 
    
    DEPENDENCIES:
       removePartial, arrDelete
    
    MODIFICATION HISTORY:
       Written on 12 September 2008 by James McBride
    '''

    # check for variable input
    if len(binaryFile) == 0:
        print('Usage: spec = readSpec(binaryFile, fitsName = fitsName, header = header)')
        return 0


    # read in binary file, and then trim it down so only complete spectra
    # remain in the data file that the rest of the program will work with
    #rawData = read_binary(binaryFile)
    rawData = np.fromfile(binaryFile,dtype='u1')
    trunData = removePartial(rawData)#, header = None, badSpec = None)

    # set defaults
    bytesPerChan = long(4)
    bytesPerPack = long(1045)
    numBytesHead = long(21)
    numBytesData = long(1024)
    chanPerPack = long(256)
    packsPerSpec = long(32)

    # calculate some other defaults
    bytesPerSpec = numBytesData * packsPerSpec
    numChan = chanPerPack * packsPerSpec
    totBytes = trunData.size
    numSpec = totBytes / (bytesPerSpec)
    #print(rawData.size)
    #print(trunData.size)
    #print(bytesPerSpec)


    # find indices for locations of bytes with different values
    quarterInds = np.arange(totBytes / bytesPerChan)
    byteInds1 = quarterInds * bytesPerChan
    byteInds2 = byteInds1 + 1
    byteInds3 = byteInds1 + 2
    byteInds4 = byteInds1 + 3

    # convert byte values into long integers
    bytes1 = np.array(trunData[byteInds1])* long(2. ** 24)
    bytes2 = np.array(trunData[byteInds2])* long(2. ** 16)
    bytes3 = np.array(trunData[byteInds3])* long(2. ** 8)
    bytes4 = np.array(trunData[byteInds4])
    # calculate the actual values for each channel, and then reform
    # so that each spectrum is separate
    vals = np.array(bytes1 + bytes2 + bytes3 + bytes4)

    np.savez('file.npz', b1 = bytes1, b2 = bytes2, b3 = bytes3, b4 = bytes4, v = vals)
    outData = np.reshape(np.transpose(vals),[numChan,numSpec],order='F')

    # set first and last channels to the neighbor value
    outData[0,:] = outData[1, :]
    outData[numChan - 1, :] = outData[numChan - 2, :]


    # write to a binary file if desired
    if binn:
        filenameParts = binaryFile[0:binaryFile.index('.')]
        binName = filenameParts + '_f.bin'
        np.savetxt(binName, float(outData))

    return outData

def arrdelete(init, at0=0, len0=0, count=0, 
              empty1=False, overwrite=False):
    '''
    NAME:
       ARRDELETE
    
    AUTHOR:
       Craig B. Markwardt, NASA/GSFC Code 662, Greenbelt, MD 20770
       craigm@lheamail.gsfc.nasa.gov
    
    PURPOSE:
       Remove a portion of an existing array.
    
    CALLING SEQUENCE:
       NEWARR = ARRDELETE(INIT, [AT=POSITION,] [LENGTH=NELEM])
    
    DESCRIPTION: 
       ARRDELETE will remove or excise a portion of an existing array,
       INIT, and return it as NEWARR.  The returned array will never be
       larger than the initial array.
    
       By using the keywords AT and LENGTH, which describe the position
       and number of elements to be excised respectively, any segment of
       interest can be removed.  By default the first element is removed.
    
    INPUTS:
       INIT - the initial array, which will have a portion deleted.  Any
       data type, including structures, is allowed.  Regardless of
       the dimensions of INIT, it is treated as a one-dimensional
       array.  If OVERWRITE is not set, then INIT itself is
       unmodified.
    
    KEYWORDS:
 
       AT - a long integer indicating the position of the sub-array to be
       deleted.  If AT is non-negative, then the deleted portion
       will be NEWARR[AT:AT+LENGTH-1].  If AT is negative, then it
       represents an index counting from then *end* of INIT,
       starting at -1L.
       Default: 0L (deletion begins with first element).
       
       LENGTH - a long integer indicating the number of elements to be
       removed.  
       
       OVERWRITE - if set, then INIT will be overwritten in the process of
       generating the new array.  Upon return, INIT will be
       undefined.
       
       COUNT - upon return, the number of elements in the resulting array.
       If all of INIT would have been deleted, then -1L is
       returned and COUNT is set to zero.
    
       EMPTY1 - if set, then INIT is assumed to be empty (i.e., to have
       zero elements).  The actual value passed as INIT is
       ignored.
       
    RETURNS:
    
       The new array, which is always one-dimensional.  If COUNT is zero,
       then the scalar -1L is returned.
    
    SEE ALSO:
       STORE_ARRAY in IDL Astronomy Library
    
    MODIFICATION HISTORY:
       Written, CM, 02 Mar 2000
       Added OVERWRITE and EMPTY1 keyword, CM 04 Mar 2000
    
       $Id: arrdelete.pro,v 1.2 2001/03/25 18:10:41 craigm Exp $
    

    Copyright (C) 2000, Craig Markwardt
    This software is provided as is without any warranty whatsoever.
    Permission to use, copy, modify, and distribute modified or
    unmodified copies is granted, provided this copyright and disclaimer
    are included unchanged.
    '''

    n1 = len(init)  ;  sz1 = init.shape  ;  tp1 = init.dtype
    count = n1
    if count == 0 or empty1: return -1
    
    if not at0: 
        at  = 0L 
    else:
        at  = long(at0)

    if not len0:
        lenn = 1L
    else:
        lenn = long(len0)

    if at < 0: at = (n1 + long(1) + at) > 0
    at = (at > 0) < n1
    
    if at + lenn > count: lenn = (count - at) > 0
    if lenn <= 0: return init
    count = n1 - lenn
    if lenn >= n1: return -1
    
    if overwrite:
    #Conserve memory as much as possible
    
        if at == 0: return init[lenn:]
        if at == n1-lenn: return init[0:n1-lenn]
        if at < n1/2:        # Minimize the memory copying
            init[lenn] = init[0:at]
            return init[lenn:]
        else:
            init[at] = init[at+lenn:]
            return init[0:count]

    ## Normal memory-hoggy part of the routine
    out = np.empty(count, dtype=tp1)
        
    if at > 0:      out[0:at-1]  = init[0:at-1]
    if at+lenn < n1: out[at:at+(n1-at-lenn)] = init[at+lenn:]

    return out





def removePartial(rawData, header = False, badSpec = False):
    '''
    NAME: 
       removePartial
    PURPOSE: 
       eliminate spectra which are incomplete due to a missing pack
       or the observation starting or ending during recording of a pack
    CALLING SEQUENCE:
       trunData = removePartial(rawData)
    INPUTS: 
       rawData - an array with raw binary data from the Leuschner spectrometer
    OUTPUTS:
       trunData - a trimmed version of rawData, with incomplete or unfinished
                  spectra removed
       header (opt) - array with header information 
       badSpec (opt) - spectrum number of spectra with dropped packets
    DEPENDENCIES: arrdelete
    MODIFICATION HISTORY: 
       Written on 11 September 2008 by James McBride
    '''

    # calculate the total number of spectra based on the length of the file
    # the reason for subtracting two spectra is that the first and last spectra
    # are thrown away in case they are incomplete
    totBytes = len(rawData)
    byteInds = np.arange(totBytes,dtype = long)
    bytesPerPack = long(1045)
    chanPerPack = 256
    packsPerSpec = 32
    numBytesHead = 21
    numBytesData = long(1024)
    numPacks = totBytes / bytesPerPack
    bytesPerSpec = packsPerSpec * bytesPerPack

    # calculate vector numbers to be used for finding out where the first 
    # spectrum starts, as well as checking for any dropped packets
    #vecNums = np.zeros(numPacks)
    vecInds1 = np.where(byteInds % bytesPerPack == 9)[0]
    vecInds2 = np.where(byteInds % bytesPerPack == 10)[0]
    vecInds3 = np.where(byteInds % bytesPerPack == 11)[0]
    vecInds4 = np.where(byteInds % bytesPerPack == 12)[0]

    # find where first spectrum starts
    rd1 = np.array([rawData[i] for i in vecInds1])
    rd2 = np.array([rawData[i] for i in vecInds2])
    rd3 = np.array([rawData[i] for i in vecInds3])
    rd4 = np.array([rawData[i] for i in vecInds4])
    vecNums = (rd1* 2**long(24)) + (rd2 * 2**long(16)) + (rd3 * 2**long(8)) + rd4
    firstPack = np.where(vecNums % packsPerSpec == 0)[0]
    #print, 'First pack at:', min(firstPack) * bytesPerPack
    #print, 'Spec length:', bytesPerSpec
    firstSpec = np.min(firstPack)
    lastSpec = np.max(firstPack)
    firstByte = bytesPerPack * firstSpec
    lastByte = bytesPerPack * lastSpec - 1
    
    # perform first possible snip
    #byteInds = arrdelete(byteInds, at0 = lastByte + 1, len0 = totBytes - lastByte + 1, overwrite=True)
    #byteInds = arrdelete(byteInds, at0 = 0, len0 = firstByte, overwrite=True)
    trunData = np.array(rawData[firstByte: lastByte + 1])
    totBytes = trunData.size
    #print(len(firstPack))
    # look for dropped packets
    maxNumSpec = len(firstPack) - 2
    packsInSpec = np.zeros(maxNumSpec)

    # mark positions of bad spectra
    badSpec = np.zeros(maxNumSpec)
    #pdb.set_trace()
    for i in range(maxNumSpec):
        # essentially a true or false test
        missingPack = (firstPack[i + 1] - firstPack[i]) % packsPerSpec 
        if missingPack != 0:
            # delete any spectra missing packs, as necessary
            numMissingPacks = packsPerSpec - missingPack
            lenToDel = bytesPerSpec - (numMissingPacks * bytesPerPack) 
            trunData = arrdelete(trunData, at0 = (i * bytesPerSpec), len0 = lenToDel)
            #byteInds = arrdelete(trunData, at0 = (i * bytesPerSpec), len0 = lenToDel)
            badSpec[i] = 1
            #print numMissingPacks
            
    # taking only the true instances of bad spectra
    if np.where(badSpec == 1) >= 1: badSpec = badSpec[np.where(badSpec == 1)]

    # generate new variables with array information, which may have now changed
    totBytes = len(trunData)
    byteInds = np.arange(totBytes,dtype = long)
    numPacks = totBytes / bytesPerPack
    numSpec = totBytes / bytesPerSpec
    
    # strip header
    headerInds = np.tile(np.arange(numBytesHead,dtype=long), [numPacks,1])
    #temp_arr = np.empty((1,numPacks))
    #temp_arr[0] = np.arange(numPacks)
    #temp_arr.shape
    indMultipliers = np.transpose(np.tile(np.arange(numPacks), [numBytesHead,1]))
    headerInds = np.reshape(headerInds+(indMultipliers*bytesPerPack),numPacks*numBytesHead)
    headerMask = np.zeros(trunData.size)
    headerMask[headerInds] = 1
    header = trunData[np.where(headerMask != 0)]
    header = np.transpose(header)
    
    #remove header indices from the data array
    #dataInds = setDifference(byteInds, headerInds)
    trunData = trunData[np.where(headerMask != 1)]

    return trunData



    
    
    
