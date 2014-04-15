;+
; NAME: ra2ha
; PURPOSE: convert right ascension to hour angle
; CALLING SEQUENCE: ha = ra2ha(ra, dec, lst, outDecAng = outDecAng)
; INPUTS: ra - right ascension in hours 
;         dec - declination in degrees
;         lst - local sidereal time in hours
; OUTPUTS: ha - hour angle in radians
;          outDecAng (opt) - declination in radians
; MODIFICATION HISTORY: Written on 13 February 2008 by James McBride
;-

function ra2ha, ra, dec, lst, outDecAng = outDecAng

raAng = ra * 15 * !dtor 
lstAng = lst * 15 * !dtor
decAng = dec * !dtor

x0 = cos(decAng) * cos(raAng)
x1 = cos(decAng) * sin(raAng)
x2 = sin(decAng)

x = [[x0], [x1], [x2]]
ra2ha = [[cos(lstAng), sin(lstAng), 0], $
         [sin(lstAng), -cos(lstAng), 0], $
         [0, 0, 1]]

xp = ra2ha ## x

haAng = atan(xp[1], xp[0])
outDecAng = asin(xp[2])

haSex = sixty(haAng * !radeg * 24 / 360)

return, haAng 
end

