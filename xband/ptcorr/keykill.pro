;+
; NAME: keykill
;
; PURPOSE: a subroutine of azfit and altfit
;
; EXPLANATION: this procedure takes the data which will be used for
; fitting and a key corresponding to which data is to be used and
; removes all of the unwanted data points.
;
; CALLING SEQUENCE: keykill,key,delta,alt,reverse,moon,kill,outdelta,outalt,outreverse,itworked,crossdex
;
; INPUTS:   KEY: one of the following codes
;                    0 - forward sun correction
;                    1 - reverse sun correction]
;                    2 - combined f&r sun correction
;                    3 - forward moon correction
;                    4 - reverse moon correction
;                    5 - combined f&r moon correction
;                    6 - forward sun and moon correction
;                    7 - reverse sun and moon correction
;                    8 - combined f&r sun&moon correction
;
;         delta - array of the object center minus the dial reading
;         alt - array of altitude in degrees
;         reverse - an array which is 1 whenever data was taken in
;                   reverse mode and 0 when in forward mode
;         moon - an array which is 1 whenever the object was the moon
;                and zero when it was the sun
;         kill - an array which is 1 whenever a data point should NOT
;                be used for fitting, and which is 0 otherwise
; OPTIONAL INPUT KEYWORDS:
;
;          /verbose - prints some random info
;
; OUTPUTS: outdelta - delta minus the killed bits
;          outalt - alt minus the killed bits
;          outreverse - reverse minus the killed bits
;          itworked - a flag which is 1 if there were one
;                     or more data points sonsistant with
;                     key
;          crossdex - an array equal in size to outalt and containing
;                     the index number of the original index of alt
;                     which corresponds to that position in outalt
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED:
;
; REVISION HISTORY: Erik Shirokoff, 5/2001
;-

pro keykill,key,delta,alt,reverse,moon,kill,outdelta,outalt,outreverse,itworked,outdex,verbose=verbose

verby=keyword_set(verbose)


;DO THE KILL
killidx = where(kill eq 0,killk)
outdex=findgen(n_elements(alt))
;help,killidx
;help,killk
;help,delta
itworked=0
;print,'linr65 of keykill,kill',kill
if killk ne 0 then begin
    talt=alt[killidx]
    tdelta=delta[killidx]
    treverse=reverse[killidx]
    tmoon=moon[killidx]
    outdex=outdex[killidx]
    itworked=1
endif; else begin
   ; talt=[-1000.]
   ; tdelta=[-1000.]
   ; treverse=[-1000]
   ; tmoon=fltarr(2)*-1000.
;endelse
;help,key
;help,tdelta

;if key eq 0 then begin
;    !p.multi=[0,2,1]
;    plot,reverse,xtitle='reverse'
;    plot,tmoon,xtitle='moon'
;    !p.multi=[0,1,1]
;endif

;if key eq 0 then begin
;    plot,treverse,xtitle='treverse'
;    wait,3
;endif

if verby then print,'n#kills:',killidx

if itworked eq 1 then begin

;MAKE SOME USEFUL INDEXES
id0=where(tmoon eq 0 and treverse eq 0,k0)
id1=where(tmoon eq 0 and treverse eq 1,k1)
id2=where(tmoon eq 0,k2)
id3=where(tmoon eq 1 and treverse eq 0,k3)
id4=where(tmoon eq 1 and treverse eq 1,k4)
id5=where(tmoon eq 1,k5)
id6=where(treverse eq 0,k6)
id7=where(treverse eq 1,k7)
id8=where(treverse eq 1 or treverse eq 0,k8)

;help,key,id0
;print,'k0',k0

;NOW DO THE KEY MATCHING
itworked=0
if (key eq 0 and k0 ne 0) then begin
    talt=talt[id0]
    tdelta=tdelta[id0]
    treverse=treverse[id0]
    outdex=outdex[id0]
    itworked=1
;    print,'forward sun'
endif 

if (key eq 1 and k1 ne 0) then begin
    talt=talt[id1]
    tdelta=tdelta[id1]
    treverse=treverse[id1]
    itworked=1
    outdex=outdex[id1]
endif 


if (key eq 2 and k2 ne 0) then begin
    talt=talt[id2]
    tdelta=tdelta[id2]
    treverse=treverse[id2]
    itworked=1
    outdex=outdex[id2]
endif 


if (key eq 3 and k3 ne 0) then begin
    talt=talt[id3]
    tdelta=tdelta[id3]
    treverse=treverse[id3]
    itworked=1
    outdex=outdex[id3]
endif 


if (key eq 4 and k4 ne 0) then begin
    talt=talt[id4]
    tdelta=tdelta[id4]
    treverse=treverse[id4]
    itworked=1
    outdex=outdex[id4]
endif 

if (key eq 5 and k5 ne 0) then begin
    talt=talt[id5]
    tdelta=tdelta[id5]
    treverse=treverse[id5]
    itworked=1
    outdex=outdex[id5]
endif 


if (key eq 6 and k6 ne 0) then begin
    talt=talt[id6]
    tdelta=tdelta[id6]
    treverse=treverse[id6]
    itworked=1
    outdex=outdex[id6]
endif


if (key eq 7 and k7 ne 0) then begin
    talt=talt[id7]
    tdelta=tdelta[id7]
    treverse=treverse[id7]
    itworked=1
    outdex=outdex[id7]
endif 


if (key eq 8 and k8 ne 0) then  begin
    talt=talt[id8]
    tdelta=tdelta[id8]
    treverse=treverse[id8]
    itworked=1
    outdex=outdex[id8]
endif 

endif

;OKAY, WE'RE DONE. RENAME THINGS TO EXPORT
if itworked eq 1 then begin
    outdelta=tdelta
    outalt=talt
    outreverse=treverse
endif

;help,tdelta

end




