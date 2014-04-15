pro fitscan, pos, pwr, sigma, $
	zro1, hgt1, cen1, wid1, $
	sigzro1, sighgt1, sigcen1, sigwid1, problem, cov, indxy

;+ pro fitscan  fits gaussian to one d scans. you can kill points
;
;PURPOSE: Take the data from a 1-d scan over the source and fit a Gaussian. 
;	the fitted parameters are returned.
;
;INPUTS:
;
;	POS: the positions at which the data are taken
;	PWR: the powers.
;
;OUTPUTS:
;
;	ZRO1, HGT1, CEN1, WID1: the zro level and three Gauss params.
;	SIG... the uncertainties in the Gauss params.
;
;	units of zro and hgt are system power (volts from hp voltmeter)
;	units of cen are degrees offset from the source
;	units of wid1 are degrees
;-

common plotcolors

indxy= indgen( n_elements( pwr))

plot, pos, pwr, psym=-4, /xsty, /ysty

carlkill, pos, pwr, indxy

ntot= n_elements( indxy)
indxmid= ntot/2.
zro0= mean( [pwr[ indxy[0]], pwr[ indxy[ntot-1]]])
hgt0= pwr[ indxy[indxmid]]- zro0
cen0= pos[ indxy[indxmid]]
wid0= 2.5

gcurv, pos[indxy], zro0, hgt0, cen0, wid0, tguess
oplot, pos[indxy], tguess, psym=-2, color=red

gfit, -1, pos[indxy], pwr[indxy], zro0, hgt0, cen0, wid0, tfit, sigma, $
	zro1, hgt1, cen1, wid1, $
	sigzro1, sighgt1, sigcen1, sigwid1, problem, cov

oplot, pos[ indxy], tfit, psym=-2, color=green
print, zro0,hgt0[0],cen0[0],wid0[0]
print, zro1,hgt1[0],cen1[0],wid1[0]
print, sigzro1,sighgt1[0],sigcen1[0],sigwid1[0]

return
end

