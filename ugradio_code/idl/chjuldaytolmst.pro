;+
;NAME:
;chjuldaytolmst - julian day to local mean sidereal time.
;SYNTAX: lmst=chjuldaytolmst(juldat,obspos_deg=obspos_deg)
;  ARGS:
;  julday[n]: double julian day
;
;KEYWORDS:
;   obspos_deg[2]: double [northlat,westLong] of observatory in degrees. 
;def=ao. WARNING: if obspos_deg is defined, it uses these values. it's 
;not a keyword set!
;
;RETURNS:
;   lmst[n]: double local mean sidereal time in radians.
;
;DESCRIPTION
;
; Convert from julian day to local mean sidereal time. By default the
;latitude,long of AO is used.
;
; If you need local apparent sidereal time, then add the equation of the
;equinox to these values (see nutation_m()).
;-
function chjuldaytolmst,juldat,obspos_deg=obspos_deg

IF (N_ELEMENTS( OBSPOS_deg) EQ 0) THEN $
	obsWestLongFract  = (4.D +  27./60. + .720D/3600.D)/24. $
	ELSE obsWestLongFract= obspos_deg[ 1]/360.d
;stop
    if not keyword_set(eqEquinox) then eqEquinox=0.
    JULDAYS_IN_CENTURY=36525.D
    JULDATE_J2000     = 2451545.D
    SOLAR_TO_SIDEREAL_DAY= 1.00273790935D
    istat=utcinfoinp(mean(juldat),utcinfo)

;   julian day starts at noon. get utc frac at midnite
;   we will compute the sidereal time for 0 hours Ut then add 
;   on the fraction of a day utcFrac + utcToUt1
;
    utcFrac  =(juldat - .5D) mod 1.D
    juldat0Ut=long(juldat - .5D) + .5D  ; juldat at 0 hours utc
;
;      go utc fract to ut1 fract
;
        ut1Frac= utcFrac + utcToUt1(julDat,utcInfo)
        ind=where(ut1Frac lt 0.,count)
        if count gt 0 then begin
            ut1Frac[ind]=ut1Frac[ind] +1.
            juldat0Ut=juldat0Ut - 1L
        endif
        ind=where(ut1Frac ge 1.,count)
        if count gt 0 then begin
            ut1Frac[ind]=ut1Frac[ind] -1.
            juldat0Ut=juldat0Ut + 1L
        endif
;
; fraction of julian centuries till j2000
; TU is measured from 2000 jan 1D12H UT
;
        Tu= (juldat0Ut - JULDATE_J2000)/JULDAYS_IN_CENTURY
;
;     gmst at 0 ut of date in sidereal seconds
;        
        gmstAt0Ut=24110.54841D + Tu*(8640184.812866D + $
                                 Tu*(.093104D        - $
                                 Tu*(6.2d-6)))
;
;  convert to fraction of a day, add on user fract and throw away
;  integer part
;
    dfract=(gmstAt0Ut/86400.D + ut1Frac*SOLAR_TO_SIDEREAL_DAY - $
                     obsWestLongFract) mod 1.d
    ind=where(dfract lt 0.D,count)
    if count gt 0 then dfract[ind]=dfract[ind] + 1.d
    lmstRd=dfract*2.*!dpi    
    return,lmstRd
end
