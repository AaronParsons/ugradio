PRO srs2_dbm, dbm

;  Set Amplidtude for the SRS (1) DS345 function generator
;
;  Amplitude range ==>> dbm: -36 dBm < dbm < 23 dbm


If (dbm GT -36) AND (dbm LT 23) THEN BEGIN

; Set GPIB Address / controller mode / EOS Mode

addr = '++addr 21'
gpib_strg, addr

mode = '++mode 1'
gpib_strg, mode

eos = '++eos 2'
gpib_strg, eos

; FREQ Argument

dbm = 'AMPL ' + string(dbm,FORMAT='(f0.2)')+' DB'
gpib_strg,dbm

ENDIF ELSE BEGIN

print, 'AMPLITUDE INPUT ERROR => -36 dBm < AMPLITUDE < 23 dBm'
print, 'SRS2 AMPLITUDE REMAINS UNCHANGED'

ENDELSE


END