PRO srs2_frq, FRQ

;  Set frequency for the SRS (2) DS345 function generator
;
;  Frequency range ==>> frq: 0 < frq < 30e6 Hz


If (FRQ GT 0.000001) AND (FRQ LT 30e6) THEN BEGIN

; Set GPIB Address / controller mode / EOS Mode

addr = '++addr 21'
gpib_strg, addr

mode = '++mode 1'
gpib_strg, mode

eos = '++eos 2'
gpib_strg, eos

; FREQ Argument

frq = 'FREQ ' + string(frq,FORMAT='(f0.6)')
gpib_strg,frq

ENDIF ELSE BEGIN

print, 'FREQUENCY INPUT ERROR => 1 uHz < FREQUENCY < 30 MHz'
print, 'SRS2 FREQUENCY REMAINS UNCHANGED'

ENDELSE


END