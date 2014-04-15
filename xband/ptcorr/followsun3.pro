;+
; NAME: followsun3
;
; PURPOSE: reads in data from followsun2 and plots it 
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
; REVISION HISTORY: ES, 7/2001
;-


pro followsun3,filename,noreturn=noreturn

restore,filename,/verbose

eavg=avg(edat)
wavg=avg(wdat)

print,'plotting the actual power deviation of each dish. (pwr-avg(pwr))'
print,' White=east, red=west.'

ae=edat-eavg
aw=wdat-wavg
mm=minmax([ae,aw])
plot,ae,psym=-2,yr=[mm[0],mm[1]],title='actual power deviation'
oplot,aw,color=255,psym=-2
print,'average power levels: east,west:',eavg,wavg

if keyword_set(noreturn) then print,stopitnow

;print,'press any key to continue'
;junk=get_kbrd(1)

;print, 'plotting fractional power deviation (pwr / avg(pwr))
;be=edat/eavg-1.
;bw=wdat/wavg-1.
;mm=minmax([be,bw])
;plot,be,psym=-2,yr=[mm[0],mm[1]],title='actual power deviation'
;oplot,bw,color=255,psym=-2

end





