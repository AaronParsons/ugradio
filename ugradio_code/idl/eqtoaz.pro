pro eqtoaz, ha, dec, az, za, direction

;+
;NAME:
;eqtoaz -- CONVERT HA, DEC TO AZ, ZA or vice versa
;CONVERT HA, DEC TO AZ, ZA IF DIRECTION=+1
;CONVERT AZ, ZA TO ZA, DEC IF DIRECTION=-1
;HA, DEC ARE IN DECIMAL HRS, DEG
;AZ, ZA ARE IN DECIMAL DEG, DEG
;
;
;
;*********** DO NOT USE THIS PROGRAM. USE EQ2AZ INSTEAD ***************
;*********** do not use this program. use eq2az instead ***************
;*********** DO NOT USE THIS PROGRAM. USE EQ2AZ INSTEAD ***************
;*********** do not use this program. use eq2az instead ***************
;*********** DO NOT USE THIS PROGRAM. USE EQ2AZ INSTEAD ***************
;------Reason: it needs 'common anglestuff', which is deprecated-------
;
;IN COMMON ANGLESTUFF, OBSLONG AND OBSLAT ARE ASSUMED TO BE IN DEGREES.
;-

common anglestuff, obslong, obslat, cosobslat, sinobslat

if ( (direction ne 1) and (direction ne -1) ) then begin
	print, 'IN ANGLESTUFF, DIRECTION MUST BE EITHER + OR - 1. RETURNING.'
	RETURN
endif

if (direction eq 1) then begin
	lat = !dtor*dec
	long = 15.*!dtor*ha
	nrr = n_elements(ha)
endif else begin
	lat = !dtor*(90.-za)
	long = !dtor*az
	nrr = n_elements(az)
endelse


;GET RECTANGULAR COORDINATES...
x=fltarr(3, nrr)
x[0,*] = cos(lat) * cos(long)
x[1,*] = cos(lat) * sin(long)
x[2,*] = sin(lat)

;DEFINE THE ROTATION MATRIX...
r = fltarr(3, 3, nrr)
r[0,0, *] = -sinobslat + fltarr(nrr)
r[0,2, *] = cosobslat + fltarr(nrr)
r[1,1, *] = -1. + fltarr(nrr)
r[2,0, *] = cosobslat + fltarr(nrr)
r[2,2, *] = sinobslat + fltarr(nrr)
if (direction eq -1) then for nr=0,nrr-1 do r[*,*,nr] = transpose(r[*,*,nr])

;CALCULATE THE PRIMED COORDINATES...
xp = fltarr(3,nrr)
for nr=0l,nrr-1 do xp[*,nr] =  r[*,*,nr] ## x[*,nr]

;CALCULATE THE PRIMED LONG, LAT...
longp = atan(xp[1,*], xp[0,*])
latp = asin(xp[2,*])

;CALCULATE THE OUTPUT ANGLES...
 
if (direction eq 1) then begin
	za = reform( 90.-!radeg*latp)
	az = reform( !radeg*longp)
	if (n_elements( az) eq 1) then az=az[0] 
	if (n_elements( za) eq 1) then za=za[0] 
	;print, 'dir was 1'
endif else begin
	dec = reform( !radeg*latp)
	ha = reform( !radeg*longp/15.)
	if (n_elements( ha) eq 1) then ha=ha[0] 
	if (n_elements( dec) eq 1) then dec=dec[0] 
	;print, 'dir was not 1'
endelse


;stop
return
end










