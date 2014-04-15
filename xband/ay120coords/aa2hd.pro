;+
; NAME:  
;	aa2hd.pro
;
; PURPOSE:
;	This function performs a coordinate transform from
;	terrestrial coordinates (Altitude, Azimuth) to
;	equatorial coordinates (hour angle, declination).
;
; CALLING SEQUENCE:
;	Result = AA2HD(Az, Alt)
;
; INPUTS:
;	Az:	Azimuth in decimal degrees.  Azimuth zero point is
;		north, measured positively from north to east.
;
;	Alt:	Altitude in decimal degrees.  Altitude zero point
;		is the horizion, measured positively to the zenith.
;		Maximum value of altitude of 90.0 degrees at the 
;		zenith.
;
; KEYWORDS:
;	Lat:	Use this keyword to specify a latitude (dd:mm:ss or decimal).
;		If this keyword is not specified, a latitude of 37 52' 40''
;		(Campbell Hall) is assumed.  
;
; OUTPUTS:
;	This function returns a vector with two elements:
;	Result[0]:  Hour angle in decimal hours.
;	Result[1]:  Declination in decimal degrees.
;
; RESTRICTIONS:
;	This procedure will not handle vectors of coordinates.
;
; PROCEDURE:
;	The coordinate transformation is performed by forming a
;	rotation matrix and matrix multiplying with the input coordinate.
;
; EXAMPLE:
;	hd = AA2HD(az, alt, lat=20.0)
;
; MODIFICATION HISTORY:
;	Written by Murray Brown, November 12, 1997
;	Documentation corrected, CF, 11/15/97
;	Lat keyword added,  CF, 12/15/97
;
;-

;; Simple coordinate transform routine

;; from Az, Alt to Ra, Dec
;; inputs are decimal degrees 

;;  returns a two dimensional array hd
;                     hd(0) = ha   (in decimal hours)
;                     hd(1) = dec  (in decimal degrees)



function aa2hd, azimuth, altitude, lat=lat




;  Convert altitude and azimuth from degrees to radians
alt = !dtor * altitude
az = !dtor * azimuth

;  Convert the altitude and azimuth to Cartesian coordinates
x = make_array(1,3,/double)
x(0) = cos(alt) * cos(az)
x(1) = cos(alt) * sin(az)
x(2) = sin(alt)

;  Determine latitude in radians
size_lat = size(lat)
if (keyword_set(lat)) then begin
	if (size_lat[1] EQ 7) then latitude=bab2deg(lat)*!dtor else latitude=lat*!dtor
endif else latitude=37.877777777777778*!dtor

;  Make the rotation array
R = make_array(3,3,/double)

R(0,0) = -sin(latitude) 
R(1,0) = 0  
R(2,0) = cos(latitude)

R(0,1) = 0
R(1,1) = double(-1)
R(2,1) = 0

R(0,2) = cos(latitude) 
R(1,2) = 0
R(2,2) = sin(latitude)

;  Perform the matrix multiplication
xp = make_array(1,3,/double)
xp = transpose(R) ## x

;  Convert back to spherical coordinates
hd = make_array(2,1,/double)
hd(0) = !radeg * atan(xp(1),xp(0)) / double(15)
hd(1) = !radeg * asin(xp(2))

;  Return the HA and dec
return, hd

end
