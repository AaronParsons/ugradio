PRO srs1_frq, frq

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


If (FRQ ge 1.0d-6) AND (FRQ le 30.2d6) THEN BEGIN
;If (FRQ GT -1.) THEN BEGIN

; Set GPIB Address / controller mode / EOS Mode

addr = '++addr 19'
gpib_strg, addr

mode = '++mode 1'
gpib_strg, mode

;stop

eos = '++eos 2'
;eos = '++eos 0Ah'
gpib_strg, eos

; FREQ Argument

;stop

frqq= 'FREQ ' + string(frq,FORMAT='(f0.6)')
frqq= 'ENABLE REMOTE'
;frqq= 'Sine Wave'
print,frqq
;stop

gpib_strg,frqq

ENDIF ELSE BEGIN

print, 'FREQUENCY INPUT ERROR => 1 uHz <= FREQUENCY <= 30.2 MHz'
print, 'SRS1 FREQUENCY REMAINS UNCHANGED'

ENDELSE

RETURN

END
