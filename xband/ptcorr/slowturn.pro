;+
; NAME: slowturn
;
; PURPOSE: rotates the dishes slowly in az using POINT rather than TRACK
;
; EXPLANATION: non general routine used to explore the 5 degree az offset
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; OPTIONAL INPUT KEYWORDS:
;
; OUTPUTS: 
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED
;
; REVISION HISTORY: ES, 7/2001
;-

pro slowturn

min=50.  
max=70.
az=100
d=1.

azo=az

a=systime(/sec)
;surehome

wait,45
for nr=2,2 do begin
wait,15
az=azo+nr*10.

;loop for turning
flag=0
alt=min
while flag eq 0 do begin
print,'alt,az',alt,az
a=point2(alt=alt,az=az)
wait,1
spawn,'echo oms re rp |sendpc node=quasar',s
print,s
alt=alt+d
if alt gt max then flag=1
endwhile

endfor

end








