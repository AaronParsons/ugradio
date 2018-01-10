pro acf_to_pspec, taus, acf, freqs, pspec, acfcnx=acfcnx

;+
;NAME: ACF_TO_PSPEC -- given an acf, calc the pwr spectrum
;CALLING SEQUENCE:
;       acf_to_pspec, taus, acf, freqs, pspec, acfcnx=acfcnx
;
;INPUTS:
;       TAUS, the array of delays of the output ACF (microsec)
;       ACF, the autocorrelation function
;
;OUTPUTS: 
;       FREQS, the array of frequencies (MHz) of the pwr spectrum points
;       PSPEC, the output power spectrum
;
;OUTPUT KEY WORDS
;       ACFCNX, the symmetrized ACF used to calculate PSPEC
;
;HISTORY: CH july 2016, origin from earlier software
;-

n1024= n_elements( acf)
n2048 = 2l * n1024
n1023 = n1024 - 1l
n1025 = n1024 + 1l
n2047 = n2048 - 1l

;DEFINE THE PSPEC FREQS VECTOR...
taures= (max(taus)- min(taus))/( n1024-1l)
;freqs= 0.5d0* taures* (dindgen( n1024)/n1024)
freqs= (0.5d0/ taures)* (dindgen( n1024)/n1024)

pspec = fltarr( n1024)

;symmetrize the ACF...
acfcnx = fltarr(n2048)
acfcnx[0:n1023] = acf
acfcnx[n1025:n2047] = reverse(acf[1:n1023])
acfcnx[n1024] = 0.5 * (acfcnx[n1023] + acfcnx[n1025])

pspec = float( (fft(acfcnx))[0:n1023])

return
end
