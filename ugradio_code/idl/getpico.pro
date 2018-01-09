pro getpico, voltrange, divisor, nsp, tseries, $
             dual=dual, fsmpl=fsmpl, vmult=vmult, $
             savefile=savefile, filename=filename, tss=tss
;+
;procedure GETPICO. run the picosampler and return the resulting time
;series
;
;CALLING SEQUENCE:
;GETPICO, voltrange, divisor, nsp, tseries, $
;             dual=dual, fsmpl=fsmpl, vmult=vmult, $
;             savefile=savefile, filename=filename
;
;INPUTS: 
;VOLTRANGE: The sampler resolution is 8+ bits (257 values)) over the
;range ~/- 2*voltrange. Thus, when the input voltage is {+/- 1 volt, you
;should set VOLTRANGE to at least '500mV'. VOLTRANGE is a string with only
;the following possible values: '50mV', '100mV', '200mV', '500mV', '1V',
;'2V', '5V', '10V', '20V'.
;
;DIVISOR: The sampling frequency is 62.5/DIVISOR MHz. DIVISOR must be an
;...INTEGER NUMBER...NOT FRACTIONAL!!
;
;NSP: The sampler always gives either 16000 or 32000 samples for each
;time series, depending on whether DUAL is set. NSP is the number of
;time series that it returns. Thus the number of sampled points is
;either NSP*16000 or NSP*32000.
;
;OUTPUTS:
;TSERIES: the sampled the series. an integer array running from -127 to
; +127. Tseries has dimensions as follows:
;       for nsp=1,   dual=0   tseries[16000]
;       for nsp>1,   dual=0   tseries[16000, nsp]
;       for nsp=1,   dual=1   tseries[16000, 2]
;       for nsp>1,   dual=1   tseries[16000, 2, nsp]
;
;KEYWORDS:
;DUAL: if set, it does dual-channel sampling. 
;
;FSMPL: the sampling frewuency in MHz, = 62.5/DIVISOR
;
;VMULT: multiply TSERIES by VMULT to get TSERIES in units of volts.
;
;SAVEFILE: if set, it saves the sampled voltages in a binary file with
;name FILENAME.
;
;FILENAME. If savefile is set, this is the filename.
;
;EXAMPLE
; ;GETPICO, '1V', 3, 4, tseries
;
;returns the time series as integers and deletes the binay file.
;-

vmult= -99.
if voltrange eq '50mV' then vmult=0.050/4096
if voltrange eq '100mV' then vmult=0.100/4096
if voltrange eq '200mV' then vmult=0.200/4096
if voltrange eq '500mV' then vmult=0.500/4096
if voltrange eq '1V' then vmult=1.000/4096
if voltrange eq '2V' then vmult=2.000/4096
if voltrange eq '5V' then vmult=5.000/4096
if voltrange eq '10V' then vmult=10.000/4096
if voltrange eq '20V' then vmult=20.000/4096
vmult=vmult*64./2.
if vmult lt 0. then begin
print
print, '*****VOLTRANGE is not allowed. Allowable values are:*****'
print, $
" '50mv', '100mV', '200mV', '500mV', '1V', '2V', '5V', '10V', '20V'"
return
endif

filename=picosampler(voltrange, divisor, nsp, dual=dual)
tseries= read_binary( filename, data_type=2)
;stop
;fix 12 bit conversion...
tss=tseries/256
fsmpl= 62.5d0/divisor

if (nsp eq 1) and (keyword_set(dual) eq 0) then $
   tseries= tss
if (nsp gt 1) and (keyword_set(dual) eq 0) then $
   tseries= reform( tss, 16000, nsp)

if (nsp eq 1) and (keyword_set(dual) eq 1) then $
   tseries= reform( tss, 16000, 2)
if (nsp gt 1) and (keyword_set(dual) eq 1) then begin
   tss= reform( tss, 16000, 2*nsp)
   tseries= intarr( 16000, 2, nsp)
   for ns=0,nsp-1 do tseries[ *, 0, ns]= tss[*, ns] 
   for ns=0,nsp-1 do tseries[ *, 1, ns]= tss[*, nsp+ ns] 
endif

if keyword_set( savefile) eq 0 then spawn, 'rm -f ' + filename

return
end
