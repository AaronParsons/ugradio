;+
; NAME: PARALLAX
;
; PURPOSE: Converts from geocentric to topocentric coordinates.
;
; EXPLANATION: 
;       This procedure takes the observer's geographical latitude and 
;       uses an eccentric spheroid model of the earth to approximate the
;       geocentric latitude.  That is used to calculate the parallax
;       offsets for a specific source's ra, dec, and distance.
;
;       The topocentric values are returned in place of the original
;       Ha and Dec, unless the noswap keyword is set.
;
;       Based on formulae in Astronomical Algorithms by Jean Meeus.
;
; CALLING SEQUENCE:

;       parallax,ha,dec,delta,[/au,lat=lat,long=long,height=height,debug=debug,verbose=verbose,dalpha,ddec,noswap=noswap]
;
;
; INPUTS:
;       ha - hour angle at observer's longitude in decimal hours
;       dec - declination in decimal degs
;       delta - distance to object in KM, or AU if the /au keyword is set
;
; OPTIONAL INPUTS:
;       lat=# - observer's geographic latitude in degrees (assumes
;               Campbell hall if not specified)
;       long=# - observer's geographic longitude in degrees (assumed
;                Campbell hall if not specified)
;       height=# - observer's height above mean sea level, in
;                  meters. (assumes zero if not specified)
;
; OPTIONAL INPUT KEYWORDS:
;       /au - takes a distance in astro units instead of km
;       /noswap - does not replace ha and dec with parallax
;                 corrections. (Useful if you only want the magnitude
;                 of the correction.)
;       /debug - prints everything used or calculated
;       debug=2 - works through example 11.a and 40.a in Meeus. (This
;                 causes ra, dec, and delta to change if they are
;                 variable names!)
;
; OUTPUTS: 
;       dalpha - optional - if specified, the difference in RA,
;                in decimal hours. (RA_topo = RA_geo + dalpha, or
;                equivalently HA_topo = Ha_geo - dalpha)
;       ddec - optional - if specified, the difference in dec in 
;              degrees. (dec_topo = dec_geo +ddec)
;
; EXAMPLES:
;       Find the apparent ra and dec of the moon at campbell hall on
;       april 12, 1992:
;
;         jdcnv,1992,4,12,12,jd
;         geolong=37.8732
;         geolat=-122.25730
;         moonpos, jd, ra, dec, delta ,geolong,geolat
;         ra=ra*15.  ;degrees to radians
;         ct2lst,lst,geolong,dummy,jd
;         ha=lst-ra
;         parallax,ha,dec,delta,long=geolong,lat=geolat
;         print,ha,dec
;
; RESTRICTIONS: 
;       May return strange results for objects below the
;       horizon. (Although I can't imagine why anyone would
;        need that info.)
;
; PROCEDURES CALLED:
;
; REVISION HISTORY: Erik Shirokoff, 10/2001

;-

pro parallax,ha,dec,delta,au=au,lat=lat,long=long,height=height,debug=debug,verbose=verbose,dalpha,ddec,noswap=noswap

On_error,2

if n_params() le 2 then begin
    print,'Oops!  Syntax: paralax,ha,dec,delta,[/au,lat=#,long=#,height=#]'
    print,'ha = hour angle in decimal hours'
    print,'dec = declination in decimal degs.'
    return
endif

;independant (non meeus) constants
autokm=1.49598e8  ;(nist 2001) km per astro unit

;keywords and input handling
buggy=keyword_set(debug)
if buggy then $
  if debug eq 2 then begin      ;example 11a and 40a in meeus
    lat=ten(33,21,22)
    height=1706.
    long=ten(7,47,27)*15.0
    ha=288.7958/15.0
    dec=-ten(15,46,15.9)
    delta=.37276
    au=1
endif
;
verby=keyword_set(verbose)
if keyword_set(lat) then geolat=double(lat)*!dtor else $
  geolat=37.873200d0*!dtor
if keyword_set(long) then geolong=double(long)*!dtor else $
  geolong=-122.25730d0*!dtor
if keyword_set(height) eq 0 then height=0d0  ;above sea level in meters
if keyword_set(au) then delt=double(delta)*autokm else delt=double(delta)
gha=double(ha)*15d0*!dtor
gdec=double(dec)*!dtor

;from chapter 11 in meeus
a=6378.14d0 ;equitorial radius in km
f=1d0/298.257d0 ;flatening factor
b=a*(1d0-f) ;polar radius
e=sqrt(2d0*f-f^2) ;eccentricity
phi=geolat

tanu=(b/a)*tan(phi)
u=atan(tanu)

rsphip=(b/a)*sin(u)+(height/6378140d0)*sin(phi) ;rho sin phi prime
rcphip=cos(u)+(height/6378140d0)*cos(phi) ;rho cos phi prime

if buggy then begin
    print,'a,f,b:',a,f,b
    print,'e,phi(deg),u(deg):',e,phi*!radeg,u*!radeg
    print,'rsphip,rcphip:',rsphip,rcphip
endif


;From chapter 40

sinpi=6378.14/delt ;for a delta in KM
pi=asin(sinpi)

;tan of delta alpha
tdalpha=(-rcphip*sinpi*sin(gha))/(cos(gdec)-rcphip*sinpi*cos(gha))
dalpha=atan(tdalpha)
if buggy then begin
print,'tdalpha fraction:'
print,(-rcphip*sinpi*sin(gha))
print,(cos(gdec)-rcphip*sinpi*cos(gha))
endif


;tan of delta prime
tdprime=((sin(gdec)-rsphip*sinpi)*cos(dalpha))/(cos(gdec)-rcphip*sinpi*cos(gha))

dprime=atan(tdprime)
ddec=dprime-gdec

if buggy then begin
    print,'pi(arcdeg,min,sec):'
    print,sixty(pi*!radeg)
    print,'dalpha(hour,min,sec):'
    print,sixty(dalpha*!radeg/15.)
    print,'ddec(arcdeg,min,sec):'
    print,sixty(ddec*!radeg)
;    print,'pi(arcsec),tdalpha,dalpha(deg)',sinpi*!radeg*3600.,tdalpha,dalpha*!radeg
;    print,'tdprime,ddec(deg)',tdprime,ddec*!radeg
endif


;get the units right
;ha=lst-ra ; ra=ra+dalpha
dalpha=dalpha*!radeg/15d0
ddec=ddec*!radeg
newha=ha-dalpha
newdec=dprime*!radeg

;do the in place swap, return floats if not double input
if keyword_set(noswap) eq 0 then begin
    hasize=size(ha)
    nhas=n_elements(hasize)
    hatype=hasize[nhas-2]
    if hatype ne 5 then begin
        ha=float(newha)
        dec=float(newdec)
    endif else begin
        ha=newha
        dec=newdec
    endelse
endif

return
end
