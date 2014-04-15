;+
; NAME: rmscut
;
; PURPOSE: returns the indices of points where the rms value is
; unusually large
;
; EXPLANATION: trims points which are more than a numebr of standard
; deviations from the mean twice
;
; CALLING SEQUENCE: rmscut,rms,nsd
;
; INPUTS:rms - the array of points
;
; OPTIONAL INPUTS: nsd - the number of standard devs
;
; OPTIONAL INPUT KEYWORDS:
;       /keep - returns the good points instead of the bad ones
;
; OUTPUTS: the index of bad points
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED
;
; REVISION HISTORY:
;-
function rmscut,rms,nsd,keep=keep

;CONSTANTS
if n_params() le 1 then nsd=3 ; number of standard devs to use in trimming

;hitbin=.01 ; size of binning for histogram
;a=histogram(a,binsize=histbin)
;b=float(total(a,/cumulative))
;c=float(total(a))
;d=b/c
;idx=where(a d ge .9)

a=moment(rms)
b=abs(rms-a[0])
firstidx=where(b ge nsd*a[1])

c=moment(rms[firstidx])
d=abs(rms-c[0])
idx=where(d ge nsd*c[1])
if keyword_set(keep) then idx=where(d le nsd*d[1])

return,idx


end
