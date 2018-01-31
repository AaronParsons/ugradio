pro eq2az, ha, dec, az, za, latitude, REVERSE=reverse
;+
; NAME:
;       EQ2AZ
;
; PURPOSE:
;       To convert between the HOUR ANGLE-DECLINATION and AZIMUTH-ZENITH 
;       ANGLE coordinate systems.
;
; CALLING SEQUENCE:
;       EQ2AZ, ha, dec, az, za, latitude [, /REVERSE]
;
; INPUTS:
;       latitude  - the latitude (a scalar) of the observatory, measured 
;                   in decimal degrees. If latitude is not entered, it
;                   uses !obsnlat
;
; KEYWORD PARAMETERS:
;       /REVERSE : if this keyword is set, the program takes the azimuth 
;                  and zenith angle as inputs and returns the hour angle 
;                  and the declination.  The default behavior, as the module 
;                  name suggests, is to return the azimuth and zenith angle 
;                  given the hour angle and declination.
;
; INPUTS OR OUTPUTS (DEPENDING ON /REVERSE KEYWORD) :
;       ha  - hour angle, measured in decimal hours; scalar or array
;       dec - declination, measured in decimal degrees; scalar or array
;       az  - azimuth, measured in decimal degrees; scalar or array
;       za  - zenith angle (the complementary angle to the elevation), 
;             measured in decimal degrees; scalar or array
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       Hour angle must be given in decimal hours.  Declination, azimuth,
;       zenith angle, and latitude must be given in decimal degrees.
;
; EXAMPLE:
;       Find the azimuth and zenith angle of Altair [RA (J2000): 19 50 47 
;       Dec (J2000): 08 52 06] at LST 19h at Arecibo [LONG: 66 45 10.8
;       LAT: 18 21 14.2]
;
;       IDL> eq2az, 19.0-ten(19,50,47), ten(08,52,06), az, za, $
;       IDL> ten(18,21,14.2)
;       IDL> help, az, za
;       AZ              DOUBLE    =        125.90073
;       ZA              DOUBLE    =        15.549609
;
; NOTES:
;       Went through pain to assure that if a scalar is input, a scalar 
;       is returned, but even more pain to allow multi-dimensional
;       arrays to be input (and to make the output have the same 
;       dimensions!) Also, if inputs are double precision, the calculations 
;       will be done in double precision.  The azimuth is returned in the 
;       range 0 -> 360 degrees.
;
; MODIFICATION HISTORY:
;       20 May 2004  Written by Tim Robishaw, Berkeley
;       9 Jul 2016. CH added: use !obsnlat if latitude is undefined.
;-

on_error, 2

; GET THE LATITUDE AND LONGITUDE...
if n_elements( latitude) eq 0 then lati=!obsnlat else lati=latitude

if not keyword_set(REVERSE) then begin

    ; MAKE SURE INPUTS HAVE THE SAME SIZE...
    nelm = N_elements(ha)
    ndim = size(ha,/N_DIMENSIONS)
    dim  = size(ha,/DIMENSIONS)
    if not array_equal(dim,size(dec,/DIMENSIONS)) $
      then message, 'HA and DEC must have the same dimensions!'

    ; CONVERT TO RADIANS...
    lat  = !dtor*((ndim gt 0) ? reform(dec,nelm) : dec)
    long = 15.*!dtor*((ndim gt 0) ? reform(ha,nelm) : ha)

endif else begin

    ; MAKE SURE THE INPUTS HAVE THE SAME SIZE...
    nelm = N_elements(za)
    ndim = size(za,/N_DIMENSIONS)
    dim  = size(za,/DIMENSIONS)
    if not array_equal(dim,size(az,/DIMENSIONS)) $
      then message, 'AZ and ZA must have the same dimensions!'

    ; CONVERT TO RADIANS...
    lat  = !dtor*(90.-((ndim gt 0) ? reform(za,nelm) : za))
    long = !dtor*((ndim gt 0) ? reform(az,nelm) : az)

endelse

; TAKE THE SIN AND COS OF THE OBSERVATORY LATI...
cos_obs_lat = cos(!dtor*lati)
sin_obs_lat = sin(!dtor*lati)

; GET RECTANGULAR COORDINATES...
x = [[cos(lat) * cos(long)],$
     [cos(lat) * sin(long)],$
     [sin(lat)]]

; DEFINE THE ROTATION MATRIX...
r = make_array(3,3,DOUBLE=(size(lat,/TYPE) eq 5))
r[0,0] = -sin_obs_lat
r[0,2] = cos_obs_lat
r[1,1] = -1.
r[2,0] = cos_obs_lat
r[2,2] = sin_obs_lat

; DO WE WANT TO CONVERT FROM AZ/ZA TO HA/DEC...
if keyword_set(REVERSE) then r = transpose(r)

; ROTATE TO THE PRIMED COORDINATES...
xp = R ## x

; CALCULATE THE PRIMED LONG, LAT...
longp = atan(xp[*,1], xp[*,0])
latp  = asin(xp[*,2])

; REFORM THE OUTPUT TO THE CORRECT DIMENSIONS...
longp = (ndim gt 0) ? reform(longp,dim) : longp[0]
latp  = (ndim gt 0) ? reform(latp,dim)  : latp[0]

; CALCULATE THE OUTPUT ANGLES...
if not keyword_set(REVERSE) then begin

    ; CONVERT BACK TO DECIMAL DEGREES...
    za = 90.-!radeg*latp        ; COMPLEMENTARY TO ELEVATION ANGLE 
    az = !radeg*longp

    ; CONSTRAIN AZIMUTH TO RANGE 0<=AZ<360...
    az = az mod 360
    az = az + 360*(az lt 0)

endif else begin

    dec = !radeg*latp           ; CONVERT BACK TO DECIMAL DEGREES
    ha  = !radeg*longp/15.0     ; CONVERT BACK TO HOURS

endelse

end; eq2az
