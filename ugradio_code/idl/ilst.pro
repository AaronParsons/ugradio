function ilst, juldate=juldate,  $
   path=path, nlat=nlat, wlong=wlong, obspos_deg=obspos_deg, $
               arecibo=arecibo, gbt=gbt, campbell=campbell
;+
; NAME: 
;       ilst -- return current or julday-specified LST
;
; CALLING SEQUENCE:
; result = ILST([juldate=juldate]), $ 
;      path=path, nlat=nlat, wlong=wlong, gbt=gbt, $
;       campbell=campbell, arecibo=arecibo, obspos_deg=obspos_deg
;
; INPUTS: none
;
; OPTIONAL INPUTS 
;       juldate = (julian date). The full julian date, not the modified.
;               juldate = JULDAY(Month, Day, Year, Hour, Minute, Second
;
; OPTIONAL INPUTS:
;       campbell: calc for campbell
;       arecibo: calc for arecibo.
;       gbt: calc for gbt.
;       nlat, wlong - specify nlat and wlong of obs in
;               degrees.  if you set one, you must set the other also.
;               program uses EAST long, converts the input WEST long 
;               to EAST internally. 
;
;       If nlat and wlong ARE NOT SET, it uses !obsnlat and !obswlong
;
;       path - path for the station file. If both (nlat, wlong) and
;               (path) are specified, then (nlat, wlong) overrules.
;               if path is specified, it reads (nlat, elong) from the
;               file path + .station. NOTE **EAST** LONGITUDE IS
;               CONTAINED IN THE .STATION FILE (We convert to wlong
;               here)!! 
;
;If (nlat, wlong), path, or observatory name is not
;               specified, THE DEFAULT NLAT, WLONG ARE the system ones
;               $obsnlat, $obswlong
;
;KEYWORD PARAMETERS
;       /hms - causes the output to be an array
;              of [h,m,s] 
;                           
;       /debug - compares this lst to the results
;                of a call to the unix program 'LST'
;                           
; OUTPUTS: 
;       the lst for the julian date specified; default is current.
;          
; OPTIONAL OUTUTS:
;       /obspos_deg: observatory [nlat, wlong] in degrees that was used
;       in the calculation. This is set by either (nlat and wlong) or
;       path; DEFAULT IS OBSPOS_DEG= [ !OBSNLAT, !OBSWLONG]
;
; EXAMPLES:
;      print, ilst()      ;gives the current Local Sidereal Time 
;      print, ilst(juldate=2454140.5) for !obsnlat, !obswlong 
;               on jd=2454140.5)=1.0967372
;
; REVISION HISTORY: 
;       greatly hacked of original version by ES (shiro@ugastro), 5/2001
;       20 march 07: CH cleaned up, corrected documentation, added 
;       observatory-coordinate optional input.
;       09 jul 2016: CH added 'use !obsnlat and !obswlong' as default if 
;               observatory coords are not otherwise defined
;-

;FROM SYSTEM VARIABLES (DEFAULT)
obspos_deg= [ !obsnlat, !obswlong]

;campbell
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

;------------------
;in the end, it uses the longitude in obspos_deg, which must be Wlong...
long= -obspos_deg[1]

if keyword_set(juldate) eq 0 then juldate=systime(/utc,/julian)

ct2lst,lst,long,dummy,juldate

;get sixty equiv of lst if asked for
if keyword_set(hms) then lst=sixty(lst)

if keyword_set( debug) then begin
print,'northlat, eastlong:', lat, long
print,'lst: ', lst
endif

return,lst
end

