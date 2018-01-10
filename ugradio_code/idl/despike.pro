pro despike, in, out, inplace=inplace, fwidth=fwidth, mult=mult
;+
; NAME:despike
;
; PURPOSE:given an inout vector, remove spikes without degrading resolution.
;
; CATEGORY:sig_processing
;
; CALLING SEQUENCE: 
;        despike, in, out, inplace=inplace, fwidth=fwidth, mult=mult
;
; INPUTS: 
;IN, the input vector with spikey noise. despike done in place if INPLACE is set
;
; OPTIONAL INPUTS:
;FWIDTH, the width of the median filter used to find the spikes. this
;should be set to at least twice as wide as the widest spikes you want to remove.
;
;MULT, the multiplier for the default limit that is applied to 
; the 'rms' for which points are 'removed'. This limit is
;       MULT * [11./ (fwidth/7.)^0.33]
;
; KEYWORD PARAMETERS:
;INPLACE. set to remove spikes from IN and leave the result in place.
;
; OUTPUTS:
;OUT, the despiked vector. if INPLACE is set, the output is in IN
;
;METHOD. subtracts median filtered of IN from IN (the median filter has
;widdth FWIDTH). With Gaussian noise, this would give another Gaussian
;disstributed noise with a diepersion close to the original. Make a
;cumulative distribution function of these numbers, scaling the
;histogram range to the median of the absolute values of these new
;data. Find the limits where 68.3% of the points lie inside. Define this
;as twice the rms. Find all points whose value excees 5 timese the
;rms. Set these equal to the previous point; do this sequentially with a
;for loop, to ensure that you never set a bad point eequal to another
;bad point.

; MODIFICATION HISTORY:
; ch, 8 jun 2007
;-



if n_elements( fwidth) eq 0 then fwidth=7
if keyword_set( inplace) eq 0 then out=in
if keyword_set( mult) eq 0 then mult=1.
five=mult* 11./ (fwidth/7.)^0.33

tmp= in
tmpmed= median( tmp,fwidth)

;CALCULATE RATIO OF DATA TO MEDIAN OF DATA--SHOWS SPIKES
ratio= tmp- tmpmed 

;FIND RMS EQUIVALENT FROM CUM HISTOGRAM...
p4= median( abs( ratio))
omin= -p4
omax= p4
nbins= (omax- omin)/0.01 + 1.
histo_wrap, ratio, omin, omax, nbins, bin_edges, bin_cntrs, hx

;cum= total( hx, /cum)/ float( sz[1])

cum= total( hx, /cum)
cum= cum/ max(cum)
cut= (1.- 0.683)/2.
indxmin= where( cum ge cut)
indxmax= where( cum ge 1.-cut)

rms= 0.5*(bin_cntrs[ min(indxmax)]- bin_cntrs[ min(indxmin)])

;print, 'rms = ', rms, rms/fwidth^.33, five, five*rms

;indx= where( abs(ratio) gt five*rms, count, complement=cindx, ncomplement=ccount)

indx= where( abs(ratio) gt five*rms, count)

;print, count

;;SET EACH BAD POINT EQUAL TO ITS LEFT-HAND NEIGHBOR...first chk the
;;FIRST BAD POINT, SEE IF IT IS THE FIRST ONE OF THE ARRAY...
;IF COUNT NE 0 THEN BEGIN
;  IF INDX[0] EQ 0 THEN if indx[1] ne 1 then TMP[ 0]= TMP[ 1] $
;    ELSE tmp[0]= median( tmp[ cindx])
;  for nri=1, count-1 do tmp[ indx[ nri]]= tmp[ indx[ nri]-1l]  
;ENDIF

;stop

;SET EACH BAD POINT EQUAL TO ITS LEFT-HAND NEIGHBOR...
;NOTE THAT THE FIRST POINT WILL NEVER BE FLAGGED BECAUSE MEDIAN DOES
;NOTHING TO THE FIRST FWIDTH/2 OF THE DATA.
if count ne 0 and indx[0] ne 0 then tmp[ indx[0]]= tmp[ indx[0]-1l]
if count ne 0 then $
  for nri=1, count-1 do tmp[ indx[ nri]]= tmp[ indx[ nri]-1l]  

if keyword_set( inplace) then in= tmp else out= tmp

return
end
