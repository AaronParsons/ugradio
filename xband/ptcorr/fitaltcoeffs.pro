pro fitaltcoeffs, nrdish, fit, coeffs, sigcoeffs, sigma, cov, t, yfit

common plotcolors

;purpose: fit ALT pointing coeffs to gauss fit centers.

ndata= n_elements( fit)/2
ncoeffs= 4

t= fit[ nrdish,*].cen1[ 0]

s= fltarr( ncoeffs, ndata)
s[ 0,*]= 1.
s[ 1,*]= cos( !dtor* fit[ nrdish].dishalt[ 1])
s[ 2,*]= cos( !dtor* fit[ nrdish].dishaz[ 1])
s[ 3,*]= sin( !dtor* fit[ nrdish].dishaz[ 1])

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

;wset,1
;plot, fit[nrdish,*].dishalt[ 1], t, /ysty, psym= -4, $
;	xtit='DISHALT', ytit='ALT OFFSET'
;oplot, fit[nrdish,*].dishalt[ 1], yfit, psym= -4, color=red
;
;wset,2
;plot, fit[nrdish,*].dishaz[ 1], t, /ysty, psym= -4, $
;	xtit='DISHALT', ytit='ALT OFFSET'
;oplot, fit[nrdish,*].dishaz[ 1], yfit, psym= -4, color=red

return
end
