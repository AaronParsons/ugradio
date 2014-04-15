;+
; NAME: followsun1
;
; PURPOSE: 
;       keeps the dishes pointed at the sun and measures the power
;       from each repeatedly
;
; EXPLANATION:
;
; CALLING SEQUENCE: followsun,edat,wdat,[timer,filename=filename]
;
; INPUTS: 
;
; OPTIONAL INPUTS: 
;       timer - number of minutes to run; defaults to 30
;       filename - a string for a file into which edat and wdat will
;                  be saved
;
; OPTIONAL INPUT KEYWORDS: 
;
; OUTPUTS: 
;       edat - an array of power levels for the east dish
;       wdat - an array of power levels for the west dish
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED:
;
; REVISION HISTORY:  Erik Shirokoff, 7/2001
;-

pro followsun1,edat,wdat,timer,filename=filename,nomove=nomove

if n_params() le 2 then timer=2.

tmax=timer*60.

t0=systime(/sec)
nr=0L
flag=0

while flag eq 0 do begin
print,nr

if keyword_set(nomove) eq 0 then begin
    aasun,alt,az,/aa 
    a=point2(alt=alt,az=az,/verbose)
endif


junk=spc(/xon)
wait,4
a=spc(/dvm)
wait,1
junk=spc(/xoff)
wait,4
b=spc(/dvm)
wait,1

if nr eq 0L then begin
    edat=[a]
    wdat=[b]
endif else begin
    edat=[edat,a]
    wdat=[wdat,b]
endelse

nr=nr+1

if nr mod 25 eq 0 then begin
    if keyword_set(filename) then begin
    save,filename=filename,edat,wdat
    endif
endif


dt=systime(/sec)-t0
if dt ge tmax then flag=1
print,'minutes so far:',dt/60.

endwhile

if keyword_set(filename) then begin
save,filename=filename,edat,wdat
endif

;dat=fltarr(n_elements(edat),2)
;dat[*,1]=edat
;dat[*,0]=wdat
;print,'dat[*,0]=west'
;print,'dat[*,1]=east'
;dat=[transpose(edat),transpose(wdat)]

if keyword_set(filename) then begin
    save,filename=filename,edat,wdat
endif

end



