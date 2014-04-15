PRO srs2_phs, phs

;  Set Phase for the SRS (2) DS345 function generator
;
;  Phase range ==>> off:  0 < phs < 7200


If (phs GE 0) AND (phs LT 7200) THEN BEGIN

; Set GPIB Address / controller mode / EOS Mode

addr = '++addr 21'
gpib_strg, addr

mode = '++mode 1'
gpib_strg, mode

eos = '++eos 2'
gpib_strg, eos

; FREQ Argument

phs = 'PHSE ' + string(phs,FORMAT='(f0.3)')
gpib_strg,phs

ENDIF ELSE BEGIN

print, 'PHASE INPUT ERROR => 0 deg < OFFSET < 7200 deg'
print, 'SRS2 PHASE REMAINS UNCHANGED'

ENDELSE


END