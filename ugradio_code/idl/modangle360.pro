function modangle360, angles, negpos=negpos
;+
;NAME:
;modangle360 --  CONVERT ANGLES TO THE INTERVAL 0 TO 360 DEG.
; CONVERT ANGLES TO THE INTERVAL 0 TO 360 DEG.
; ALL ANGLES ARE IN DEGREES.
; if negpos is set, interval is -180 to 180
;-

mangles = angles mod 360.
mangles = mangles + 360.*(mangles lt 0.)

if  keyword_set( negpos) then mangles= mangles - 360.*(mangles gt 180)

return, mangles
end
