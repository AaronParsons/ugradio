function ugdoppler, ra, dec, julday, $
	obspos_deg=obspos_deg, path=path, light=light, nlat=nlat, wlong=wlong

;+
; NAME: ugdoppler
;       
; PURPOSE: 
;       computes the projected velocity of the telescope wrt 
;       four coordinate systems: geo, helio, bary, lsr.
;	negative velocities mean approach
;
;       the standard LSR is defined as follows: the sun moves at 20.0 km/s
;       toward ra=18.0h, dec=30.0 deg in 1900 epoch coords
;
; CALLING SEQUENCE: result = ugdoppler( ra, dec, julday,
;        obspos_deg=obspos_deg, path=path, light=light)
;
; INPUTS: fully vectorized...ALL THREE INPUTS MUST HAVE SAME DIMENSIONS!!
;       ra[n] - the source ra in DECIMAL HOURS, equinox 2000
;       dec[n] - the source dec in decimal degrees, equinox 2000
;	julday[n] - the full (unmodified) julian day. MJD = JD - 2400000.5
;
; KEYWORD PARAMETERS;
;       /light - returns the velocity as a fraction of c
;
; OPTIONAL INPUTS: 
;       nlat, wlong - specify nlat and wlong of obs in
;               degrees.  if you set one, you must set the other also.
;       path - path for the station file. If both (nlat, wlong) and
;               (path) are specified, then (nlat, wlong) overrules.
;               if path is specified, it reads (nlat, elong) from the
;               file path + .station. NOTE **EAST** LONGITUDE IS
;               CONTAINED IN THE .STATION FILE (We convert to wlong
;               here)!! If (nlat, wlong) or path is not 
;               specified, the default nlat, wlong are for CAMPBELL HALL.
;
; OUTPUTS: 
;       program returns the velocity in km/s, or as a faction of c if
;       the keyword /light is specified. the result is a 4-element
;	vector whose elements are [geo, helio, bary, lsr]. quick
;	comparison with phil's C doppler routines gives agreement to 
;	better than 100 m/s one arbitrary case.
;
; OPTIONAL OUTUTS:
;	/obspos_deg: observatory [lat, wlong] in degrees that was used
;	in the calculation. This is set by either (nlat and wlong) or
;	path; default is Arecibo.
;
; REVISION HISTORY: carlh 29oct04. 
;	from idoppler_ch; changed calculation epoch to 2000
;	19nov04: correct bad earth spin calculation
;	7 jun 2005: vectorize to make faster for quantity calculations.
;       20 Mar 2007: CH updated documentation for chdoppler and 
;created this version, ugdoppler, which uses the locally-derived lst
;(from ilst.pro).
;-

;------------------ORBITAL SECTION-------------------------
nin= n_elements( ra)

;GET THE COMPONENTS OF RA AND DEC, 2000u EPOCH
rasource=ra*15.*!dtor
decsource=dec*!dtor

xxsource = fltarr( 3, nin)
xxsource[0, *] = cos(decsource) * cos(rasource)
xxsource[1, *] = cos(decsource) * sin(rasource)
xxsource[2, *] = sin(decsource)
pvorbit_helio= dblarr( nin)
pvorbit_bary= dblarr( nin)
pvlsr= dblarr( nin)

;GET THE EARTH VELOCITY WRT THE SUN CENTER
;THEN MULTIPLY BY SSSOURCE TO GET $
;	PROJECTED VELOCITY OF EARTH CENTER WRT SUN TO THE SOURCE
FOR NR=0, NIN-1 DO BEGIN
baryvel, julday[nr], 2000.,vvorbit,velb
pvorbit_helio[ nr]= total(vvorbit* xxsource[ *,nr])
pvorbit_bary[ nr]= total(velb* xxsource[ *,nr])
ENDFOR

;stop

;-----------------------LSR SECTION-------------------------
;THE STANDARD LSR IS DEFINED AS FOLLOWS: THE SUN MOVES AT 20.0 KM/S
;TOWARD RA=18.0H, DEC=30.0 DEG IN 1900 EPOCH COORDS
;using PRECESS, this works out to ra=18.063955 dec=30.004661 in 2000 coords.
ralsr_rad= 2.*!pi*18./24.
declsr_rad= !dtor*30.
precess, ralsr_rad, declsr_rad, 1900., 2000.,/radian

;FIND THE COMPONENTS OF THE VELOCITY OF THE SUN WRT THE LSR FRAME 
xxlsr = fltarr( 3, nin)
xxlsr[ 0, *] = cos(declsr_rad) * cos(ralsr_rad)
xxlsr[ 1, *] = cos(declsr_rad) * sin(ralsr_rad)
xxlsr[ 2, *] = sin(declsr_rad)
vvlsr = 20.*xxlsr

;PROJECTED VELOCITY OF THE SUN WRT LSR TO THE SOURCE
for nr=0, nin-1 do pvlsr[ nr]=total(vvlsr*xxsource[ *, nr])

;---------------------EARTH SPIN SECTION------------------------
;NOTE: THE ORIGINAL VERSION WAS FLAWED. WE comment out those bad statements...

;;ARECIBO COORDS...
;northlat= 18.3539444444d
;westlong= 15.d* (4.D +  27.d/60.d + .720D/3600.D)
;obspos_deg= [ northlat, westlong]

;CAMPBELL HALL COORDS...
northlat= 37.8732
westlong= 122.2573
obspos_deg= [ northlat, westlong]

;COORDS FROM .STATION FILE...
IF KEYWORD_SET( PATH) THEN BEGIN
	station, northlat, eastlong, path=path
	obspos_deg= [ northlat, -eastlong]
ENDIF 

;COORDS FROM NLAT, WLONG INPUT...
if n_elements( nlat) ne 0 and n_elements( wlong) ne 0 then $
  obspos_deg= [nlat, wlong]

;GET THE LATITUDE...
lat= obspos_deg[0]

lst_mean= ilst( juldate=julday, nlat=obspos_deg[0], wlong=obspos_deg[1], $
   path=path)                                                           

;if (n_elements( obspos_deg) ne 0) then $
;   lst_mean= 24./(2.*!pi)* chjuldaytolmst( julday, obspos_deg=obspos_deg) $
;else lst_mean= 24./(2.*!pi)* chjuldaytolmst( julday)

;MODIFIED EARTH SPIN FROM GREEN PAGE 270
pvspin= -0.465* cos( !dtor* lat) * cos( decsource) * $
	sin(( lst_mean- ra)* 15.* !dtor)

;stop

;---------------------NOW PUT IT ALL TOGETHER------------------

vtotal= fltarr( 4, nin)
vtotal[ 0,*]= -pvspin
vtotal[ 1,*]= -pvspin- pvorbit_helio
vtotal[ 2,*]= -pvspin- pvorbit_bary
vtotal[ 3,*]= -pvspin- pvorbit_bary- pvlsr

if keyword_set(light) then vtotal=vtotal/(2.99792458e5)

;print, pvorbit, pvspin, vtotal, keyword_set( geo), keyword_set( helio)

;stop

return,vtotal
end






