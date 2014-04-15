;+
; NAME:  
;	geo2topo.pro
;
; PURPOSE:
;	This function performs a coordinate transform from
;	geocentric coordinates (center of earth) to topocentric
;	coordinates (surface of earth at you lattitude and
;	longitude).
;
; CALLING SEQUENCE:
;	GEO2TOPO, ra, dec, dis, topo_ra, topo_dec[,/date,/lat, /lon]
;
; INPUTS:
;	ra:	Source right ascention (babylonian or decimal hours).
;	dec:	Source declination (babylonian or decimal degrees).
;	dis:	Distance to source (assumed to be the distance to the center).
;
; KEYWORDS:
;	date:	a date array of the form:
;               [year,month,day,hour,min,sec]
;		keyword is not specified, the current Julian date is used.
;	lat:	Use this keyword to specify a latitude (dd:mm:ss or decimal).
;		If this keyword is not specified, a latitude of 37 52' 40''
;		(Campbell Hall) is assumed.
;	lon:	Use this keyword to specify the longitude (dd:mm:ss or decimal).
;		If this keyword is not spceified, a longitude of 122 14' 44''
;		(Campbell Hall) is assumed.
;
; OUTPUTS:
;	topo_ra:	Topographical right ascention (decimal hours).
;	topo_dec:	Topographical declination (decimal degrees).
;
; RESTRICTIONS:
;	This procedure will not handle vectors of coordinates.
;
; EXAMPLE:
;	GEO2TOPO, ra, dec, dis, topo_ra, topo_dec, jd=2345235.343d, $
;		lat='45:23:63', lon=146.232561
;
; MODIFICATION HISTORY:
;	Written by Curtis Frank, May 5, 1999
;       modified by Erik Shirokoff, may 2001
;-




pro geo2topo, $
	ra, $
	dec, $
	dis, $
	topo_ra, $
	topo_dec, $
	jdr=jdr, $
	lat=lat, $
	lon=lon

r_e = 6.37814d+6		;  Earth radius, from the 1998 almanac E88 (meters)
dis = dis*1d+3			;  Source distance in meters


;  Check keywords
if not(keyword_set(date)) then begin
    now=1
    jdr=jdnow(/reduced)
endif else begin
    now=0
endelse

if (keyword_set(lat)) then begin
	if ((size(lat))[1] EQ 7) then $
		lat = bab2deg(lat) 
endif else $
	lat = bab2deg('37:52:40.4')	;  Campbell Hall

if (keyword_set(lon)) then begin
	if ((size(lon))[1] EQ 7) then $
		lon = bab2deg(lon) 
endif else $
	lon = bab2deg('122:14:44')	;  Campbell Hall



;  Check ra and dec for babylonia numbers
if ((size(ra))[1] EQ 7) then $
	ra = bab2deg(ra)

if ((size(dec))[1] EQ 7) then $
	dec = bab2deg(dec)

;  Get lst now or use provided value.
if now then begin
    lst=lstnow()  
    endif else begin
    ct2lst,lst,lon,0,ten(date[3],date[4],date[5]),date[2],date[1],date[0]
endelse    
  
;ct2lst, lst, lon, dummy, jd


;  Make some intermediate and often done calculations
sd = sin(dec * !dtor)
cd = cos(dec * !dtor)
sr = sin(ra * 15. * !dtor)
cr = cos(ra * 15. * !dtor)
slat = sin(lat * !dtor)
clat = cos(lat * !dtor)
slst = sin(lst * 15. * !dtor)
clst = cos(lst * 15. * !dtor)

;  Calculate x, y, and z distances from earth surface to moon
dx = dis * cd * cr - r_e * clat * clst
dy = dis * cd * sr - r_e * clat * slst
dz = dis * sd      - r_e * slat

;  Calculate
dr = sqrt(dx^2 + dy^2 + dz^2)
topo_ra  = atan(dy, dx) / !dtor
topo_dec = asin(dz/dr) / !dtor

;  Make sure 0<=topo_ra<360
topo_ra = pmod(topo_ra + 360., 360) / 15.

end




