PRO srs1_tst, FRQ

;+  
;Set frequency for the SRS (1) DS345 function generator
;
;CALLING SEQUENCE:
;       SRS1_frq, frq   
;
;   FRQ is in Hz with limits 
;               1.00 microHz to 
;               30.200000000 MHz
;
;with resolution 1 microHz or 11 sigfigs, whichever is worse. 
; ------>>>> USE DOUBLE PRECISION! <<<<<<<<<<------
;-

host= '10.32.92.86'

commandstr = 'FREQ ' + string(frq,FORMAT='(f0.6)')  ; + '\r'

;commandStr = 'FREQ 9999 \n'  
;commandStr = 'FREQ 9999 \r'  
; + strtrim(string(freq/1d6),2) +'MZ;'
;commandstr = 'FREQ ' + string(frq,FORMAT='(f0.6)')

;commandstr='ENABLE REMOTE'
PRINT, COMMANDSTR

gpibStatus = gpib_cmd( host,1234,19,commandStr)
print,gpibstatus

;WAIT,1.
;gpibStatus = gpib_cmd( host,1234,19,commandStr)
;print,gpibstatus

return

;=======================================================
If (FRQ ge 1.0d-6) AND (FRQ le 30.2d6) THEN BEGIN
;If (FRQ GT -1.) THEN BEGIN

; FREQ Argument

stop


stop

gpib_strg,frq

ENDIF ELSE BEGIN

print, 'FREQUENCY INPUT ERROR => 1 uHz <= FREQUENCY <= 30.2 MHz'
print, 'SRS1 FREQUENCY REMAINS UNCHANGED'

ENDELSE

RETURN

END
