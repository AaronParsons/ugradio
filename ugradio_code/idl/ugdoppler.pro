function ugdoppler, ra, dec, julday, $
         nlat=nlat, wlong=wlong, $
         path=path, light=light, $
         obspos_deg=obspos_deg, lst_mean=lst_mean, $
         pvorbit_helio=pvorbit_helio, pvorbit_bary=pvorbit_bary, $
         pvlsr=pvlsr, pvspin=pvspin

;+
; NAME: ugdoppler
;       
; PURPOSE: 
;       computes the projected velocity of the telescope wrt 
;       four coordinate systems: geo, helio, bary, lsr.
;	negative velocities mean approach
;
;To obtain the velocity of an observed line in the (BARY, LSR) frame,
;subtract (V_bary, V_LSR) as given by this proc from the observed
;velocity at the telescope.
;
;       the standard LSR is defined as follows: the sun moves at 20.0 km/s
;       toward ra=18.0h, dec=30.0 deg in 1900 epoch coords
;
; CALLING SEQUENCE: 
;vel = ugdoppler( ra, dec, julday, $
;         nlat=nlat, wlong=wlong, $
;         path=path, light=light, $
;         obspos_deg=obspos_deg, lst_mean=lst_mean), $
;         pvorbit_helio=pvorbit_helio, pvorbit_bary=pvorbit_bary, $
;         pvlsr=pvlsr, pvspin=pvspin
;
; INPUTS: fully vectorized...ALL THREE INPUTS MUST HAVE SAME DIMENSIONS!!
;       ra[n] - the source ra in DECIMAL HOURS, equinox 2000
;       dec[n] - the source dec in decimal degrees, equinox 2000
;	julday[n] - the full (unmodified) julian day JD. MJD = JD - 2400000.5
;
; KEYWORD PARAMETERS;
;       campbell: calc for campbell
;       arecibo: calc for arecibo.
;       gbt: calc for gbt.
;       nlat, wlong - specify nlat and wlong of obs in
;                     degrees.  if you set one, you must set the other
;                     also.
;       If nlat and wlong ARE NOT SET, it uses !obsnlat and !obswlong
;
;       path - path for the station file. If both (nlat, wlong) and
;              (path) are specified, then (nlat, wlong) overrules.
;               if path is specified, it reads (nlat, elong) from the
;               file path + .station. NOTE **EAST** LONGITUDE IS
;               CONTAINED IN THE .STATION FILE (We convert to wlong
;               here)!!
;
;       If (nlat, wlong), path, or observatory name is not
;               specified, THE DEFAULT NLAT, WLONG ARE the system ones
;               $obsnlat, $obswlong
;
;       /light - returns the velocity as a fraction of c
;        pvorbit_helio, MINUS the heliocentric orbital velocity component
;        pvorbit_bary, MINUS the heliocentric orbital velocity component
;        pvlsr, MINUS the lsr velocity component
;        pvspin, MINUS the earth spin velocity component
;
; OUTPUTS: 
;       program returns the velocity in km/s, or as a faction of c if
;       the keyword /light is specified. the result is a 4-element
;	vector whose elements are [geo, helio, bary, lsr]. quick
;	comparison with phil's C doppler routines gives agreement to 
;	better than 100 m/s one arbitrary case.
;
; OPTIONAL OUTPUTS:
;	obspos_deg: observatory [lat, wlong] in degrees that was used
;	in the calculation. This is set by either (nlat and wlong) or
;	path; default is Arecibo.
;
;       lst_mean: the lst at the observatory for the specified JD
;
; REVISION HISTORY: carlh 29oct04. 
;	from idoppler_ch; changed calculation epoch to 2000
;	19nov04: correct bad earth spin calculation
;	7 jun 2005: vectorize to make faster for quantity calculations.
;       20 Mar 2007: CH updated documentation for chdoppler and 
;created this version, ugdoppler, which uses the locally-derived lst
;(from ilst.pro).
;       5apr2011: updated documentation, tested with tst.ugdopp.idl and
;tst1.ugdopp.ilprc 
;
;30 DEC 2015: checked for signs, purged old versions, replaced
;       duplicate files with symlinks.
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

;GET OBSERVATORY COORDS...

;FROM SYSTEM VARIABLES (DEFAULT)
obspos_deg= [ !obsnlat, !obswlong]

;CAMPBELL
if keyword_set( campbell) then obspos_deg= [  37.8732d0, 122.2573]

;ARECIBO
if keyword_set( arecibo) then obspos_deg= [  18.353944d0, 66.753000d0]

;GBT
if keyword_set( gbt) then obspos_deg= [  38.4331d0, 79.8397d0]

;COORDS FROM .STATION FILE...
IF KEYWORD_SET( PATH) THEN BEGIN
        station, northlat, eastlong, path=path
        obspos_deg= [ northlat, -eastlong]
     ENDIF

;COORDS FROM NLAT, WLONG INPUT...
if n_elements( nlat) ne 0 and n_elements( wlong) ne 0 then $
  obspos_deg= [nlat, wlong]

;=======================================================================
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






