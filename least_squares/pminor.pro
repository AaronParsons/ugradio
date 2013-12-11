function pminor, indices, xoriginal
;+
;PURPOSE:
;
;	extract the glorified minor from a square matrix. The glorified minor
;is defined as the intersection of all rows and columns defined by the
;incides you want to retain. Used in multiparameter ls fits.
;
;INPUTS:
;	PMINOR: the set of indices you want to retain.
;
;	XORIGINAL: the original matrix.
;
;OUTPUTS:
;	PMINOR, the glorified minor matrix.
;-


;indices = [0,3,4]
n_indices= n_elements( indices)

xnew = fltarr( n_indices, n_indices)

for m = 0, n_indices-1 do xnew[ m,*] = xoriginal[ indices[ m], indices]

return, xnew

end

