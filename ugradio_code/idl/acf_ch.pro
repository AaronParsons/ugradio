pro acf_ch, tseries, acf, lags=lags

;+
;ACF_ch: calculates the ACF of a 1d time series, with each entry divided
;by the nr of elements in the sum so that the normalization of each
;delay is the same relative to the other ones. ACF[0] is not normalized
;to unity.
;
;To calculate the pwr spectrum from the ACF, use ACF_TO_PSPEC
;
;INPUT: tseries, the time series
;OUTPUT: the ACF
;
;KEYWORD INPUT: 
;  LAGS, the set of lags. If not set, LAGS= lindgen( N/2), where N is
;the length of the input time series. This is the set required for
;calculating a power spectrum from the time series.
;-

npts= n_elements( tseries)
acf= fltarr( npts)

if n_elements( lags) eq 0 then lags= lindgen( n_elements( tseries)/2l) 
nrlags= n_elements( lags)

for lag= 0, nrlags-1 do begin
ts00= tseries[ lags[ lag]: npts-1]
ts11= tseries[ 0: npts- lags[ lag]- 1]
acf[ lags[ lag]]= total( ts00*ts11)/ (npts- lags[ lag])
;if lag eq 10 then stop
endfor




end


