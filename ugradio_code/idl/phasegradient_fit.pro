pro nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
;SETS DEFAULT OUTPUTS FOR NONCONVERGENCE CASES.
kk = dpdf/!radeg
sigkk = 0.
sa = 0.
ca = 1.
sigsa = 0.
sigca = 0.
sigarray = [0., 0., 0.]
sigma = 0.

print, 'SETTING OUTPUTS TO DEFAULTS AND RETURNING...', string(7b)
return
end

pro phasegradient_fit, frq, realpart, imagpart, dpdf_rad, $
                       coeffs, sigcoeffs, aphi, sigaphi, $
                       sigma, tfit, PROBLEM=problem, $
                       thetafit=thetafit, sigthetafit=sigthetafit
;+
;NAME:
;   PHASEGRADIENT_FIT
;    An almost identical program using degrees is DTHETA_DF_ATAN_FIT.PRO
;
;PURPOSE:

;If an angle theta (units: degrees) varies linearly with variable ff (e.g.,
; as in Faraday rotation), i.e. if
;
;                        theta = theta_0 + KK*[ff-ff_mean]
; and if
;                        theta = atan(imagpart/realpart)
; then imagpart and realpart must have functional dependences
;  imagpart = SA*cos([2*pi/360]*KK*[ff-ff_mean]) +
;       CA*sin([2*pi/360]*KK*[ff-ff_mean])
;  realpart = CA*cos([2*pi/360]*KK*[ff-ff_mean]) -
;       SA*sin([2*pi/360]*KK*[ff-ff_mean])
;
;If you have measured values for imagpart and realpart as functions of ff, and if these
;measured values have Gaussian noise, then this nonlinear fit will provide
;the fit parameters CA, SA, and KK. 

;    A three step process:
;	1. A linear fit for aareal, etc, using the guess for dpdf
;	2. A nonlinear fit for dpdf using the above values for aareal, etc.
;	3. A simultaneous onlinear fit for all five parameters.

;    In each step, bad points are tested for and discarded using the
;	criterion residual gt sigma3 * sigma.
;
;CALLING SEQUENCE:
;PHASEGRADIENT_FIT, frq, realpart, imagpart, dpdf_rad, coeffs, aphi, sigaphi, $
;	sigcoeffs, sigma, tfit
;
;INPUTS:
;     FRQ: freq, in MHz, of the XY products; offset should be
;	subtracted so that the values cluster around zero.
;     REALPART: the real part of the XY products. 
;     IMAGPART: the imaginary part of the XY products. 
;     DPDF_rad: the ESTIMATE for d(phase)d(freq), i.e. the estimate for KK.
;		THE UNITS FOR DPDF ARE --->RADIANS<--- PER MHZ.
;
;OUTPUTS:
;     COEFFS: = [CA, SA, KK]. KK is in units of --->RADIANS<--- /MHz
;     SIGCOEFFS: the uncertainties of the coefficients.
;     APHI is the phase angle at MEAN(FRQ), units RADIANS. 
;     SIGAPHI is the 1 sigma error in APHI
;     SIGMA: the mean error of the residuals. These residuals are in REALPART and
;               IMAGPART, not in the derived theta.
;     TFIT: the fitted datapoints two-element [N,2] array [[REALPART],[IMAGPART]].
;
;KEYWORD-TYPE INPUTS:
; SIGMA3, discard all points with residuals exceeding SIGMA3*SIGMA. Default
; is SIGMA3=6. These sigmas are in XX and YY, not in the derived theta.
;
; OPTIONAL OUTPUTS:
;     
;     PROBLEM is nonzero if there is a problem...value depends on the problem
;        -1, there are no points less than SIGMA3*sigma in step 1
;        -2, negative sqrts in sigarray in step 1
;        -3, Convergence problem in step 2
;        -4, negative sqrts in sigarray in step 2
;        -5, Convergence problem in 3rd stage
;     THETAFIT, the fitted values of theta in --->RADIANS<---.
;     SIGTHETAFIT is the rms of the fitted angles, units 
;       ---> RADIANS <---, calculated using the angles and not xx,yy.
;
;RESTRICTIONS:
;    As with any nonlinear least squares fit, the estimate KK_GUESS should
;       be pretty good. Zero estimates for kk_guess are not allowed. if the
;       derived value of kk during the iterations exceeds 4 times the
;       guessed value, it's a problem...
;
;HISTORY:
;	Written by Carl Heiles. 19 FEB 1999.
;	Corrected and updated 4 MAR 2000.
;       improved, better doc, aphi now for mean freqq not zeero freq. 19may08
;-

dpdf= !radeg* dpdf_rad 

;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DISCARD ALL POINTS EXCEEDING sigma3*SIGMA...
sigma3=6.

