function modangle, angle, extent, NEGPOS=negpos
;+
; NAME:
;       MODANGLE
;
; PURPOSE:
;       Convert angle to a specified range by finding the angle modulo the
;       extent of the range.
;
; CALLING SEQUENCE:
;       Result = MODANGLE(angle [, extent] [, /NEGPOS])
;
; INPUTS:
;       angle - an angle of any value in degrees or radians, a scalar or
;               vector
;
; OPTIONAL INPUTS:
;       extent - the extent of the range of angles into which we are
;                converting the input angles; a scalar value.  The range of
;                angles will be [0,+RANGE). The default is 360 degrees.  If
;                the input angles are in radians, this value *must* be
;                passed and must be in units of radians.
;
; KEYWORD PARAMETERS:
;       /NEGPOS - set this keyword if the values to be returned are
;                 negative and positive rather than all positive; the range
;                 of the returned angles will be [-EXTENT/2,+EXTENT/2)
;                 rather than the default of [0,+EXTENT).  Since the
;                 default value of EXTENT is 360 degrees, if it is not set
;                 but /NEGPOS is set, the default range will be
;                 [-180,+180).
;
; OUTPUTS:
;       Function returns the input angles modulo the extent of the range
;       into which the angles are to be transformed.  Default range is
;       [0,+EXTENT); [-EXTENT/2,+EXTENT/2) if the /NEGPOS keyword is set.
;
; EXAMPLE:
;       Plot angles so that they cover an extent of 180 degrees, centered
;       on zero degrees, so that they are wrapped into the range [-90,+90):
;       IDL> angles = findgen(720*2)-720
;       IDL> plot, angles, angles & oplot, !x.crange, [0,0]
;       IDL> oplot, angles, modangle(angles,180,/NEGPOS)
;
;       Convert angles measured in radians to range [0,!dpi):
;       IDL> rad = findgen(200)/10-10
;       IDL> plot, modangle(rad,!dpi), ys=19, ps=3
;
; NOTES:
;       Will work for radians; but the EXTENT parameter must be specified
;       since its default is 360 degrees; obviously the extent must be
;       specified in radians if the input angle is also in radians.
;
;       The word "modulo" was introduced into mathematics by Gauss in
;       1801's Disquisitiones Arithmeticae.
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  10 May 2006
;-

on_error, 2

; MAKE SURE SOMETHING GOT PASSED IN...
if (N_params() eq 0) then $
   message, "Syntax - Result = modangle(angle [,extent][,/NEGPOS])"

; IF THE EXTENT ISN'T PASSED IN, SET DEFAULT TO 360 DEGREES...
if (N_params() lt 2) then extent = 360

; IF NEGPOS IS SET, WE SET THE EXTENT OF THE RANGE TO RANGE/2...
offset = keyword_set(NEGPOS) ? extent/2 : 0

; TRANSFORM THE INPUT ANGLES INTO THE SPECIFIED EXTENT USING MOD...
return, ((((angle-offset) mod extent) + extent) mod extent) - offset

end; modangle
