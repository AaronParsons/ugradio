;+
; NAME: 
;       removePartial
; PURPOSE: 
;       eliminate spectra which are incomplete due to a missing pack
;       or the observation starting or ending during recording of a pack
; CALLING SEQUENCE:
;       trunData = removePartial(rawData)
; INPUTS: 
;       rawData - an array with raw binary data from the Leuschner spectrometer
; OUTPUTS:
;       trunData - a trimmed version of rawData, with incomplete or unfinished
;                  spectra removed
;       header (opt) - array with header information 
;       badSpec (opt) - spectrum number of spectra with dropped packets
; DEPENDENCIES: arrdelete
; MODIFICATION HISTORY: 
;       Written on 11 September 2008 by James McBride
;-

function removePartial, rawData, header = header, badSpec = badSpec

; calculate the total number of spectra based on the length of the file
; the reason for subtracting two spectra is that the first and last spectra
; are thrown away in case they are incomplete
totBytes = n_elements(rawData)
byteInds = lindgen(totBytes)
bytesPerPack = 1045L
chanPerPack = 256
packsPerSpec = 32
numBytesHead = 21
numBytesData = 1024L
numPacks = totBytes / bytesPerPack
bytesPerSpec = packsPerSpec * bytesPerPack

; calculate vector numbers to be used for finding out where the first 
; spectrum starts, as well as checking for any dropped packets
vecNums = fltarr(numPacks)
vecInds1 = where(byteInds mod bytesPerPack eq 9)
vecInds2 = where(byteInds mod bytesPerPack eq 10)
vecInds3 = where(byteInds mod bytesPerPack eq 11)
vecInds4 = where(byteInds mod bytesPerPack eq 12)

; find where first spectrum starts
vecNums = (rawData[vecInds1] * 2 ^ 24L) + (rawData[vecInds2] * 2 ^ 16L) + (rawData[vecInds3] * 2 ^ 8L) + rawData[vecInds4]
firstPack = where(vecNums mod packsPerSpec eq 0)
;print, 'First pack at:', min(firstPack) * bytesPerPack
;print, 'Spec length:', bytesPerSpec
firstSpec = min(firstPack)
lastSpec = max(firstPack)
firstByte = bytesPerPack * firstSpec
lastByte = bytesPerPack * lastSpec - 1

; perform first possible snip
;byteInds = arrdelete(byteInds, at = lastByte + 1, len = totBytes - lastByte + 1, /overwrite)
;byteInds = arrdelete(byteInds, at = 0, len = firstByte, /overwrite)
trunData = rawData[firstByte: lastByte]
totBytes = n_elements(trunData)

; look for dropped packets
maxNumSpec = n_elements(firstPack) - 2
packsInSpec = fltarr(maxNumSpec)

; mark positions of bad spectra
badSpec = fltarr(maxNumSpec)

for i = 0, maxNumSpec do begin

    ; essentially a true or false test
    missingPack = (firstPack[i + 1] - firstPack[i]) mod packsPerSpec 
    if missingPack ne 0 then begin
        ; delete any spectra missing packs, as necessary
        numMissingPacks = packsPerSpec - missingPack
        lenToDel = bytesPerSpec - (numMissingPacks * bytesPerPack) 
        trunData = arrdelete(trunData, at = (i * bytesPerSpec), len = lenToDel)
;        byteInds = arrdelete(trunData, at = (i * bytesPerSpec), len = lenToDel)
        badSpec[i] = 1
        print, numMissingPacks
    endif

endfor

; taking only the true instances of bad spectra
if where(badSpec eq 1) ge 1 then badSpec = badSpec[where(badSpec eq 1)]

; generate new variables with array information, which may have now changed
totBytes = n_elements(trunData)
byteInds = lindgen(totBytes)
numPacks = totBytes / bytesPerPack
numSpec = totBytes / bytesPerSpec

; strip header
headerInds = rebin(lindgen(numBytesHead), numBytesHead, numPacks)
indMultipliers = rebin(transpose(lindgen(numPacks)), numBytesHead, numPacks) 
headerInds = headerInds + (indMultipliers * bytesPerPack)
header = trunData[headerInds]
header = transpose(header)

;remove header indices from the data array
dataInds = setDifference(byteInds, headerInds)
trunData = trunData[dataInds]

return, trunData
end