;SET NEW INTERNAL VARIABLES SO WE DON'T DISTURB THE OLD ONES...
frqmean = mean(frq)
freq=frq - frqmean
datasize = n_elements(freq)
nrgood = 2*datasize
wgt = 1. + fltarr(4, 2*datasize)

;;=================== OLD CODE HAS UNREASONABLE LIMITS ON KK
;;                    ================
;WE DEFINE A LIMIT FOR HOW ACCURATE KK MUST BE. THIS LIMIT IS
;THAT KK DOES NOT CHANGE BY MORE THAN 20 DEGREES OVER THE FITTED
;FREQUENCY RANGE.
;dpdflim = abs(20.*!dtor/(freq[datasize-1]-freq[0]))

;WE BEGIN BY ASSUMING DPDF IS CORRECT AND DOING A LINEAR FIT FOR A AND B...
;BUT FIRST, CHECK . MAKE IT NONZERO IF IT HAPPENS TO BE ZERO.
;dpdf_int = dpdf
;if (abs(dpdf_int) lt (dpdflim/40.)) then dpdf_int = dpdflim/40.

;kk= !dtor*dpdf_int
;kklim = !dtor*dpdflim
;^^^^^^^^^^^^^^^^^^^^^ OLD CODE HAS UNREASONABLE LIMITS ON KK ^^^^^^^^^^^

; =================== NEW LIMS ON dpdf and kk =========================
IF dpdf eq 0 then stop, 'YOU MUST ENTER A NONZERO NUMBER FOR DPDF_RAD!!
kk_guess_int = dpdf
kk_guesslim= abs(4.* kk_guess_int)
kk= !dtor*kk_guess_int
kklim = !dtor*kk_guesslim
; =================== NEW LIMS ON dpdf and kk =========================

;DEFINE THE ARRAY OF MEASURED DATA...
xy = fltarr(2*datasize)
xy[0:datasize-1] = realpart
xy[datasize:*] = imagpart

;DEFINE THE EQUATION-OF-CONDITION COEFFICIENTS...
sxy = fltarr(2, 2*datasize)
sxy[0,0:datasize-1] = cos(kk*freq)
sxy[1,0:datasize-1] = -sin(kk*freq)
sxy[0,datasize:*] = sin(kk*freq)
sxy[1,datasize:*] = cos(kk*freq)

nloopsboth=0
nloop002=0

;ITERATE FOR BAD POINTS...
iterate00:
t = wgt[0,*]*xy
s = wgt*sxy

ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st

bt = a # s
resid = t - bt
sigsq = total( resid^2)/(nrgood - 2.0)
sigma = sqrt( sigsq)

;FIND POINTS WHOSE RESIDUALS EXCEED 6 SIGMA
;	IF THEY EXIST, DISCARD AND DO AGAIN...
jndx = where( abs(resid) ge sigma3*sigma, count)
if (count eq 2*datasize) then begin
	print,'IN PHASEFIT, THERE ARE NO POINTS LESS THAN N SIGMA!!'
	problem = -1
	nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
	goto, goproblem
endif

if (count  ne 0l) then begin
nrgood = nrgood - count
wgt[*,jndx]=0.
nloop002=nloop002+1
goto, iterate00
endif

;DERIVE THE ERRORS IN DERIVED COEFFICIENTS...
sigarray = sigsq * ssi[indgen(2)*3]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;TEST FOR NEG SQRTS...
if (countsqrt ne 0) then begin
	print, countsqrt, ' NEGATIVE SQRTS IN SIGARRAY!'
;	sigarray[indxsqrt] = -sigarray[indxsqrt]
	problem=-2
	nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
	goto, goproblem
endif

sigmasave = sigma
a = reform(a)
;print, a
;print, sigarray

CA = a[0]
SA = a[1]
sigCA = sigarray[0]
sigSA = sigarray[1]

;STOP
;********WE NEXT HOLD A AND B CONSTANT AND DO A NONINEAR FIT FOR KK*******

nloop_on_kkbadpoints = 0
;REDEFINE THE WGTS TO BE ALL UNITY...
nrgood = 2l*datasize
wgt = 1. + fltarr(2*datasize)

;THIS IS THE BEGINNING OF THE ITERATION LOOP FOR BAD POINTS...
iterate_on_kkbadpoints:
nloop_on_kkbadpoints = nloop_on_kkbadpoints + 1
nloop_on_kk=0

;THIS IS THE BEGINNING OF THE ITERATION LOOP FOR THE NONLINEAR FIT FOR KK...
iterate_on_kk:
nloop_on_kk = nloop_on_kk + 1

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t[0:datasize-1] = xy[0:datasize-1] - (CA*cos(kk*freq) - SA*sin(kk*freq))
t[datasize:*]   = xy[datasize:*]   - (CA*sin(kk*freq) + SA*cos(kk*freq))
t = wgt*xy

