;+
; NAME: checkaz1
;
; PURPOSE: compares azes returned by scanner to the text of hte jpl
; ephemeris calculator
;
; EXPLANATION: must be changes to reflect correct files before using.
; also, you should replace all the non numbers with spaces in emacs first
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

pro checkaz1,jd,az,outeaz,outejd

;readcol,'~/temp/test1.txt',ejd,eaz,ealt,era,edec,format='d,f,f,f,f'
;save,filename='~/temp/test1.sav',ejd,eaz,ealt,era,edec
restore,'~/temp/test1.sav',/verbose

;plot,ejd,/xs,/ys
;oplot,jd,color=red

num=n_elements(az)

outeaz=fltarr(num)
outejd=dblarr(num)


for nr=0,num-1 do begin

diff=abs(ejd[*]-jd[nr])
idx=where(diff eq min(diff))
outeaz[nr]=eaz[idx]
outejd[nr]=ejd[idx]

;help,diff
;print,idx


endfor

diff=outeaz-az
plot,outeaz,diff,ps=4,ytitle='jpl ephemeris calculator - recorded az',xtitle='recorded az' 

end


