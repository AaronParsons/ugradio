;+
; NAME: 
;       totSpec
;
; PURPOSE:
;       wrapper for readSpec which will sum multiple log files,
;	creating one total spectrum for the pointing
;
; CALLING SEQUENCE:
;       tot = totSpec(filePrefix)
;
; INPUTS:
;       filePrefix - part of the filename which stays constant
;
; EXAMPLE:
;
;
; MODIFICATION HISTORY:
;       Written on 20 May 2009 by James McBride
;
;-

function totSpec, filePrefix

files = file_search(filePrefix + '*.log')
numFiles = n_elements(files)

; get spectrum size
spec = readspec(files[0])
specSize = size(spec, /dim)
numChan = specSize[1]

totSpec = fltarr(numChan)

for i = 0, numFiles - 1  do begin

    spec = readspec(files[i])
    totSpec = totSpec + total(spec, 2)

endfor

return, totSpec
end

