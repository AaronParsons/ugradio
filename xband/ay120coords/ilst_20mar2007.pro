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
; EXAMPLES:
;      print, ilst()      ;gives the Local Sidereal Time for UCB
;      print, ilst(juldate=2454140.5)   ;(the LST for UCB on jd=2454140.5)=1.0967372
;
; CALLING SEQUENCE:
;       result=ilst([juldate=julddate])
;
; INPUTS:
;       if none supplied, the current unix time is used
;       time='hh:mm:ss' - user specified UT civil time
;       date='dd:mm:yyyy' - user specified UT date.     
;
; OPTIONAL INPUT KEYWORDS: 
;       juldate = (julian date)
;
;       /hms - causes the output to be an array
;              of [h,m,s] 
;                           
;       /debug - compares this lst to the results
;                of a call to the unix program 'LST'
;                           
;       /verbose - prints out some extra stuff
;                           
;       /mlst - returns mean lst instead of
;               apparent lst
;
; OUTPUTS: 
;       the current lst, as a floating decimal hour by default
;          
; EXAMPLES: 
;       IDL> print,ilst(date='14/12/2001',time='21:49:07',/hms)
;       IDL> print,ilst()
;

; RESTRICTIONS:
;
; PROCEDURES CALLED: makedate,ct2alst,ct2lst (goddard)
;
; REVISION HISTORY: by ES (shiro@ugastro), 5/2001
;
;-
;function ilst,time=time,date=date,local=local,verbose=verbose, $
;        hms=hms,debug=debug,unixstyle=unixstyle,ut=ut,mlst=mlst,$
;        juldate=juldate

function ilst, juldate=juldate

if keyword_set(ut) then time=ut
verby=keyword_Set(verbose)
if keyword_set(debug) then begin
    verby=1
    hms=1
endif

;something=keyword_set(date)*1 + keyword_Set(time)*2

;LETS GET THE UT DATE AND TIME NOW
if n_elements(time) ne 0. then begin
datearr=makedate(time,date,local=local)
timearr=[datearr[3],datearr[4],datearr[5]]
timefl=ten(timearr)
endif


;GET THE STATION LONG
lat=37.8732  ;campbell
long=-122.2573  ;campbell
;print,'line 49 has been changed for arecibo:'
;lat=ten(18,21,14.2)
;long=-ten(66,45,18.8)
;print,lat,long
;station,lat,long

if verby then print,'lat, long:',lat,long
if verby and n_elements( datearr) ne 0 then print,'datearr',datearr

;GET THE LST
;if keyword_set(mlst) eq 0 then $
if keyword_set(time) ne 0 then begin
  if keyword_set(mlst) eq 0 then ct2alst,lst,long,0,timefl,datearr[2],datearr[1],datearr[0] $
  else ct2lst,lst,long,0,timefl,datearr[2],datearr[1],datearr[0] 
;ct2lst,lst,long,nothinghere,jd
endif

if keyword_set(juldate) eq 0 then juldate=systime(/utc,/julian)
;if keyword_set(jd) ne 0 then juldate=jd
ct2lst,lst,long,dummy,juldate

if verby then print,'lst:',lst

;get sixty equiv of lst if asked for
if keyword_set(hms) then lst=sixty(lst)

;compare to the doppler program LST
if keyword_Set(debug) then begin
spawn,'lst',unixlst
print,'from unix:',unixlst
print,'from idl:',lst
endif

return,lst
end










