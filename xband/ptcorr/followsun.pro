;+
; NAME: followsun
;
; PURPOSE: 
;       keeps the dishes pointed at the sun
;
; EXPLANATION:
;
; CALLING SEQUENCE: followsun,timer,delay
;
; INPUTS: 
;
; OPTIONAL INPUTS: 
;       timer - number of hours to run; defaults to 48
;       delay - space between readjustments, in seconds. Defaults to 10.
;       filename - name of a file to save data to. 
;
; OPTIONAL INPUT KEYWORDS: 
;       moon - tracks the moon
;       verbose - prints useful stuff
;       home - not implimented yet
;
; OUTPUTS: 
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED:
;
; REVISION HISTORY:  Erik Shirokoff, 7/2001
;-

pro followsun,timer,delay,verbose=verbose,moon=moon,home=home,filename=filename,reverse=reverse

if n_params() eq 0 then timer=48.
if n_params() le 1 then delay=10.
verby=keyword_set(verbose)

tmax=float(timer)*60.*60.

t0=systime(/sec)
nr=0L
flag=0

while flag eq 0 do begin
print,nr
print,'hours so far:',(systime(/sec)-t0)/3600.

lst=ilst()
if keyword_set(moon) then $
  aamoon,alt,az,/aa else $
  aasun,alt,az,/aa 
a=point2(alt=alt,az=az,/verbose,reverse=reverse)
if verby then print,'alt,az:',alt,az

dt=systime(/sec)-t0
if dt ge tmax then flag=1
print,'minutes so far:',dt/60.


if nr eq 0 then begin
    lstarr=[lst]
    altarr=[alt]
    azarr=[az]
endif else begin
    lstarr=[lstarr,lst]
    altarr=[altarr,alt]
    azarr=[azarr,az]
endelse

if nr mod 25 eq 0 then begin
if keyword_set(filename) then begin
save,filename=filename,azarr,altarr,lstarr
    endif
endif

endwhile

if keyword_set(filename) then $
save,filename=filename,azarr,altarr,lstarr


end



