;+
; NAME:  
;	hd2aa.pro
;
; PURPOSE:
;	This function performs a coordinate transform from
;	equatorial coordinates (hour angle, declination) to
;	terrestrial coordinates (altitude, azimuth).
;
; CALLING SEQUENCE:
;	Result = HD2AA(HA, dec, [lat=])
;
; INPUTS:
;	HA:	Hour angle to be converted in DECIMAL *****DEGREES*****.
;
;	dec:	Declination to be converted in decimal degrees.
;
; KEYWORDS:
;	Lat:	Use this keyword to specify a latitude (dd:mm:ss or decimal).
;		If this keyword is not specified, a latitude of 37 52' 24''
;		(Campbell Hall) is assumed.  
;
; OUTPUTS:
;	This function returns a vector with two elements:
;	Result[0]:  Altitude in decimal degrees.
;	Result[1]:  Azimuth in decimal degrees.
;
; RESTRICTIONS:
;	This procedure will not handle vectors of coordinates.
;
; PROCEDURE:
;	The coordinate transformation is performed by forming a
;	rotation matrix and matrix multiplying with the input coordinate.
;
; EXAMPLE:
;	aa = HD2AA(ha, dec, lat=20.0)
;
; MODIFICATION HISTORY:
;	Written by Curtis Frank, November 12, 1997
;	Lat keyword added,  CF, 12/15/97
;
;-

;; Simple coordinate transform routine

;; from HA, Dec to Alt, Az
;; inputs are decimal degrees 
;; outputs are decimal degrees

;;  returns a two dimensional array hd
;                     aa[0] = alt 
;                     aa[1] = az

function hd2aa, HourAngle, Declination, lat=lat

;default_latitude= ten(37,52,40)
default_latitude= ten(37,52,24)

;  Make needed arrays and vectors
aa = make_array(2, /double)
R = make_array (3,3, /double, value=0.0)
x = make_array (1,3, /double)
xp = make_array (1,3, /double)

;  Determine latitude and in radians
size_lat = size(lat)
if (keyword_set(lat)) then begin
	if (size_lat[1] EQ 7) then latitude=bab2deg(lat)*!dtor else latitude=lat*!dtor
endif else latitude= default_latitude*!dtor

;  Convert equitorial coordinates to radians
ha = !dtor * HourAngle
dec = !dtor * Declination

;  Make sure the hour angle is within range.
ha = (ha - floor((ha + 180.0 * !dtor) / 360.0 * !dtor) * 360.0 * !dtor)

;  Calculate sines and cosines used.
ch = cos (ha)
cd = cos (dec)
cl = cos (latitude)
sh = sin (ha)
sd = sin (dec)
sl = sin (latitude)

;  Convert ha and dec to Cartesian coordinates
x[0] = cd * ch
x[1] = cd * sh
x[2] = sd

;  Make rotation matrix
R[0,0] = -1 * sl
R[2,0] = cl
R[1,1] = -1
R[0,2] = R[2,0]
R[2,2] = -1 * R[0,0]

;  Perform matrix multiplication
xp = R##x

;  Convert back to spherical coordinates
aa[0] = (asin (xp[2])) / !dtor
aa[1] = (atan (xp[1], xp[0])) / !dtor

;  Check azimuth range
if (aa[1] LT 0.0) then aa[1] = aa[1] + 360.0

;  Return result
return, aa

end
