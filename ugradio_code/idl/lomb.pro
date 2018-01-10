pro lomb, time, tsig, frqout, Pftsig
;+
;NAME:
;lomb -- evaluate lomb periodogram
;
;LOMB METHOD FOR PWR SPECTRUM
;
;CALLING SEEQUENCE:
;	LOMB, time, tsig, frqout, pftsig
;
;INPUTS:
;	time, time at which input sig is sampled
;	tsig, amplitude of input sig
;	frqout, freqs at which you want the ft computed.
;OUTPUTS
;	Pftsig, PWR SPECT of sig evaluated at frqout. float.
;-

jjj= complex( 0., 1.)
n400= n_elements( frqout)

Pftsig= fltarr( n400)

mult=1./n400

hbar= mean( tsig)
sigmasq = total( (tsig- hbar)^2 )/ (n400- 1.)
h_m_hbar= tsig- hbar

for k = 0l, n400-1l do begin

IF ( FRQOUT[ K] NE 0.) THEN BEGIN
tangent = total( sin( 4.*!pi* frqout[ k]* time)) / $
	  total( cos( 4.*!pi* frqout[ k]* time))
tau = atan( tangent)/(4.*!pi*frqout[ k])
ENDIF ELSE tau=0.

first_term= total( h_m_hbar* cos( 2.*!pi* frqout[ k]* (time- tau)) )^2 / $
	total( cos( 2.*!pi* frqout[ k]* (time- tau))^2 ) 

secnd_term= total( h_m_hbar* sin( 2.*!pi* frqout[ k]* (time- tau)) )^2 / $
	total( sin( 2.*!pi* frqout[ k]* (time- tau))^2 ) 

pftsig[ k]= (first_term + secnd_term)/(2.* sigmasq)

endfor

return
end
