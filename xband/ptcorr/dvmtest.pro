;+
; NAME: dvmtest 
;
; PURPOSE:
;       give two different voltages to the dmm and switch back
;       and forth at different rates to test the meter's
;       update speed.
;
; EXPLANATION:
;
; CALLING SEQUENCE: dvmtest,dat
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
; PROCEDURES CALLED:
;
; REVISION HISTORY:  Erik Shirokoff, 7/2001
;-

pro dvmtest,dat,time,filename=filename

tmax=4
tmin=.5
dt=.5

;THE LOOP
flag=0
nr=0
while flag eq 0 do begin
print,nr
t=tax-dt*nr
print,'t',t


aasun,alt,az,/aa 
a=point2(alt=alt,az=az,/verbose)
;str='echo point alt_w=90 |sendpc node=quasar'
;spawn,str,s
;print,s



;inner loop
a=fltarr(5)
b=fltarr(5)
for nr=0,4 do begin
junk=spc(/xon)
wait,t
a[ns]=spc(/dvm)
;wait,1
junk=spc(/xoff)
wait,t
b[ns]=spc(/dvm)
;wait,1
endfor

if nr eq 0L then begin
    dat=[a,b]
    time=(fltarr(5)+float(t))
endif else begin
    dat=[dat,a,b]
    time=[time,fltarr(5)+float(t)]
endelse

nr=nr+1



if t ge tmax then flag=1

endwhile



if keyword_set(filename) then begin
save,filename=filename,dat,time
endif

;dat=fltarr(n_elements(edat),2)
;dat[*,1]=edat
;dat[*,0]=wdat
;print,'dat[*,0]=west'
;print,'dat[*,1]=east'
;dat=[transpose(edat),transpose(wdat)]

if keyword_set(filename) then begin
    save,filename=filename,dat,time
endif

end



