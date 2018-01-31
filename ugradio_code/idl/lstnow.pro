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

;on_error, 3
verby=keyword_Set(verbose)
if keyword_set(debug) then begin
    verby=1
    hms=1
endif

;check if nlat, nlong are definted as sysvariables...
if n_elements( !obsnlat) eq 1 then begin
   lst= ilst( nlat=!obsnlat, wlong=!obswlong)
endif else lst=ilst()

;get sixty equiv of lst if asked for
if keyword_set(hms) then lst=sixty(lst)

;catch, /cancel
return,lst
end




