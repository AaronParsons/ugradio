pro pspec_to_acf, freqs, pspec, taus, acf, pspecx=pspecx, meters=meters, $
        no_normalize=no_normalize

;+ 
;NAME: PSPEC_TO_ACF -- given a power spectrum, calc the acf from whence
;                      it came
;CALLING SEQUENCE:
;       pspec_to_acf, freqs, pspec, taus, acf, pspecx=pspecx, meters=meters
;INPUTS:
;       FREQS, the array of frequencies (MHz) of the pwr spectrum points
;       PSPEC, the input power spectrum
;
;KEY WORDS:
;       NO_NORMALIZE: The ACF is normalized so that its value at 
;               zero delay is unity, which corresponds to the usual
;                defintion of a correlation function. If NO_NORMALIZE
;                is set, it is not normalized; in this case, you can
;                get the ACF with PSPEC_TO_ACF, modify the ACF (e.g. zero
;                out a particular channel to get rid of ripple), and 
;                calculate the corrected powerr spectrum using 
;                ACF_TO_PSPEC and the un-normalized ACF, to recover the 
;                corrected power spectrum. 
;
;OUTPUTS: 
;       TAUS, the array of delays of the output ACF (microsec)
;       ACF, the autocorrelation function
;
;OUTPUT KEY WORDS
;       METERS, the array of light-travel distances correspondng to TAUS
;       PSPECX, the symmetrized pspec used to calculate the acf. 
;
;HISTORY: CH july 2016, origin from earlier software
;-

n1024= n_elements( pspec)
n2048 = 2l * n1024
n1023 = n1024 - 1l
n1025 = n1024 + 1l
n2047 = n2048 - 1l

;DEFINE THE ACF TAUS AND METERS VECTORS...
freqres= (max(freqs)- min(freqs))/( n1024-1l)
taus= (0.5d0/ freqres)* (dindgen( n1024)/n1024)
meters= 3.e8* taus * 1.e-6

;now calc the ACF...
acf = fltarr( n1024)

;SYMMETRIZE THE POWER SPECTRUM...
pspecx = fltarr(n2048)
pspecx[0:n1023] = pspec
pspecx[n1025:n2047] = reverse(pspec[1:n1023])
pspecx[n1024] = 0.5 * (pspecx[n1023] + pspecx[n1025])

acf = float( (fft(pspecx, /inverse))[0:n1023])

if keyword_set( no_normalize) eq 0 then acf= acf/acf[0]

return
end
