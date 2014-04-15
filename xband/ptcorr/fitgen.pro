;+
; NAME: fitgen
;
; PURPOSE: generates the s arrays used by aafit (pointfit, analyze, etc.)
;
; EXPLANATION: 
;
; CALLING SEQUENCE:
;
; INPUTS:
;       alt - array in degrees
;       az - array in degrees
;       aac - 0 for alt, 1 for az
;       rev - an array of 1 or -1
;
; OPTIONAL INPUTS:
;
; OPTIONAL INPUT KEYWORDS:
;       /constant - see analyze.pro docs
;
; OUTPUTS:
;       s - a [2,n] array used in fitting
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED
;
; REVISION HISTORY: 
;       Erik Shirokoff,7/2001
;       Changed sign of alt dial offset, ES, Aug 6, 2001
;-

;FIRST, A GOOFY LITTLE PROGRAM TO MAKE OUR FITTING FUNCTIONS
function fitgen,alt,az,aac,rev=rev,constant=constant
num=n_elements(alt)
s=fltarr(2,num)
;       az fitting
if aac eq 2 then begin
    if keyword_set(constant) then begin
        s[0,*]=1
        s[1,*]=0.0
    endif else begin
        s[0,*]=1
        s[1,*]=rev*1./cos(alt*!dtor)            
    endelse
endif else begin
;       alt fitting
    if keyword_set(constant) then begin
        s[0,*]=1.
        s[1,*]=0.0
    endif else begin
        s[0,*]=1.
        s[1,*]=cos(alt*!dtor)            
    endelse
endelse

return,s

end








