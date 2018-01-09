PRO srs2_off, off

;  Set voltage offset for the SRS (2) DS345 function generator
;
;  Offset range ==>> off:  -5 < off < 5


If (off GT -5) AND (off LT 5) THEN BEGIN

; Set GPIB Address / controller mode / EOS Mode

addr = '++addr 21'
gpib_strg, addr

mode = '++mode 1'
gpib_strg, mode

eos = '++eos 2'
gpib_strg, eos

; FREQ Argument

off = 'OFFS ' + string(off,FORMAT='(f0.2)')
gpib_strg,off

ENDIF ELSE BEGIN

print, 'OFFSET INPUT ERROR => -5 V < OFFSET < 5 V'
print, 'SRS2 OFFSET REMAINS UNCHANGED'

ENDELSE


END