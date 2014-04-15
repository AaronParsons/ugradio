import os

def takeSpec(filename, numFiles = 1, numSpec = 78125):
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

    #check for variable input
    if filename == "":
        print("Default filename 'filename0.log' will be used")

    #set call to start data stream
    path = '/home/radiolab/spec_code/bin/'
    cdCmd = 'cd ' + path + ';'
    recCall = './udprec'

    # figure out (inelegantly) where to save the current files
    # (don't worry too much about this, unless it ceases working)
    codePath = '/home/radiolab/idl_spec_code/'
    newPath = '/home/radiolab/spec_data/uglab' #default

    os.system('pwd > ' + codePath + 'pwd.txt')
    fil = open(codePath + 'pwd.txt','r')
    newPath = fil.read()
    newPath = newPath.replace('\n','')
    fil.close()

    # generate and call the command to udprec
    arg = ''
    arg += ' -p ' + newPath + '/' + str(filename)
    if numFiles > 1: arg += ' -i ' + str(numFiles)
    if numSpec > 0: 
        arg += ' -n ' + str(numSpec) 
    else: arg += ' -n 40'
         
    # collecting the spectra
    os.system(cdCmd + recCall + arg)
