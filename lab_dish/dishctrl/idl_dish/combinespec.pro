pro combinespec, prefix, range

numChan = 8192
length = 999

minr = range[0]
maxr = range[1]
filenums = intarr(maxr - minr) + minr
suffix = '.log'
binarray = fltarr(8192, 999L * (maxr - minr))

for i = 0L, maxr - minr - 1 do begin

    filename = prefix + strcompress(filenums[i], /remove_all) + suffix
    binarray[*, i * 999:(i + 1) * 999L - 1] = float(readspec(filename))
    print, i

endfor

outfile = 'combinedspec.bin'

openw, lun, outfile, /get_lun
writeu, lun, binarray
close, lun

end

