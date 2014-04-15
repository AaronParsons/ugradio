;+
; NAME: lstnow
;
; PURPOSE: returns the current lst
;
; EXPLANATION: the NEW version calles ilst. 
;
;the OLD version did it all itself and is now called lstnow_old. 
;
;this function uses the system time and the user's
; .station file to find the current lst.
;
;NOTE that this uses ct2alst, not ct2lst. ct2alst uses long EAST of greenwich.
;
; CALLING SEQUENCE: result=lstnow([/hms,/debug,/verbose])
;
; INPUTS: non required
;
; OPTIONAL INPUT KEYWORDS:  /hms - causes the output to be an array
;                                  of [h,m,s] 
;                           /debug - compares this lst to the results
;                                    of a call to the unix program
;                                    'LST'
;                           /verbose - prints out some extra stuff
;
;
; OUTPUTS: the current lst, as a floating decimal hour by default
;          
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED: station, ct2lst (goddard)
;
; REVISION HISTORY: by ES (shiro@ugastro), 5/2001
;

function lstnow,verbose=verbose,hms=hms,debug=debug

verby=keyword_Set(verbose)
if keyword_set(debug) then begin
    verby=1
    hms=1
endif


;LETS GET THE UT DATE AND TIME NOW
lst= ilst()
;ct2Alst,lst,long,0,time,date[2],date[1],date[0]
if verby then print,'lst:',lst

;stop

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










