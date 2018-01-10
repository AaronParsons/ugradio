pro despike2, in, out, chanmask=chanmask, rfiwidth=rfiwidth, maxrfiwidth=maxrfiwidth, rms=rms, status=status, cum=cum
;+
; NAME: DESPIKE2
; PURPOSE: 	
;	Given an input vector with RFI that may be one or more channels wide, identify the RFI
;	channels by determining the rms (without RFI) and returning the Signal to Noise ratio 
;	for each channel. The input vector does not need a flat baseline.
;
; CATEGORY:	sig_processing
;	  
; CALLING SEQUENCE:
;despike2,in,out,chanmask=chanmask,rfiwidth=rfiwidth,maxrfiwidth=maxrfiwidth,rms=rms,status=status 
;
; INPUTS:
;		IN, the input vector with spiky RFI
; OUTPUTS:
;		OUT, A vector, the same size and type as IN with the Signal to Noise ratio for 
;	each channel. OUT will return NaNs for channels where CHANMASK=0 (See DESCRIPTION below) 
;	
; OPTIONAL INPUTS:
;		CHANMASK, A vector of the same size as IN. Values of 1 indicate channels to be considered
;	for RFI removal. Any channels where there is no signal, where the IN spectrum has constant values,
;	or where signal that is known to be non-RFI should be flagged with values of 0. If no CHANMASK is
;	provided, all channels will be included in the filtering.
;	DEFAULT VALUE: CHANMASK= IN*0 + 1
;
; OPTIONAL INPUT/OUTPUT KEYWORDS:
;		RFIWIDTH, The width (in channels) of the widest RFI feature to be removed. This determines
;	the channel width used in the median filter (rfiwidth*2 - 1). Setting RFIWIDTH too small will
;	result in wider RFI features not being fully removed. Setting RFIWIDTH too high will overly smooth the
;	median filter spectrum, resulting in overestimates of the RMS. 
;	If RFIWIDTH is not supplied, the procedure will attempt to calculate the optimal value prior to
;	despiking and return that through the RFIWIDTH keyword. It does so by trying different values of
;	RFIWIDTH (from 1 to MAXRFIWIDTH) to find the one which maximizes MEAN(IN - MEDIAN(IN, RFIWIDTH*2-1)).
;	This should work in most cases, but is NOT ALWAYS RELIABLE.
;		MAXRFIWIDTH, The maximum RFIWIDTH size to use when trying to determine RFIWIDTH. Only used
;	when RFIWIDTH is not supplied.
;	DEFAULT VALUE: MAXRFIWIDTH = 30
;
; OPTIONAL OUTPUTS:
;		RMS, Will return a two element vector with the calculated RMS values on the positive and
;	negative sides of the cumulative distribution function. Since the cumulative distribution function
;	is often non-symmetrical, two RMS values are determined.
;		STATUS, Will return a string vector with various warning messages. 
;	If n_elements(STATUS) > 1, there may be a problem.
;		CUM, Will store a structure containing the cumulative distribution function
;
; DESCRIPTION:
;		Based on Carl Heiles' original DESPIKE procedure. The goal of this procedure is to
;	determine the proper RMS values by which to judge spikes that may be caused by RFI. The given
;	spectrum may have any shape, and does not need to be baseline-corrected apriori. 
;
;	TMPMED= median(IN, RFIWIDTH*2 - 1), is the median filter of the input (IN) spectrum.
;	DIFF=IN - TMPMED, is the difference between the original and median filtered spectra
;	CUMX=DIFF[sort(DIFF)]
;	CUMY=indgen(n_elements(DIFF))/(n_elements(DIFF)*1.), represent the cumulative distribution of DIFF
;
;		If IN contains only gaussian noise, then a histogram of DIFF will be a gaussian, 
;	and CUMX,CUMY should resemble the cumulative distribution function (CDF) of a gaussian. The
;	presence of RFI will tend to modify the CDF, but primarily at the edges. The innermost
;	68.3% of the CDF can still be used to identify the 1-sigma RMS values with only secondary 
;	influence from the RFI. Since the RFI can make the CDF non-symmetric, two RMS values are calculated
;	one for the positive, and one for the negative side of the CDF.
;		Finally OUT = DIFF/RMS where the negative and positive values of DIFF are divided by the 
;	corresponding RMS.
;		User may then decide which channels are acceptable. Removing channels where abs(RMS) > 5 
;	is usually good. Note that it may be that all cases where OUT < 0 may be clear of RFI if the RFI
;	is only positive. 
;		The presence of strong negative values in OUT may indicate that RFIWIDTH is too low.
;
;	Written by Marko Krco	Aug 5th, 2016
;
;-
 





status=strarr(1)
status[0]=Systime() + " Begun"

if (n_elements(chanmask) eq 0) then chanmask=in*0+1
mask=where(chanmask eq 1)
nchan=n_elements(chanmask)
oriindex=indgen(n_elements(in))
ngoodchan=n_elements(where(chanmask eq 1))

tmp= double(in[mask])

if (n_elements(rfiwidth) eq 0) then begin
	;If maxrfiwidth is not set, set it to default
	if (n_elements(maxrfiwidth) eq 0) then maxrfiwidth=30

	fwstd=dblarr(4,maxrfiwidth-2)
	for i=0, maxrfiwidth-3 do fwstd[*,i]=moment(tmp-median(tmp,(i*2)+3),/nan, maxmoment=1)


	maxi=where(fwstd[0,*] eq max(fwstd[0,*]))
	effwidth=(maxi*2)+3
	rfiwidth=(effwidth+1)/2
endif


;CALCULATE DIFFERENCE BETWEEN DATA AND MEDIAN OF DATA--SHOWS SPIKES
tmpmed= median( tmp,(rfiwidth*2)-1,/double)
diff= tmp- tmpmed 

;Make the cumulative distribution
cumx=diff[sort(diff)]
cumy=indgen(ngoodchan)/(ngoodchan*1.)
cut= (1.- 0.683)/2.
indxmin= min(where( cumy ge cut))
indxmax= min(where( cumy ge 1.-cut))

cum={X:cumx, Y:cumy}

;It can happen that more than 68.3% of the cumx points have value 0. 
;In this case use the first non-zero values as indxmin and indxmax 
if (cumx[indxmin] eq cumx[indxmax]) then begin
	misc=where(cumx eq 0)
	indxmin=min(misc)-1
	indxmax=max(misc)+1
	status=[status, '1 - More than 68.3 percent of the points in the cumulative distribution function had value 0. Had to estimate RMS. This may be okay. Probably there are too many channels with 0, or constant values.']
		
endif

;Because the cumulative distribution is not necessarily symmetric, we will keep two rms values
rms=[cumx[indxmin], cumx[indxmax]]

;Assing S/N values to each channel do it separately for channels where diff is negative and positive
out=in*alog(-1.)
misc=where(diff lt 0)
;Preserve the negative sign on the output S/N
if (misc[0] ne -1) then out[mask[misc]]=diff[misc]/abs(rms[0])
misc=where(diff gt 0)
if (misc[0] ne -1) then out[mask[misc]]=diff[misc]/abs(rms[1])
misc=where(diff eq 0)
if (misc[0] ne -1) then out[mask[misc]]=0.

end

