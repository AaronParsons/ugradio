pro samptext, nsamples, freq, filename=filename, dual=dual, lo=lo, integer=integer
;+
;  NAME:     samptext
;
;  PURPOSE:  Get data from the sampler card in Pulsar,
;            and save it to a text file
;  
;  SYNTAX:   samptext, nsamples, freq, filename='somedata.txt', /dual, /lo
;
;  EXAMPLE:  To save a text file named 'data.txt' for a single channel
;            containing a single column of 1024 voltages sampled at 1 MHz:
;            
;            samptext, 1024, 1e6
;
;
;            To save a text file named 'data2.txt' for two channels
;            containing two columns of 262144 voltages sampled at 10
;            MHz, with the voltage limited to +/- 1 Volt
;
;            samptext, 2L^18, 10e6, filename='data2.txt', /dual, /lo
; 
;  INPUTS:   *) nsamples = (number of samples)
;            *) freq = (sampling frequency in Hz)
;
;            *) if the keyword filename is not set, 'data.txt' is the default
;            *) if the keyword dual is not set, single channel is
;               assumed
;
;            *) the optional keyword "lo" meaning "low voltage"
;               should only be used if the input voltage is
;               between +/- 1V
;
;            *) the optional keyword "integer" records the 
;               voltages as integers
;
;
;  OUTPUTS:  A text file will be saved with sampled voltagges in  rows AND 
;            1 column for single channel, and two columns for dual          
;
;  LIMITATIONS:  The total voltage from ground
;                cannot exceed +/- 5V
;
;                if the optional keyword "lo" is used,
;                the voltage is limited between +/- 1V.
;
;-   

  if keyword_set(filename) then begin
    fname_txt=filename
  endif else begin
    fname_txt='data.txt'  ;assume a default filename
  endelse

  if keyword_set(dual) then begin
    channel_str='dual'
    if freq gt 10e6 then begin
        print, 'ERROR: Maximum sampling frequency in dual mode is 10 MHz'
        return
    endif
  endif else begin
    channel_str='chan=2';assume single channel
    if freq gt 20e6 then begin
        print, 'ERROR: Maximum sampling frequency in single mode is 20 MHz'
        return
    endif
  endelse

  if keyword_set(lo) then begin
    lo_text=' lo'
  endif else begin
    lo_text=''
  endelse

  if keyword_set(integer) then begin
    int_text=' integer'
  endif else begin
    int_text=''
  endelse

  nsamples_str = strcompress(nsamples,/remove)
  freq_str = strcompress(freq,/remove)

  string_total = 'echo adc nsamples='+nsamples_str+' freq='+freq_str+' '+ channel_str +' '+$
         'fname=' + fname_txt + lo_text + int_text + ' | /home/global/instrument/sendpc/sendpc'
  print, string_total

  spawn, string_total, result

end
