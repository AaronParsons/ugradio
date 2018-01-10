function fshift, tin, fchan

;+
;NAME:
;fshift -- like idl's shift, but does fractional shifts
;PURPOSE:
;	LIKE IDL'S SHIFT, BUT WORKS FOR **FRACTIONAL** CHANNELS 
;USING LINEAR INTERPOLATION.
;-

floorchan = floor(fchan)
fltchan = float( fchan - floorchan)

tshift = shift( tin, floorchan)

tshift1 = shift( tshift, 1)

tout = (1. - fltchan) * tshift + fltchan * tshift1

;plot, tin, psym=-4
;oplot, tout, psym=-2, color=255

return, tout
end
