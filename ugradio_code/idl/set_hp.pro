function set_hp, freq
;+
; NAME:
;    SET_HP
;
; AUTHOR:
;    Karto Keating
;
; PURPOSE: 
;    Set the HP 8657A synthesizer in the lab.
;
; CALLING SEQUENCE:
;    STATUS = SET_HP(FREQ)
; INPUTS:
;    FREQ -- (Double, Single, Long or Int): The frequency in Hz to set the oscillator
;            to. Note that the maximum frequency is 1040 MHz, so the program will throw
;            an error if the synthesizer is set above this value.
;
; OUTPUTS:
;    STATUS -- If all is well, this value will be set to zero.
;
; VERSION HISTORY:
;    10Feb2015: Created.
;    01Dec2015. CH changed upper limit to 1040 MHz and added a bit of documentation.
;    11jan2017. CH fixed bug in 1040 MHz test
;-

;goto, skip

if (freq gt 1040.d6) then begin
    print, 'Frequency selection exceeds 1040 MHz--too high!' 
    return, 1040
    message, 'Frequency selection exceeds 1040 MHz--too high!'
endif else if (freq lt 0.01d6) then begin
    print, 'Frequency selection smaller than 0.01 MHz--too low!' 
    return, 0.01
    message, 'Frequency selection smaller than 0.01 MHz--too low!'
endif

skip:
host= '10.32.92.87'

commandStr = 'FR' + strtrim(string(freq/1d6),2) +'MZ;'
;commandstr = 'ENABLE REMOTE'
;PRINT, COMMANDSTR
;gpibStatus = gpib_cmd( host,1253,2,commandStr)
gpibStatus = gpib_cmd( host,1234,2,commandStr)

return, gpibStatus

end
