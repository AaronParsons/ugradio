PRO srs2_vpp, vpp

;  Set Amplidtude for the SRS (2) DS345 function generator
;
;  Amplitude range ==>> vpp: -5 Vpp < vpp < 5 Vpp


If (vpp GT -5) AND (vpp LT 5) THEN BEGIN

; Set GPIB Address / controller mode / EOS Mode

addr = '++addr 21'
gpib_strg, addr

mode = '++mode 1'
gpib_strg, mode

eos = '++eos 2'
gpib_strg, eos

; FREQ Argument

vpp = 'AMPL ' + string(vpp,FORMAT='(f0.2)')+' VP'
gpib_strg,vpp

ENDIF ELSE BEGIN

print, 'AMPLITUDE INPUT ERROR => -5 Vpp < AMPLITUDE < 5 Vpp'
print, 'SRS2 AMPLITUDE REMAINS UNCHANGED'

ENDELSE


END