pro dft, inputx, inputy, outputx, outputy, inverse=inverse
;+
;NAME:
;DFT -- DIRECT FT USing IDL CONVENTION FOR FORWARD/REVERSE
;
;CALLING SEQUENCE: dft, inputx, inputy, outputx, outputy, [/inverse]
;
;INPUTS:
;	inputx, x-value at which input sig is sampled
;	inputy, amplitude of input sig
;	outputx, x-values at which you want the ft computed.
;KEYWORD: 
;	INVERSE. if set, does the idl inverse equivalent.
;OUTPUTS
;	outputy, ft of sig evaluated at outputx. complex.
;
;TO TEST AND COMPARE WTIH THE FFT: see the attached 
;
;	pro dfttst_2
;
;
;IN PARTICULAR, NOTE HOW THE ORDER OF THE INPUT AND OUTPUT ARRAYS FOR THE
;FFT MUST BE REARRANGED SO AS TO BE MONOTINICALLY INCREASING
;
;MODS
;	11nov04, carlh added check to see which method is faster in for loop.
;
;-

jjj= complex( 0., -1.)
n400= n_elements( outputx)
outputy= complexarr( n400)

mult=1./n_elements( inputx)
if (n_elements( inverse) ne 0) then begin
	if (inverse eq 1) then begin
	jjj=-jjj
	mult= 1.
	endif
endif

n_inputx= n_elements( inputx)

IF (N_inputx GT N400) THEN BEGIN
for k = 0l, n400-1l do $
        outputy[ k]= total( inputy* exp( 2.*!pi*jjj* outputx[ k]* inputx) )
ENDIF ELSE BEGIN
for k = 0l, n_inputx-1l do $
        outputy= outputy+ $
	inputy[ k]* exp( 2.*!pi*jjj* outputx* inputx[ k])
ENDELSE

outputy= mult* outputy
return
end

;----------------------------------------------------------------------------------

pro dfttst_2

;GENERATE TIME SERIES WITH NSMPLS POINTS...
ts=0.3
nsmpls= 256
time= ts* ( findgen( nsmpls)- nsmpls/2 )
bigt= ts* nsmpls

;EXPT WITH A SIG HAVING 6 CYCLES OVER THE TOTAL TIME RANGE...
fsig= 6./bigt
;fsig= 5./bigt

tsig= complex( 1.*cos( 2.*!pi* fsig* time), $
               1.*sin( 2.*!pi* fsig* time) )
frqout= (1.0/ts)*(findgen( nsmpls)-nsmpls/2)/ nsmpls

;DO DFT...
dft, time, tsig, frqout, dftsig

;REARRANGE INPUTS FOR FFT AND DO IT...
tsig_0= complexarr( nsmpls)
tsig_0[ 0:nsmpls/2-1]= tsig[ nsmpls/2:nsmpls-1]
tsig_0[ nsmpls/2:nsmpls-1]= tsig[ 0:nsmpls/2-1]

fftsig_0= fft( tsig_0)

;REARRANGE OUTPUTS FOR FFT SO THAT FREQS GO FROM NEG TO POS...
fftsig= complexarr( nsmpls)
fftsig[ 0:nsmpls/2-1]= fftsig_0[ nsmpls/2:nsmpls-1]
fftsig[ nsmpls/2:nsmpls-1]= fftsig_0[ 0:nsmpls/2-1]

wset,0
plot, float( fftsig), yra=[-1,1], /ysty
oplot, imaginary( fftsig), color=red

wset,1
plot, float( dftsig), yra=[-1,1], /ysty
oplot, imaginary( dftsig), color=green

print, minmax( fftsig- dftsig)

return
end
