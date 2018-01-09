function sampler, nsamples, freq,  dual=dual, integer=integer, lo=lo
;+
;  NAME:     sampler
;
;  PURPOSE:  Get data from the sampler in Pulsar
;  
;  SYNTAX:   v=sampler(nsamples, freq, /dual, /integer, /lo)
;
;  EXAMPLE:  To get a 1-D array of 1024 voltages sampled at 1 MHz
;            volts=sampler(1024, 1e6)
;
;            To get a 2-D array of 512 voltages sampled at 10 MHz
;            v=sampler(512, 10e6, /dual)
; 
;  INPUTS:   nsamples = (number of samples)
;            freq = (sampling frequency in Hz)
;
;  OPTIONAL INPUTS:  dual - set this keyword to read input on
;                           channel 0 AND channel 1, otherwise
;                           channel 2 is read as the input
;                    integer - set this keyword to store the
;                              voltages as integers
;                    lo - set this keyword for small inputs
;                         (-1 < V < +1)
;
;  OUTPUTS:  1-D array of voltages
;            2-D array of voltages if dual keyword is used
;            -1 if error occurs
;            
;  LIMITATIONS:  The total voltage, including offset, 
;                cannot exceed +/- 5V
;                0 < freq < 20 MHz for single channel
;                0 < freq < 10 MHz for dual channel
;-

  fname_txt='/home/global/ay121/idl/pc/data/data.txt'

  if keyword_set(dual) then begin
    channel_str='dual'
    v=fltarr(2,nsamples)
    if freq gt 10e6 then begin
        freq = 10e6  ;set frequency to max frequency, 10 MHz
        print, 'ERROR: Maximum sampling frequency in dual mode is 10 MHz'
        return, -1
    endif
    if nsamples gt 262144 then begin
        nsamples = 262144  
        print, 'ERROR: Maximum number of samples is 262144'
        return, -1
    endif
  endif else begin
    channel_str='chan=2';assume single channel
    v=fltarr(nsamples)
    if freq gt 20e6 then begin
        freq = 20e6  ;set frequency to max frequency, 20 MHz
        print, 'ERROR: Maximum sampling frequency in single mode is 20 MHz'
        return, -1
    endif
    if nsamples gt 262144 then begin
        nsamples = 262144  
        print, 'ERROR: Maximum number of samples is 262144'
        return, -1
    endif
  endelse

  if keyword_set(integer) then channel_str = channel_str + ' integer'
  if keyword_set(lo) then channel_str = channel_str + ' lo'

  nsamples_str = strcompress(nsamples,/remove)
  freq_str = strcompress(freq,/remove)

  string_total = 'echo adc nsamples='+nsamples_str+' freq='+freq_str+' '+ channel_str +' '+ $
         'fname='+fname_txt+' | /home/global/instrument/sendpc/sendpc'
  print, string_total

  spawn, string_total, result

  if keyword_set(dual) then begin 
    readcol, fname_txt, v0, v1, /silent
    v[0,*]=v0
    v[1,*]=v1
  endif else begin
     readcol, fname_txt, v, /silent
  endelse

  return, v

end

