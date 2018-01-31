pro spherical1_to_spherical2, long1, lat1, rtot, long2, lat2

print, '***** DO NOT USE THIS. USE SPH_COORD_CONV INSTEAD'
RETURN

;+
;NAME
;spherical1_to_spherical2 -- CONVERTS LONGITUDE AND LATITUDE between 2 systems
;
;purpose:
;CONVERTS LONGITUDE AND LATITUDE IN SYSTEM 1 TO THOSE IN SYSTEM 2
;USES THE ROTATION MATRIX RTOT
;ALL ANGLES ARE IN ***DEGREES***.
;VECTORIZED BUT REUTNRS ALL INPUTS IN 1-D.
;-

long = !dtor*long1
lat = !dtor*lat1
nrr = n_elements(long)

;GET RECTANGULAR COORDINATES...
x=fltarr(nrr, 3, /nozero)
x[*,0] = cos(lat) * cos(long)
x[*,1] = cos(lat) * sin(long)
x[*,2] = sin(lat)

;CALCULATE THE PRIMED COORDINATES...
xp = rtot ## x

;CALCULATE THE PRIMED LONG, LAT...
long2 = reform( !radeg * atan(xp[*,1], xp[*,0]))
lat2 = reform( !radeg * asin(xp[*,2]))


;stop
return
end
