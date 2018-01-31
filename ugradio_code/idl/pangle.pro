function pangle, az, za, modno

;+
;PANGLE: get parallactic angle in DEGREES.
;
;CALLING:
;pangle, az, za, modno
;
;AZ is in degrees
;ZA is in degrees
;MODNO: is optional; if not given, default is zero
;
;IF MODNO IS UNDEFINED OR ZERO, THEN THE PA IS MODULO 180 DEGREES
;IF MODNO IS NONZERO, THE PA IS 0 TO 360 DEG.
;FOR MODNO NONZERO, THE PA DIFFERS FROM AZ ANGLE BY ABOUT 180 DEGREES.
;THIS MAKES SENSE, IF YOU THINK ABOUT IT...

;-

;********* IMPORTANT **********
;30 MAR: BEFORE THIS DATA ALL PA'S WERE WRONG .
;THIS ROUTINE CORRECTED ON 30 MAR.
;RETURNS THE EQUATORIAL POSITION ANGLE OF THE FEED ARM.

;ASSUME THAT THE DIRECTION OF LINEAR POLARIZATION
;OF THE FEED WRT THE FEED ARM IS THETA. NOMINALLY,
;THETA=0.

;CALCULATE TWO CLOSELY-SPACED EQUATORIAL POSITIONS
;THAT CORRESPOND TO TWO CLOSELY-SPACED POSITIONS
;SEPARATED IN ELEVATION ONLY, THAT IS AT CONSTANT AZIMUTH.

;USE 0.5 DEGREE AS THE OFFSET--THE TOTAL DISTANCE BETWEEN
;THE POSITIONS IS 1 DEGREE.

if (n_elements(modno) eq 0) then modno=0

eqtoaoaz, ha, dec, az, za, -1
eqtoaoaz, haminus, decminus, az, za-0.5, -1
eqtoaoaz, haplus, decplus, az, za+0.5, -1

;AT THIS POINT: HA IS IN DECIMAL HRS, DEC IS IN DEC DEGREES.


;USE THE OLD WAY BECAUSE IT ALLOWS POSSIBILITY OF FULL 360 DEG IN PA.
;THE OLD WAY...
haoffset = 15.* (haplus - haminus) * cos(!dtor*dec)
decoffset = decplus - decminus
posangle = !radeg*atan( -haoffset, decoffset)
if (modno eq 0) then posangle = modanglem(posangle)
;print, haoffset, decoffset, posangle
;STOP

return, posangle

;THE NEW WAY USING GODDARD ROUTINES...
;posang, 1, haminus, decminus, haplus, decplus, testangle1
;posang, 1, haplus, decplus, haminus, decminus, testangle2
;;testangle = modanglem(0.5*(testangle1 + testangle2 - 180.))
;testangle = 0.5*(testangle1 + testangle2 - 180.)
;print, posangle, testangle, testangle1-180., testangle2
;stop
;NO NEED FOR DOUBLE PRECISION!
;return, float(testangle)
end
