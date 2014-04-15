;+
; NAME: ha2az
; PURPOSE: convert hour angle, dec, to azimuth, altitude
; CALLING SEQUENCE: ha2az, haAng, decAng, altDeg, obsLat = obsLat
; INPUTS: haAng - hour angle, in radians
;         decAng - declination, in radians
;         obsLat (opt) - observer latitude, in degrees
; OUTPUTS: altDeg - altitude in degrees
; MODIFICATION HISTORY: Written on 13 February 2008 by James McBride
;-

function ha2az, haAng, decAng, altDeg, obsLat = obsLat

; latitude of Campbell Hall is set if no latitude is input
if not keyword_set(obsLat) then obsLat = 37.918333 * !dtor else obsLat = obsLat * !dtor

x0 = cos(decAng) * cos(haAng)
x1 = cos(decAng) * sin(haAng)
x2 = sin(decAng)

x = [[x0], [x1], [x2]]

ha2az = [[-sin(obsLat), 0, cos(obsLat)], [0, -1, 0], [cos(obsLat), 0, sin(obsLat)]]

xp = ha2az ## x

altDeg = asin(xp[2]) / !dtor
azDeg = atan(xp[1], xp[0]) / !dtor

return, azDeg 
end


