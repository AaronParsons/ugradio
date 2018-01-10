function hannfcn, input, hanning
;+
;FUNCTION TO HANNING SMOOTH. TO CALL:

;	output = hannfcn( input, hanning)

;	hanning is optional. if not specified, smoothing is done.
;	if zero, no smooothing; nonzero smoothing is done.
;-

if (n_elements(hanning) eq 0) then hanning=1

if (hanning ne 0) then begin
han=[0.25,0.5,0.25]
output = convol( input, han, /edge_truncate)
return, output
endif else return, input
end
