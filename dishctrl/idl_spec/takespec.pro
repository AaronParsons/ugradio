;+
; NAME: 
;       takeSpec
;
; PURPOSE: 
;       very simple wrapper for the basic c program used to take data
;
; CALLING SEQUENCE:
;       takeSpec, filename, numFiles=numIter, numSpec=numSpec
;
; INPUTS:
;       filename - will be used as the prefix of the filename, 
;	to precede '[numFiles].log' for all iterations
;
; OPTIONAL INPUTS: 
;       numFiles - if set, dictates the number of files to produce, 
;	with the default value being 1
;       numSpec - if set, dictates the number of spectra per file, 
;	with the default being 78125
;
; MODIFICATION HISTORY:
;       Written on 9 September 2008 by James McBride
;	Filename made a required input on 7 April 2009, JM
;-

pro takeSpec, filename, numFiles = numFiles, numSpec = numSpec

; check for variable input
if n_elements(filename) eq 0 then begin
print, 'Usage: takeSpec, filename, numFiles = numFiles, numSpec = numSpec'
return
endif

; set call to start data stream
path = '~/spec_code/bin/'
cdCmd = 'cd ' + path + ';'
recCall = './udprec'

; figure out (inelegantly) where to save the current files
; (don't worry too much about this, unless it ceases working)

codePath = '~/idl_spec_code/'
newPath = '~/spec_data/uglab'

; spawn, 'pwd', newPath
spawn, 'pwd >! ' + codePath + 'pwd.txt'
openr, inUnit, codePath + 'pwd.txt', /get_lun
readf, inUnit, newPath
free_lun, inUnit

; generate and call the command to udprec
arg = ''
arg += ' -p ' + newPath + '/' + string(filename)
if n_elements(numFiles) gt 0 then arg += ' -i ' + string(numFiles)
if n_elements(numSpec) gt 0 then arg += ' -n ' + string(numSpec) else arg += ' -n 40'

spawn, cdCmd + recCall + arg 

end
