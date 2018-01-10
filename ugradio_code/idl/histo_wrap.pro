pro histo_wrap, x, min, max, nbins, bin_edges, bin_cntrs, hx, $
        reverse_indices=reverse_indices

;+
;NAME:
;histo_wrap -- wrapper for histogram that returns the RH bin edges and centers
;
;PURPOSE: wrapper for histogram that returns the RH bin edges and bin centers
;**** NOTE FIXED INPUTS: MAX, MIN, NBINS ****** aviods the
;awkwardness of specifying binsize. 
;
;
;NOTE ALSO: if a point falls exactly on a bn boundary, it is put into
;the higher bin.  Thus, if you set MAX equal to the highest data value,
;there will be exactly one entry in the highest bin (assuming that only
;one data value has this maximum value). 
;
;CALLING SEQUENCE:
;	histo_wrap, x, min, max, nbins, bin_edges, bin_cntrs, hx, $
;        reverse_indices=reverse_indices
;
;INPUTS:
;	X, the input array
;	MIN, the numerical value of the RIGHT-hand (RH) bin edge 
;of the smallest bin (the LEFT-hand bin) in the histogram
;	MAX, the numerical value of the RIGHT-hand (RH) bin edge 
;of the largest bin (the RIGHT-hand bin) in the histogram
;	NBINS, the nr of bins in the histogram
;
;**************** IMPORTANT NOTE **********************************
;	if MAX is larger than the largest data value, there will be no
;entries in the last bin
;
;OUTPUTS
;	BIN_EDGES -- the numerical values of the RH edges of the bins
;	BIN_CNTRS -- the numerical values of the centers of the bins
;	HX, the histogram of the input array x
;
;OPTIONAL OUTPUTS
;       REVERSE_INDICES -- the indices that fall in each histogram bin.
;There are NBINS bins, numbered from nr=0 to nr=NBINS-1. Let 
;        REVERSE_INDICES = REV 
;Then the indices of X that lie in bin number NR are:
;        INDICES_NR = REV[ REV[NR]:REV[NR+1]-1]
;
;(See IDL's documentation for HISTOGRAM)
;-
;

dmin= double(min)
dmax= double(max)
;dx= double( x)

bin_edges= dmin+ (dmax-dmin)* (dindgen( nbins)/ ( nbins-1l))
bin_cntrs= dmin+ (dmax-dmin)* ( (dindgen( nbins)+0.5d)/ ( nbins-1l))
hx = histogram( x, nbins= nbins, min=dmin, max=dmax, $
        reverse_indices=reverse_indices)

return
end
