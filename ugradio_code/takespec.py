import os

def takeSpec(filename, numFiles = 1, numSpec = 32):
    """
    NAME: 
    takeSpec
    
    PURPOSE: 
    very simple wrapper for the basic c program used to take data
    
    CALLING SEQUENCE:
    takeSpec, filename, numFiles=numIter, numSpec=numSpec
    
    INPUTS:
    filename - will be used as the prefix of the filename, 
    to precede '[numFiles].log' for all iterations
    
    OPTIONAL INPUTS: 
    numFiles - if set, dictates the number of files to produce, 
    with the default value being 1
    numSpec - if set, dictates the number of spectra per file, 
    with the default being 78125
    
    MODIFICATION HISTORY:
    Written on 9 September 2008 by James McBride
    Updated and translated into Python April 2014
    """

    if filename == "":
        print("Default filename 'spectra.0.log' will be used")
        filename = "spectra."

    if numFiles < 1:
        raise Exception("ERROR: Number of files cannot be less than zero!")
    
    if numSpec < 4:
        raise Exception("ERROR: Number of spectra cannot be less than 4!")

    if numSpec > 65536:
        raise Exception("ERROR: Number of spectra cannot be more than 65536!")

    #Create argument to be executed by python in the system
    cmdCall = ('/home/radiolab/spec_code/bin/udprec -p '+ str(filename)
            + ' -n ' + str(numSpec) + ' -i ' + str(numFiles))
         
    # collecting the spectra
    os.system(cmdCall)
