;+
; NAME: 
;       readSpec
;
; PURPOSE: 
;       Reads in a binary data file with spectra from the Leuschner
;       spectrometer, and outputs an array of spectra, with the option
;       to also save the spectra to a fits file.
;       
; CALLING SEQUENCE: 
;       outSpec = readSpec(binaryFile)
;
; INPUTS: 
;       binaryFile - filename of file with binary rawData
;
; KEYWORDS:
;       fits - if set, will save a fits file with the same name as the
;              input file, but with the extension '.fits' instead of '.bin'
;       bin  - if set, will save the floats to a binary file with the 
;              same name as the as the input, but with extension '_f.bin'
; OUTPUTS: 
;       outData - array of spectra in floating point format
;       header (opt) - array with header info, still in binary 
;
; DEPENDENCIES:
;       removePartial, arrDelete
;
; MODIFICATION HISTORY:
;       Written on 12 September 2008 by James McBride
;-

function readSpec, binaryFile, header = header, fits = fits, bin = bin

; check for variable input
if n_elements(binaryFile) eq 0 then begin
print, 'Usage: spec = readSpec(binaryFile, fitsName = fitsName, header = header)'
return, 0
endif

; read in binary file, and then trim it down so only complete spectra
; remain in the data file that the rest of the program will work with
rawData = read_binary(binaryFile)
trunData = removePartial(rawData, header = header, badSpec = badSpec)

; set defaults
bytesPerChan = 4L
bytesPerPack = 1045L
numBytesHead = 21L
numBytesData = 1024L
chanPerPack = 256L
packsPerSpec = 32L

; calculate some other defaults
bytesPerSpec = numBytesData * packsPerSpec
numChan = chanPerPack * packsPerSpec
totBytes = n_elements(trunData)
numSpec = totBytes / (bytesPerSpec)

; find indices for locations of bytes with different values
quarterInds = lindgen(totBytes / bytesPerChan)
byteInds1 = quarterInds * bytesPerChan
byteInds2 = byteInds1 + 1
byteInds3 = byteInds1 + 2
byteInds4 = byteInds1 + 3

; convert byte values into long integers
bytes1 = trunData[byteInds1] * 2LL ^ 24
bytes2 = trunData[byteInds2] * 2LL ^ 16
bytes3 = trunData[byteInds3] * 2LL ^ 8
bytes4 = trunData[byteInds4]

; calculate the actual values for each channel, and then reform
; so that each spectrum is separate
vals = bytes1 + bytes2 + bytes3 + bytes4
outData = reform(vals, numChan, numSpec)

; set first and last channels to the neighbor value
outData[0, *] = outData[1, *]
outData[numChan - 1, *] = outData[numChan - 2, *]

; write to a fits file if desired
if keyword_set(fits) then begin
    filenameParts = strsplit(binaryFile, '.', /extract)
    fitsName = filenameParts[0] + '.fits'
    writefits, fitsName, outData
endif

; write to a binary file if desired
if keyword_set(bin) then begin
    filenameParts = strsplit(binaryFile, '.', /extract)
    binName = filenameParts[0] + '_f.bin'
    openw, lun, binName, /get_lun
    writeu, lun, float(outData)
    close, lun
endif

return, outData
end


