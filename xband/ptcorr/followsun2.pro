;+
; NAME: followsun2
;
; PURPOSE: causes the dishes to stand still and lets the sun pass
; overhead. repeatedly samples the power level from each dish.
;
; EXPLANATION: points dishes to where the sun will be at the center of
; the time interval given
;
; CALLING SEQUENCE: followsun2,edat,wdat,[timer,filename=filename]
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

pro followsun2,edat,wdat,timer,filename=filename



if n_params() le 2 then timer=30.

tmax=timer*60.

t0=systime(/sec)

jdstart=jdnow()
jdcenter=jdstart+double(timer)/(2d0*60d0*24d0)

daycnv,jdcenter,yr,mn,day,hr
darr=[yr,mn,day,sixty(hr)]
dstr=makedate(darr,/undo)
aasun,alt,az,/aa,ut=dstr[0],date=dstr[1]

s0=point2(alt=alt,az=az,/verbose)
print,s0

nr=0L
flag=0
while flag eq 0 do begin
print,''
print,nr

dt=systime(/sec)-t0
print,'minutes so far:',dt/60.
aasun,altnow,aznow,/aa
print,'sunposition now:',altnow,aznow
print,'sunposition then:',alt,az

if dt ge tmax then flag=1

junk=spc(/xon)
wait,4
a=spc(/dvm)
c=spc(oms='aa re')
wait,1
junk=spc(/xoff)
wait,4
b=spc(/dvm)
d=spc(oms='aa re')
wait,1

print,c
print,d


if nr eq 0L then begin
    edat=[a]
    wdat=[b]
    eoms=[c]
    woms=[d]
endif else begin
    edat=[edat,a]
    wdat=[wdat,b]
    eoms=[eoms,c]
    woms=[woms,d]
endelse

nr=nr+1

if nr mod 25 eq 0 then begin
    if keyword_set(filename) then begin
    save,filename=filename,edat,wdat,eoms,woms
    endif
endif


endwhile

dat=fltarr(n_elements(edat),2)
dat[*,1]=edat
dat[*,0]=wdat
print,'dat[*,0]=west'
print,'dat[*,1]=east'
;dat=[transpose(edat),transpose(wdat)]

end