;DEFINE THE EQUATION-OF-CONDITION COEFFICIENTS...
s = fltarr(1, 2*datasize)
s[0:datasize-1] = freq*( -CA*sin(kk*freq) - SA*cos(kk*freq))
s[0,datasize:*] = freq*(  CA*cos(kk*freq) - SA*sin(kk*freq))
s = wgt * s
s = reform(s, 1, 2*datasize)

transposes = transpose(s)
ss = transposes ## s
st = transposes ## transpose(t)
ssi = invert(ss)
a = ssi ## st

;CHECK DELKK: IF 'LARGE', THEN DIVIDE BY TWO...
delkk = a[0]
redoit0=0
if ( (abs(delkk) gt 0.2*abs(kk) and abs(delkk) gt kklim) ) then begin 
	delkk = 0.5*delkk & redoit0=2 
endif

kk = kk + delkk
;print, 'nloop_on_kk, kk, delkk ', nloop_on_kk, kk, delkk
if ( (redoit0 gt 0) and (nloop_on_kk lt 50) ) then goto, iterate_on_kk

if (redoit0 gt 0) then begin
	print, 'CONVERGENCE PROBLEM!!! NLOOP_ON_KK = ', nloop_on_kk
;	print, 'kk = ', kk
;	print, 'SETTING PHASE SLOPE EQUAL TO THE GUESS AND RETURNING...'
;	coeffs = [CA, SA, dpdf]
;	sigcoeffs = [sigCA, sigSA, 0.]
;	sigma=sigmasave
;	return
	problem = -3
	nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
	goto, goproblem
endif

;DERIVE THE FITTED POINTS, RESIDUALS, 
resid[0:datasize-1] = wgt[0:datasize-1] * ( xy[0:datasize-1] - $
	(CA*cos(kk*freq) - SA*sin(kk*freq) ) )
resid[datasize:*]   = wgt[datasize:*]   * ( xy[datasize:*] - $
	(CA*sin(kk*freq) + SA*cos(kk*freq) ) )

sigsq = total( resid^2)/(nrgood - 1.0)
sigma = sqrt( sigsq)

;STOP
;goto, iterate_on_kk

;FIND POINTS WHOSE RESIDUALS EXCEED 3 SIGMA
;	IF THEY EXIST, DISCARD AND DO AGAIN...
jndx = where( abs(resid) ge sigma3*sigma, count)
if (count  ne 0l) then begin
nrgood = nrgood - count
wgt[jndx]=0.
;print, 'nloop_on_kkbadpoints', nloop_on_kkbadpoints, count
goto, iterate_on_kkbadpoints
endif

;DERIVE THE ERRORS IN KK...
sigarray = sigsq * ssi[indgen(1)*2]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))
sigkk = sigarray[0]

;TEST FOR NEG SQRTS...
if (countsqrt ne 0) then begin
	print, countsqrt, ' NEGATIVE SQRTS IN SIGARRAY!'
;	sigarray[indxsqrt] = -sigarray[indxsqrt]
	problem=-4
	nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
	goto, goproblem
endif

coeffs = [CA, SA, KK]
sigcoeffs = [sigCA, sigSA, sigKK]

;STOP
;goto, iterate_on_kk

;************** NOW FIT FOR ALL THREE COEFFS SIMULTANEOUSLY************

nloop_on_5badpoints = 0
;REDEFINE THE WGTS TO BE ALL UNITY...
nrgood = 2l*datasize
wgt = 1. + fltarr(5, 2*datasize)

;THIS IS THE BEGINNING OF THE ITERATION LOOP FOR BAD POINTS...
iterate_on_5badpoints:
nloop_on_5badpoints = nloop_on_5badpoints + 1
nloop_on_5=0

;THIS IS THE BEGINNING OF THE ITERATION LOOP FOR THE NONLINEAR FIT FOR KK...
iterate_on_5:
nloop_on_5 = nloop_on_5 + 1

;print, 'CA, SA, KK ', CA, SA, kk

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t[0:datasize-1] = xy[0:datasize-1] - ( (CA*cos(kk*freq) - SA*sin(kk*freq)) )
t[datasize:*]   = xy[datasize:*]   - ( (CA*sin(kk*freq) + SA*cos(kk*freq)) )
t = wgt[0,*] * t

;DEFINE THE EQUATION-OF-CONDITION COEFFICIENTS...
s = fltarr(3, 2*datasize)
s[0,0:datasize-1] = cos(kk*freq)
s[1,0:datasize-1] = -sin(kk*freq)
s[0,datasize:*] = sin(kk*freq)
s[1,datasize:*] = cos(kk*freq)
s[2,0:datasize-1] = freq*( -CA*sin(kk*freq) - SA*cos(kk*freq))
s[2,datasize:*] =   freq*(  CA*cos(kk*freq) - SA*sin(kk*freq))
s = wgt * s

