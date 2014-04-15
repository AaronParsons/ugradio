pro fitazcoeffs, nrdish, fit_arr, coeffs, sigcoeffs, sigma, cov, t, yfit

common plotcolors

;purpose: fit AZ pointing coeffs to gauss fit centers.

ndata= n_elements( fit_arr)/2
ncoeffs= 2

t= fit_arr[ nrdish,*].cen1[ 1]

s= fltarr( ncoeffs, ndata)
s[ 0,*]= 1.
s[ 1,*]= 1./ cos( !dtor* fit_arr[ nrdish].dishalt[ 0])

ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
bt = s ## a
resid = t - bt
yfit = reform( bt)
sigsq = total(resid^2)/(ndata-ncoeffs)
sigarray = sigsq * ssi[indgen( ncoeffs)*( ncoeffs+1)]
sigcoeffs = sqrt( abs(sigarray))
coeffs = reform( a)
sigma = sqrt(sigsq)

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen( ncoeffs)*( ncoeffs+ 1)]
doug = doug#doug
cov = ssi/sqrt(doug)

;wset,0
;plot, fit_arr[nrdish,*].dishalt[ 0], t, psym=-4, $
;	/ysty, xtit='DISHALT', ytit='AZ OFFSET'
;oplot, fit_arr[nrdish,*].dishalt[ 0], yfit, psym=-4, color=red

return
end
