pro fourier_interpolate, vin, tin, vout, tout

;+
;CALLING SEQUENCE
;       FOURIER_INTERPOLATE, vin, tin, vout, tout
;
;PURPOSE
;Fourier interpolate the velocities on one spectrum to those on another.

;INPUTS
;VIN, the original array of uniformly-spaced velocities
;TIN, the original intensity array
;VOUT, the desired array of velocities on output, any spacing/arrangement
;
;OUTPUT
;TOUT, the intensities evaluated at VOUT.
;
;RESTROCTONS:
;n_elements(vin) must be even
;-

nel= n_elements( vin)
;vin_0= vin[ nel/2- 1]
del_fvin= (max(vin)- min(vin))/(nel- 1)
fsmpl= 1./del_fvin
f_vin= (findgen( nel)- nel/2+1)* fsmpl/nel

dft, vin, tin, f_vin, f_tin
dft, f_vin, f_tin, vout, tout, /inverse
;dft, f_vin, f_tin, vin, tin_t, /inverse

;stop

end
