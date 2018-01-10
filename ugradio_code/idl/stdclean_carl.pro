pro stdclean_carl, inputx, inputy, gain, nitermax, $
	outputx, outputy, clean_comp, cleanoutputy, clean_iny, outputy_recon, $
	plot_clean=plot_clean,  print_clean_comp=print_clean_comp
;+
;NAME:
;STDCLEAN_CARL, DO A STANDARD 1D CLEAN. (a/la dreher et al paper)
;
;CALLING SEQUENCE: stdclean_carl, inputx, inputy, gain, nitermax, $
;	outputx, outputy, clean_comp, cleanoutputy, clean_iny, $
;	plot_clean=plot_clean,  print_clean_comp=print_clean_comp
;
;INPUTS:
;WE DESCRIBE THE INPUTS AND OUTPUTS AS IF THE INPUTS ARE FREQ, OUTPUTS ARE TIME
;INPUTX[], the input x values (e.g. freqs)
;INPUTY[], the input y values (normally amplitude--real, not complex)
;GAIN, the loop gain. try 0.3??
;NITERMAX, the max nr of iterations, equal to nr of clean components that
;	will be generated
;OUTPUTX[] is the set of output x values (times) that will be searched for peaks
;	************ IMPORTANT ******************
;	OUTPUTX MUST RANGE FROM 0 TO +TMAX WITH UNIFORM STEP SIZE.
;
;KEYWORDS:
;PLOT_CLEAN. if set, plots each iteration and asks for key input to continue.
;PRINT_CLEAN_COMP if set, print list of clean comp.
;
;OUTPUTS:
;OUTPUTY[] the straight DFT-calculated (dirty) y values correspondinig to OUTPUTX,
;	normally known as the 'dirty output' 
;CLEAN_COMP[ 2,NITERMAX], the list of clean components. clean_comp[0,*]
;	is the OUTPUTX-value of the clean component (time), 
;	clean_comp[1,*] are the [cos, sin] amplitudes.
;CLEANOUTPUTY, the current version of the cleaned OUTPUTY values, equal to
;	OUTPUTY minus the sum of the currently-existing clean components.
;CLEAN_INY, the version of INPUTY calculated from the clean components
;OUTPUTY_RECON, the output y values reconstructed from the clean components
;	by adding them. Thus, this is a series of spikes that represent 
;	the complex clean components.
;
;METHOD AND COMMENTS:
;
;example file: @...ay204/2010/fourier/irregular/marcy/stdcleantst.idl
;
;CLEAN_COMP are defined only for positive outputx.
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

ndata= n_elements( inputx)
nrx= n_elements( outputx)
nrxm1= nrx- 1
outputx_sym= [ -reverse( outputx[ 1:*]), outputx[ 0:*]]

;GENERATE WFCN_DSYM...
xmax= max( outputx)
inputy_wfcn_dsym= fltarr( ndata)+ 1.
outputx_wfcn_dsym= 4.* xmax* ( dindgen( 4l* nrxm1+ 1)- 2l*nrx+2)/(4l* nrxm1)
dft, inputx, inputy_wfcn_dsym, outputx_wfcn_dsym, wfcn_dsym
indxwz= 2l* (nrx- 1l)

dft, inputx, inputy, outputx_sym, outputy_sym
outputy= outputy_sym[ nrx-1:*]

print, max( abs(outputy_sym), ndx), ndx, outputx_sym[ ndx]

cleanoutputy_sym= outputy_sym

clean_comp= complexarr( 2, nitermax)

range= lindgen( nrx)
outputy_iter= outputy
outputy_iter_00= outputy

FOR NRITER= 0L, NITERMAX-1L DO BEGIN

outputy_iter_orig= outputy_iter
peak= max( abs( outputy_iter[ range]), indx_peak)
cleany_fake=  outputy_iter[ indx_peak]*shift( wfcn_dsym, 1+ indxwz+ indx_peak) + $
        conj( outputy_iter[ indx_peak])* shift( wfcn_dsym, 1+ indxwz- indx_peak)

;stop
outputy_iter= outputy_iter_orig- gain* cleany_fake
outputy_iter[ 0]= complex( 0., 0.)
clean_comp[ 1, nriter]= gain* cleany_fake[ indx_peak]
clean_comp[ 0, nriter]= indx_peak