transposes = transpose(s)
ss = transposes ## s
st = transposes ## transpose(t)
ssi = invert(ss)
a = ssi ## st

delCA = a[0]
delSA = a[1]
delKK = a[2]

;CHECK DELKK: IF 'LARGE', THEN DIVIDE BY TWO...
redoit0=0
if ( (abs(delKK) gt 0.2*abs(KK) and abs(delKK) gt KKlim) ) then begin 
	delCA = 0.5*delCA
	delSA = 0.5*delSA
	delKK = 0.5*delKK
	redoit0=2 
endif

if ( (abs(delKK) gt 0.05*abs(KK) and abs(delKK) gt KKlim) ) then redoit0=1

CA = CA + delCA
SA = SA + delSA
KK = KK + delKK

;print, 'nloop_on_5, KK, delKK ', nloop_on_5, KK, delKK
								
if ( (redoit0 gt 0) and (nloop_on_5 lt 50) ) then goto, iterate_on_5

if (redoit0 gt 0) then begin
	print, 'CONVERGENCE PROBLEM!!! NLOOP_ON_5 = ', nloop_on_5
	print, 'kk = ', kk
;	print, 'SETTING PHASE SLOPE EQUAL TO THE GUESS AND RETURNING...'
;	coeffs = [CA, SA, dpdf]
;	sigcoeffs = [sigCA, sigSA, 0.]
;	sigma=sigmasave
	problem = -4
	nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
	goto, goproblem
endif

;DERIVE THE FITTED POINTS, RESIDUALS, 
resid[0:datasize-1] = wgt[0:datasize-1] * ( xy[0:datasize-1] - $
	( CA*cos(kk*freq) - SA*sin(kk*freq) ) )
resid[datasize:*]   = wgt[datasize:*] * ( xy[datasize:*] - $
	( CA*sin(kk*freq) + SA*cos(kk*freq) ) )

sigsq = total( resid^2)/(nrgood - 1.0)
sigma = sqrt( sigsq)

;FIND POINTS WHOSE RESIDUALS EXCEED 3 SIGMA
;	IF THEY EXIST, DISCARD AND DO AGAIN...
jndx = where( abs(resid) ge sigma3*sigma, count)
if (count  ne 0l) then begin
nrgood = nrgood - count
wgt[jndx]=0.
;print, 'nloop_on_5badpoints', nloop_on_5badpoints, count
goto, iterate_on_5badpoints
endif

;DERIVE THE ERRORS IN KK...
sigarray = sigsq * ssi[indgen(3)*4]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;TEST FOR NEG SQRTS...
if (countsqrt ne 0) then begin
	print, countsqrt, ' NEGATIVE SQRTS IN SIGARRAY!'
;	sigarray[indxsqrt] = -sigarray[indxsqrt]
	problem=-5
	nonconvergence, dpdf, sa, ca, kk, sigsa, sigca, sigarray
	goto, goproblem
endif

goproblem:

coeffs = [CA, SA, KK]
sigcoeffs = sigarray
;coeffs[2] = !radeg*coeffs[2]
;sigcoeffs[2] = !radeg*sigcoeffs[2]

tfit = fltarr( datasize, 2, /nozero)
tfit[*,0] = CA*cos(kk*freq) - SA*sin(kk*freq) 
tfit[*,1]   = CA*sin(kk*freq) + SA*cos(kk*freq)

thetafit= atan( tfit[*,1], tfit[*,0])
theta_data = atan( imagpart, realpart)

resids_theta= theta_data- thetafit
resids_theta= modangle( resids_theta, 2.*!pi, /negpos)
sigthetafit= sqrt( variance( resids_theta))

;FIND THE LINEAR-FIT PARAMETERS AND THEIR ERRORS...
sigca = sigcoeffs[0]
sigsa = sigcoeffs[1]
APHI_radians = atan(SA,CA) ;;;;;;;- kk*frqmean
sigaphi_radians = sqrt( (sigCA*SA)^2 + (sigSA*CA)^2 )/(SA^2 + CA^2)

;stop

;aphi = !radeg * aphi_radians
;sigaphi = !radeg * sigaphi_radians
aphi = aphi_radians
sigaphi = sigaphi_radians

;STOP

;;PLOT TO CHECK RESULTS...
;wset, 1
;plot, frq, atan(imagpart, realpart)
;oplot, frq, aphi_radians + kk * frq, color=!red

;wset, 0
;plot, frq, !radeg * atan(imagpart, realpart)
;oplot, frq, aphi + coeffs[2] * frq, color=!red

;if (problem ne 0) then stop, 'stop: phasefit_mar01, goproblem'

return
end

