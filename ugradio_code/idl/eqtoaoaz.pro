pro eqtoaoaz, ha, dec, aoaz, za, direction
;+
;PURPOSE:
;       CONVERT EQUATORIAL TO **ARECIBO'S** ALTAZ, GO EITHER DIRECTION.

;	HERE AOAZ REFERS TO THE AZ OF ARECIBO'S FEED ARM, 
;	WHICH IS 180 DEG FROM ASTRONOMICAL AZ.

;NOTE:
;       TO CONVERT TO ***ASTRONOMICAL*** ALTAZ, use EQTOAZ.

;CALLING SEQUENCE:
;        EQTOAZ, ha, dec, az, za, direction

;INPUTS:
;       DIRECTION, if +1 input is equatorial and output is azza
;                  if -1 input is azza and output is equatorial
;       INPUTS DEPEND ON DIRECTION. IF DIRECTION IS +1, HA, DEC ARE INPUTS
;                                   IF DIRECTION IS -1, AZ, ZA ARE INPUTS
;       HA HAS UNITS OF DECIMAL HOURS     
;       DEC HAS UNITS OF DECIMAL DEGREES
;       AZ HAS UNITS OF DECIMAL DEGREES
;       ZA HAS UNITS OF DECMIAL DEGREES

;OUTPUTS:
;       OUTPUTS DEPEND ON DIRECTION. IF DIRECTION IS +1, AZ, ZA ARE OUTPUTS 
;                                    IF DIRECTION IS -1, RA, DEC ARE OUTPUTS
;

;;COMMON VARIABLES:                                       
;       COMMON ANGLESTUFF, obslong, obslat, cosobslat, sinobslat
;
;       OBSLONG, the observatory's longitude in degrees 
;               (for AO: 66d45m10.8s = 66.753000000) (FROM PHIL MAR 99)
;       OBSLAT, the observatory's latitude in degrees 
;               (for AO: 18d21m14.2s = 18.3539444444) (FROM PHIL MAR 99)
;       COSOBSLAT: cosine of observatory's latitude
;       SINOBSLAT: sin of observatory's latitude

;WRITTEN BY CARL HEILES MAR 99
;DOCUMENTATION ADDED BY CARL MAR 00
;-

common anglestuff, obslong, obslat, cosobslat, sinobslat

if ( (direction ne 1) and (direction ne -1) ) then begin
	print, 'IN ANGLESTUFF, DIRECTION MUST BE EITHER + OR - 1. RETURNING.'
	RETURN
endif

if (direction eq 1) then begin
	lat = !dtor*dec
	long = 15.*!dtor*ha
endif else begin
	lat = !dtor*(90.-za)
	long = !dtor*(180.+aoaz)
endelse

nelms = n_elements(lat)

;GET RECTANGULAR COORDINATES...
x=fltarr(3, nelms)
xp = x
x[0,*] = cos(lat) * cos(long)
x[1,*] = cos(lat) * sin(long)
x[2,*] = sin(lat)

;DEFINE THE ROTATION MATRIX...
r = fltarr(3,3)
r[0,0] = -sinobslat
r[0,2] = cosobslat
r[1,1] = -1.
r[2,0] = cosobslat
r[2,2] = sinobslat
if (direction eq -1) then r = transpose(r)

;CALCULATE THE PRIMED COORDINATES...
for nr = 0, nelms-1 do xp[*,nr] = R ## x[*,nr]

;CALCULATE THE PRIMED LONG, LAT...
longp = atan(xp[1,*], xp[0,*])
latp = asin(xp[2,*])

longp=reform(longp)
latp = reform(latp)
;CALCULATE THE OUTPUT ANGLES...
 
if (direction eq 1) then begin
	za = 90.-!radeg*latp
	aoaz = modangle360(!radeg*longp + 180.)
	if (n_elements(za) eq 1) then za=za[0]
	if (n_elements(aoaz) eq 1) then aoaz=aoaz[0]
;print, 'dir was 1'
endif else begin
	dec = !radeg*latp
	ha = !radeg*longp/15.
	if (n_elements(dec) eq 1) then dec=dec[0]
	if (n_elements(ha) eq 1) then ha=ha[0]
;print, 'dir was not 1'
endelse

;stop
return
end










