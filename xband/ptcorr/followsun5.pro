;+
; NAME: followsun5
;
; PURPOSE:
;       points one dish on the sun, one dish off, and switches back
;       and forth at different rates to test the meter's ability
;       update speed.
;
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

pro followsun5,dat,time,tmin,tmax,dt,filename=filename

if n_params() le 2 then tmin=.5
if n_params() le 3 then tmax=4.
if n_params() le 4 then dt=.5

;THE LOOP
flag=0
nr=0
while flag eq 0 do begin
print,nr
t=tmax-dt*nr
print,'t',t


aasun,alt,az,/aa 
a=point2(alt=alt,az=az,/verbose)
;str='echo point alt_w=90 |sendpc node=quasar'
;spawn,str,s
;print,s



;inner loop
a=fltarr(5)
b=fltarr(5)
for ns=0,4 do begin
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



if t le tmin then flag=1

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

!p.multi=[0,1,2]
plot,dat,yticklen=1,ygridstyle=2,xticklen=5,xgridstyle=2,color=255,/nodata
oplot,dat,ps=10
plot,time,yticklen=1,ygridstyle=2,xticklen=5,xgridstyle=2,color=255,/nodata 
oplot,time,ps=10
!p.multi=[0,1,1]
end



