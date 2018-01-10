pro lsclean_carl, inputx, inputy, gain, nitermax, $
	outputx, outputy, clean_comp, cleanoutputy, clean_iny, $
	outputy_recon, $
	plot_clean=plot_clean,  print_clean_comp=print_clean_comp
;+
;NAME:
;LSCLEAN_CARL, DO A 'LEAST-SQUARES' 1D CLEAN.
;
;CALLING SEQUENCE: lsclean_carl, inputx, inputy, gain, nitermax, $
;	outputx, outputy, clean_comp, cleanoutputy, clean_iny, $
;	plot_clean=plot_clean,  print_clean_comp=print_clean_comp

;INPUTS:
;WE DESCRIBE THE INPUTS AND OUTPUTS AS IF THE INPUTS ARE FREQ, OUTPUTS ARE TIME
;INPUTX[], the input x values (e.g. freqs)
;INPUTY[], the input y values (normally amplitude--real, not complex)
;GAIN, the loop gain. should be high. should be adjusted inside for s/n of fit.
;NITERMAX, the max nr of iterations, equal to nr of clean components that
;	will be generated
;OUTPUTX[] is the set of output x values (times) that will be searched for peaks
;
;KEYWORDS:
;PLOT_CLEAN. if set, plots each iteration and asks for key input to continue.
;PRINT_CLEAN_COMP if set, print list of clean comp.
;
;OUTPUTS:
;OUTPUTY[] is the dirty y values correspondinig to OUTPUTX (complex)
;CLEAN_COMP[ 2,NITERMAX], the list of clean components. clean_comp[0,*]
;	is the X-value of the clean component (time), 
;	clean_comp[1,*] are the [cos, sin] amplitudes.
;CLEANOUTPUTY, the current version of the cleaned OUTPUTY values, equal to
;	OUTPUTY minus the sum of the currently-existing clean components.
;CLEAN_INY, the cleaned version of INPUTY obtained from the clean components
;OUTPUTY_RECON, the output y values reconstructed from the clean components
;       by adding them. Thus, this is a series of spikes that represent
;       the complex clean components.
;
;METHOD AND COMMENTS:
;
;example file: @...ay204/2010/fourier/irregular/marcy/lscleantst.idl
;
;(1) calculate the digital fourier transorm (DFT) amplitude spectrum. 
;that is, use INPUTX, CLEANY to calculate a straight dirty Y array.
;then picks the max amplitude and remembers its X-value OUTPUTX_PEAK
;
;(2) Does a ls fit: CLEANY = A + B COS( outputx_peak) + C SIN( outputx_peak)
;
;(3) Sets clean_comp[ 0,nr]=outputx_peak ; clean_comp[ 1,nr]= complexarr( B,C)
;
;(4) Loop back to (1) and repeat until done.
;
;NOTE: to calculate values of cleaned input signal CLEAN_INY 
;	for any input x value XV (even one that wasn't in the original array):
;
;clean_iny= fltarr( n_elements( XV))
;FOR NR= 0, NITERMAX-1 DO BEGIN
;coeffs= [ 0., float( clean_comp[ 1, nr]), imaginary( clean_comp[ 1,nr])]
;poly_ft_eval, XV, 0, coeffs, float( clean_comp[ 0,nr]), $
;        yeval, yeval_poly, yeval_fourier
;clean_iny= clean_iny+ yeval_fourier
;ENDFOR
;
;-

nrx= n_elements( outputx)
dft, inputx, inputy, outputx, outputy

inputy_cleaned= inputy
clean_comp= complexarr( 2, nitermax)
outputy_iter_00= outputy
outputy_iter= outputy

FOR nriter= 0L, NITERMAX-1L DO BEGIN

outputy_iter_orig= outputy_iter
dft, inputx, inputy_cleaned, outputx, cleanoutputy
peak= max( abs( cleanoutputy), indx_peak)
outputx_peak= outputx[ indx_peak]

poly_ft_fit_svd, inputx, inputy_cleaned, 0, outputx_peak, $
        coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
        residbad=residbad, goodindx=goodindx, problem=problem, $
        polycoeffs=polycoeffs, fcoeffs=fcoeffs, sigfcoeffs=sigfcoeffs, $
        fpower=fpower, sigfpower=sigfpower, $
        yfit_poly= yfit_poly, yfit_fourier=yfit_fourier, $
        itmax=itmax, /noplot
inputy_cleaned= inputy_cleaned- gain*yfit

;clean_comp[ 0, nriter]= outputx_peak
clean_comp[ 0, nriter]= indx_peak
clean_comp[ 1, nriter]= complex( gain* fcoeffs[0], gain* fcoeffs[1])

IF KEYWORD_SET( PLOT_CLEAN) THEN BEGIN
;wset,0
if wopen(31) eq 0 then window, 31, xs=400, ys=800
wset,31
wshow
!p.multi=[0,1,2]
outputy_iter_orig= outputy_iter
peak= abs( clean_comp[ 1,nriter])/gain
;plot, outputx, 2.*abs( cleanoutputy), $
;	xra= minmax( outputx), /xsty, $
;	xtit='outputx; NITER=' + string(nriter), $
;	ytit='ABS_CLEANY', yra=[0, 1.5*peak], $
;        tit='OUTPUT CLEANY'
;plots, outputx[ clean_comp[ 0,0:nriter]], $
;	abs( clean_comp[ 1,0:nriter])/gain, $
;	psym=2, color=!magenta
;plots, outputx[ clean_comp[ 0,nriter]], $
;	abs( clean_comp[ 1,nriter])/gain, $
;	psym=2, color=!cyan, symsize=2
plot, outputx, 2.*abs( cleanoutputy), $
;plot, outputx, abs( outputy_iter_orig), $
        xra= minmax( outputx), /xsty, $
        xtit='outputx; NITER=' + string(nriter), $
      ytit='ABS_CLEANY', yra=[0, 1.5* max( abs( outputy_iter_00))], /ysty, $
;       ytit='ABS_CLEANY', yra=[0, 1.5* peak], /ysty, $
        tit='OUTPUT CLEANY'
plots, outputx[ clean_comp[ 0,0:nriter]], abs( clean_comp[ 1,0:nriter])/gain, $
        psym=2, color=!magenta
plots, outputx[ clean_comp[ 0,nriter]], abs( clean_comp[ 1,nriter])/gain, $
        psym=2, color=!cyan, symsize=2

plot, outputx, 2.*abs( cleanoutputy), $
;plot, outputx, abs( outputy_iter_orig), $
        xra= minmax( outputx), /xsty, $
        xtit='outputx; NITER=' + string(nriter), $
;       ytit='ABS_CLEANY', yra=[0, 1.1* max( abs( outputy_iter_orig))],
;       /ysty, $                 
        ytit='ABS_CLEANY', yra=[0, 1.5* peak], /ysty, $
        tit='OUTPUT CLEANY'
plots, outputx[ clean_comp[ 0,0:nriter]], abs( clean_comp[ 1,0:nriter])/gain, $
        psym=2, color=!magenta
plots, outputx[ clean_comp[ 0,nriter]], abs( clean_comp[ 1,nriter])/gain, $
        psym=2, color=!cyan, symsize=2
endif

print, 'hit q to stop iteratring, any other key for another iteration'
result=get_kbrd( 1)
print, 'nriter=', nriter
if (result eq 'q') then goto, FINISHED
;ENDIF

ENDFOR

FINISHED:

nitermax= nitermax < (nriter+ 1)

outputy_recon= complexarr( nrx)
FOR NR=0, NITERMAX-1 DO BEGIN
        outputy_recon[ float( clean_comp[ 0,nr])] = $
        outputy_recon[ float( clean_comp[ 0,nr])] + clean_comp[ 1, nr]
ENDFOR
outputy_recon= 0.5* outputy_recon
                                                                  
;CLEAN_COMP[ 0,*] HAS BEEN IN UNITS OF CHANNELS. CONVERT TO OUTPUTX...
clean_comp[ 0,*]= outputx[ clean_comp[ 0,*]]

;USE CLEAN COMPONENTS TO CALCULATE THE CLEANED INPUTY...
clean_iny= fltarr( n_elements( inputx))
FOR NR= 0, NITERMAX-1 DO BEGIN
coeffs= [ 0., float( clean_comp[ 1, nr]), imaginary( clean_comp[ 1,nr])]
poly_ft_eval, inputx, 0, coeffs, float( clean_comp[ 0,nr]), $
        yeval, yeval_poly, yeval_fourier
clean_iny= clean_iny+ yeval_fourier
ENDFOR

IF KEYWORD_SET( PRINT_CLEAN_COMP) THEN BEGIN
print, '------------'
print, '     NR        FREQ                COMPLEX AMPLITUDE'
nprint= n_elements( clean_comp)/2
for nr=0, nitermax-1 do $
        print, nr, float( clean_comp[ 0,nr]), '   ...   ', $
        clean_comp[ 1,nr]
ENDIF
!p.multi=0

return
end

