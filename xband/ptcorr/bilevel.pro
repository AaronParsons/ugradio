;+
; NAME: stonehenge
;
; PURPOSE: 
;       creates a surface plot of power against az and alt
;
; EXPLANATION: 
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
; REVISION HISTORY:
;-


;plots alt and az v/s errors for a data set

pro bilevel,fname,key

filename=smartname('./',fname,'.sav')

;restore,'./28/errors.sav'
restore,filename,/verbose

if keyword_Set(key) eq 0 then key=[0,1,2,3]

for nr= 0,n_elements(key)-1 do begin
    count=key[nr]

c=out.errors[*,count]
kill=out.kill[*,count]
rev=out.reverse
a=out.expected[*,count mod 2]
b=out.expected[*,count mod 2+2]

a=a[where((kill eq 0.0) and (abs(c) le 20) and (rev eq 0.))]
b=b[where((kill eq 0.0) and (abs(c) le 20) and (rev eq 0.))]
c=c[where((kill eq 0.0) and (abs(c) le 20) and (rev eq 0.))]

;plot,a,c,ps=4
ba=fix(a)
bb=fix(b)

field=fltarr(90,360)
;field2=field

;for nr=0,n_elements(c)-1 do begin
;if bb[nr] ge 180. then field[ba[nr],bb[nr]]=-c[nr] else $
;field2[ba[nr],bb[nr]]=-c[nr]
;endfor

for nr=0,n_elements(c)-1 do begin
field[ba[nr],bb[nr]]=abs(c[nr])
endfor


;surface,field
surface,field,ax=75,az=30,/lego,xchar=3,ychar=3,font=-1,zchar=7,xr=[-5,90],/xs,xtitle='ALTITUDE',ytitle='azimuth'
junk=get_kbrd(1)
endfor


;r=get_bkrd(1)

;surface,field2,ax=75,az=30,/lego,xchar=3,ychar=3,font=-1,zchar=7,xr=[-5,90],/xs,xtitle='ALTITUDE',ytitle='azimuth'
end





