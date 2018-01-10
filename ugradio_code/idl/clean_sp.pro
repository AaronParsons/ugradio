pro clean_sp, dirty_input, wfcn, indx_wfcn_zero, gain, niter, $
	clean_comp, clean_output, maxindx= maxindx
;+
;PURPOSE: DO CLEAN ON DATA, USING PSF.
;
;INPUTS:
;XDATA, the x values of the data, a 1 d array of length M
;DATA, the data stream, a 1 d array of length M
;PSFFCN, a function name that evaluates the psf
;GAIN, the loop gain
;NITER, the nr of iterations to do 
;
;OUTPUTS:
;CLEAN_COMP, the list of clean components. A 2-d array of size
;	2 X NITER. SECOND comp is amplitude actually subtracted, 
;	FIRST is the position xdata.
;	DATA_CLEAN, the current version of the cleaned data
;-

dirty= dirty_input

if ( n_elements( clean_comp) eq 0) then begin
	indx_niter= 0
	clean_comp= complexarr( 2, niter)
endif else begin
	indx_niter= n_elements( clean_comp)/2
	clean_comp= [ [clean_comp], [complexarr(2, niter)]]
endelse

range= indgen( n_elements( dirty_input))
;range= 1+ indgen( n_elements( dirty_input)- 1 )
if ( n_elements( maxindx) ne 0) then begin
	if ( maxindx gt 0) then range= indgen(maxindx+1)
;	if ( maxindx gt 0) then range= 1+ indgen(maxindx)
endif

for nr=0, niter-1 do begin
peak= max( abs( dirty[ range]), indx_peak)
dirty_fake=  dirty[ indx_peak]*shift( wfcn, 1+ indx_wfcn_zero+ indx_peak) + $
	conj( dirty[ indx_peak])* shift( wfcn, 1+ indx_wfcn_zero- indx_peak)
dirty= dirty- gain* dirty_fake
dirty[ 0]= complex( 0., 0.)
;clean_comp[ 1, indx_niter+ nr]= gain* dirty[ indx_peak]
clean_comp[ 1, indx_niter+ nr]= gain* dirty_fake[ indx_peak]
clean_comp[ 0, indx_niter+ nr]= indx_peak
endfor

clean_output= dirty

;print, 'indx_peak in cleansp.pro is ', indx_peak
;stop
return
end

