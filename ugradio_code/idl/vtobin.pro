function vtobin, vlsr, v
;+
; NAME:
;   vtobin
;     
; PURPOSE:
;   Finds the bin number(s) in a velocity vector closest to some v.
;     
; CALLING SEQUENCE:
;   bin = vtobin(vlsr, v)
;     
; INPUTS:
;   vlsr : velocity vector
;   v    : velocity or velocities whose corresponding bins you want
;     
; REVISION HISTORY:
;   17-Nov-2000 Written T. Robishaw, Berkeley
;-

; HOW MANY BINS ARE WE LOOKING FOR...
nbins = N_elements(v)
bin   = lonarr(nbins, /NOZERO)

; FIND THE INDEX OF THE MINIMUM OF THE ABSOLUTE DIFFERENCE...
for i = 0L, nbins-1L do begin
    useless = min(abs(vlsr-v[i]),minindx)
    bin[i]  = minindx
endfor

; GUARANTEE THAT A SINGLE BIN WILL NOT BE OUTPUT AS AN ARRAY...
if (nbins eq 1) then return, bin[0]

return, bin

end ; vtobin