IF KEYWORD_SET( PLOT_CLEAN) THEN BEGIN
if wopen(31) eq 0 then window, 31, xs=400, ys=800
wset,31
wshow
!p.multi=[0,1,2]
plot, outputx, abs( outputy_iter_orig), $
	xra= minmax( outputx), /xsty, $
	xtit='outputx; NITER=' + string(nriter), $
	ytit='ABS_CLEANY', yra=[0, 1.1* max( abs( outputy_iter_00))], /ysty, $
;	ytit='ABS_CLEANY', yra=[0, 1.5* peak], /ysty, $
        tit='OUTPUT CLEANY'
plots, outputx[ clean_comp[ 0,0:nriter]], abs( clean_comp[ 1,0:nriter])/gain, $
	psym=2, color=!magenta
plots, outputx[ clean_comp[ 0,nriter]], abs( clean_comp[ 1,nriter])/gain, $
	psym=2, color=!cyan, symsize=2

plot, outputx, abs( outputy_iter_orig), $
	xra= minmax( outputx), /xsty, $
	xtit='outputx; NITER=' + string(nriter), $
;	ytit='ABS_CLEANY', yra=[0, 1.1* max( abs( outputy_iter_orig))], /ysty, $
	ytit='ABS_CLEANY', yra=[0, 1.5* peak], /ysty, $
        tit='OUTPUT CLEANY'
plots, outputx[ clean_comp[ 0,0:nriter]], abs( clean_comp[ 1,0:nriter])/gain, $
	psym=2, color=!magenta
plots, outputx[ clean_comp[ 0,nriter]], abs( clean_comp[ 1,nriter])/gain, $
	psym=2, color=!cyan, symsize=2
endif

;stop
print, 'hit q to stop iteratring, any other key for another iteration'
result=get_kbrd( 1)
print, 'nriter=', nriter
if (result eq 'q') then goto, FINISHED
;ENDIF

ENDFOR

FINISHED:

nitermax= nitermax < (nriter+ 1)

;REVERESE SIGNS OF IMAGINARY COMPONENTS OF CLEAN_COMP TO CONFORM TO THE
;STANDARD IN LSCELAN_CARL.PRO...
;ALSO MULTIPLY THEM BY 2 TO ACCOUNT FOR MISSING NEG-FREQ SIDE...
clean_comp[ 1,*]= 2.* conj( clean_comp[ 1,*])

outputy_recon= complexarr( nrx)
FOR NR=0, NITERMAX-1 DO BEGIN
	outputy_recon[ float( clean_comp[ 0,nr])] = $
	outputy_recon[ float( clean_comp[ 0,nr])] + clean_comp[ 1, nr]
ENDFOR
outputy_recon= 0.5* outputy_recon

;CLEAN_COMP[ 0,*] HAS BEEN IN UNITS OF CHANNELS. CONVERT TO OUTPUTX...
clean_comp[ 0,*]= outputx[ clean_comp[ 0,*]]

cleanoutputy= outputy- outputy_recon

;USE CLEAN COMPONENTS TO CALCULATE THE CLEANED INPUTY...
clean_iny= fltarr( ndata)
FOR NR= 0, NITERMAX-1 DO BEGIN
coeffs= [ 0., float( clean_comp[ 1, nr]), imaginary( clean_comp[ 1,nr])]
poly_ft_eval, inputx, 0, coeffs, float( clean_comp[ 0,nr]), $
        yeval, yeval_poly, yeval_fourier
clean_iny= clean_iny+ yeval_fourier
ENDFOR

IF KEYWORD_SET( PRINT_CLEAN_COMP) THEN BEGIN
print, '------------'
print
print, '      NR       FREQ     ...   (       COMPLEX AMPLITUDE   )       AMPL'


nprint= n_elements( clean_comp)/2
for nr=0, nitermax-1 do $
        print, nr, float( clean_comp[ 0,nr]), '   ...   ', $
        clean_comp[ 1,nr], abs( clean_comp[ 1,nr])
ENDIF

!p.multi=0

;stop, 'END OF STDCLEAN_CARL'

return
end

