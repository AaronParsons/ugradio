function ilst, juldate=juldate,  $
   path=path, nlat=nlat, wlong=wlong, obspos_deg=obspos_deg

;+
; NAME: 
;       ilst 
;
; PURPOSE: 
;       returns the current lst in decimal hours
;
; EXPLANATION: 
;       this function uses the system time and the user's
;       .station file to find the current lst.
;
; CALLING SEQUENCE:
;       result=ilst([juldate=julddate])
;
; INPUTS: none
;
; OPTIONAL INPUTS 
;       juldate = (julian date). The full julian date, not the modified.
;
; OPTIONAL INPUTS:
;       nlat, wlong - specify nlat and wlong of obs in
;               degrees.  if you set one, you must set the other also.
;               program uses EAST long, converts the input WEST long 
;               to EAST internally. 
;       path - path for the station file. If both (nlat, wlong) and
;               (path) are specified, then (nlat, wlong) overrules.
;               if path is specified, it reads (nlat, elong) from the
;               file path + .station. NOTE **EAST** LONGITUDE IS
;               CONTAINED IN THE .STATION FILE (We convert to wlong
;               here)!! If (nlat, wlong) or path is not
;               specified, THE DEFAULT NLAT, WLONG ARE LEUSCHNER
;               (northlat=37.8732  eastlong=-122.2573)   
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
;       path; default is Arecibo.
;
; EXAMPLES:
;      print, ilst()      ;gives the Local Sidereal Time for UCB
;      print, ilst(juldate=2454140.5)   ;(the LST for UCB on jd=2454140.5)=1.0967372
;
; REVISION HISTORY: 
;       greatly hacked of original version by ES (shiro@ugastro), 5/2001
;       20 march 07: CH cleaned up, corrected documentation, added 
;       observatory-coordinate optional input.
;-

;CAMPBELL COORDS...
NORTHlat=37.8732  ;campbell
WESTlong=+122.2573  ;campbell
obspos_deg= [ northlat, westlong]

;COORDS FROM .STATION FILE...
IF KEYWORD_SET( PATH) THEN BEGIN
        station, northlat, eastlong, path=path
        obspos_deg= [ northlat, -eastlong]
ENDIF

;COORDS FROM NLAT, WLONG INPUT...
if n_elements( nlat) ne 0 and n_elements( wlong) ne 0 then $
  obspos_deg= [nlat, wlong]

long= -obspos_deg[1]

if keyword_set(juldate) eq 0 then juldate=systime(/utc,/julian)

ct2lst,lst,long,dummy,juldate

;get sixty equiv of lst if asked for
if keyword_set(hms) then lst=sixty(lst)

if keyword_set( debug) then begin
print,'northlat, eastlong:', lat, long
if n_elements( datearr) ne 0 then print,'datearr',datearr
print,'lst: ', lst
endif

return,lst
end

