pro fft_fltr, in, length, out, $
              inplace=inplace, truncate=truncate, expand=expand, $
              outimag=outimag
;+
; NAME: fft_fltr -- produce a fourier-filtered version of input array
;
;
;
; PURPOSE: FFT the input; either zero beyond length L or pad with zeros
; to length L; when degrading resolution, option to truncate so that nr
; of points in output is also reduced.
;
;
;
; CATEGORY: sig_pocessing
;
;
;
; CALLING SEQUENCE:
; fft_fltr, in, length, out, $
;              inplace=inplace, truncate=truncate, expand=expand, $
;              outimag=outimag
;
; INPUTS:
;IN, the input array. nr elements should be EVEN.  Note the keyword INPLACE.
;
;LENGTH, the length to zero (or pad to). should be EVEN
;
; KEYWORD PARAMETERS:
;TRUNCATE; if set, reduce nr of points in output.
;
;EXPAND: if set, don't filter but, instead, increase the length of the
;original IN vector to LENGTH.
;
;INPLACE, replace 'in' by its smoothed counterpart. You cannot set
;INPLACE and, also, TRUNCATE or EXPAND because the latter two change the
;length!
;
; OUTPUTS:
;OUT, the filtered or fourier-interpolated version of IN. real part
;only. Note the keyword INPLACE.
;
; OPTIONAL OUTPUTS:
;OUTIMAG, the imaginary part of out. should consist only of numerical noise.
;
;
; EXAMPLE: You have a freq array with 16 elements and, in the Fouier
; transform domain, you want to filter out the upper half of the
; delays and reduce the nr of elements in the freq array
; accordingly. then... 
;
;    FFT_FLTR, freqarray, 8, out, /truncate
;
; MODIFICATION HISTORY:
; CH, 23 may 2007
;-

if keyword_set( inplace) then begin
if keyword_set( truncate) or keyword_set( expand) then begin
    print, 'you cannot set INPLACE and also TRUNCATE or EXPAND!!!
    return
endif
endif

nch= n_elements( in)
if length gt nch then GOTO, EXPAND

nch2= nch/2l
length2= length/2l
cut= nch- length
cut2= cut/2l

if length eq nch then begin
out=in
return
endif

infft= fft( in)

if keyword_set( truncate) eq 0 then begin
;IF WE RETAIN THE NR OF POINTS, THEN WE ZERO THE ENDS...
infftmod= [ infft[ 0l:length2], complexarr( cut-1l), infft[ nch-length2:nch-1l ]]

endif else begin

;IF WE TRUNCAATE, THEN WE DELETE THE ENDS...
infftmod= [infft[ 0l:length2], infft[ nch-length2+1l:nch-1l]]
infftmod[ length2]= complex( float(infftmod[ length2]), 0.)
endelse

;TAKE THE INVERSE FFT OF THE MODIFIED INFFT...
infftmofft= fft( infftmod, /inverse)

;MAKE SURE IMAG COMPONENTS ARE SMALL...
;print, 'real', minmax( float( infftmofft))
;print, 'imag', minmax( imaginary( infftmofft))

out= float( infftmofft)
if keyword_set( inplace) then in= out
;stop

return

EXPAND:
nch2= nch/2l
cut= length- nch
cut2= cut/2l
length2= length/2l
infft= fft( in)

infftmod= [ infft[ 0l:nch2], complexarr( cut-1l), infft[ nch-nch2:nch-1l ]]

infftmofft= fft( infftmod, /inverse)

;MAKE SURE IMAG COMPONENTS ARE SMALL...
;print, 'real', minmax( float( infftmofft))
;print, 'imag', minmax( imaginary( infftmofft))

out= float( infftmofft)
outimag= imaginary( infftmofft)

;stop

return

end
