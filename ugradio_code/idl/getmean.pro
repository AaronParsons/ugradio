;=======================================================================;
; Procedure getmean		Tim Robishaw: 1/28/99	 		;
;-----------------------------------------------------------------------;
; INPUTS:	t		:	Temperature			;
;-----------------------------------------------------------------------;
; OUTPUTS: 	mean		:	Mean Temperature of Baseline	;
; 		rms		:	RMS Temperature of Baseline	;
;-----------------------------------------------------------------------;
; DESCRIPTION: 	IF NO SPECTRUM, MEAN AND RMS ARE RETURNED UNDEFINED!!!	;
;=======================================================================;

pro getmean, t, mean, rms, FOUND=found, FIX=fix, RMS0=rms0, WATCH=watch

tsize = N_elements(t)			 ; NUMBER OF CHANNELS IN SPECTRUM.

found = 0

if finite(t[0], /NaN) then return 	 ; IF NO SPECTRUM, THEN SPLIT!

found = 1

nsmooth = 3
hanningkernel = [0.25, 0.50, 0.25]
hanningredux = sqrt(total(binomialdist(2*nsmooth)^2))

smoothy=t				 ; SMOOTH THE SPECTRUM LIKE SILLY!
for i= 1, nsmooth do smoothy = convol(smoothy, hanningkernel, /edge_truncate)

if not keyword_set(rms0) then begin

; THE DISPERSION IN TRMS THROUGHOUT THE LDS IS VERY LARGE, SO TAKING
; 0.07K AS A GOOD FIRST GUESS AT THE RMS IS NOT A GREAT IDEA. INSTEAD,
; WE TAKE THE RMS OF THE FIRST AND LAST 150 CHANNELS TO BE A GOOD
; GUESS.  IF THE MEAN OF EITHER THE FIRST OR LAST 150 CHANNELS IS
; GREATER THAN THEIR RMS THEN WE CONSIDER ONLY THE PORTION THAT HAS
; MEAN LESS THAN RMS.  MAY NOT BE GREAT WAY TO DO THINGS FOR NON-LDS WORK.
;rms0 = 0.07

    meanleft = (moment(t[0:150], sdev=rmsleft))[0]
    meanright= (moment(t[tsize-150:*], sdev=rmsright))[0]

    if (meanleft lt rmsleft) then begin
	if (meanright lt rmsright) $
      		then spec = [t[0:150],t[tsize-150:*]] $
    		else spec = t[0:150]
	endif else spec = t[tsize-150:*]
	useless = moment(spec, sdev=rms0)
endif

threshold = 5*hanningredux*rms0

big = abs(smoothy) ge threshold	; 5 TIMES MEAN SIGMA OF LDS.
bigright = [2,big[0:tsize-2]]	; SHIFT RIGHT, BUFFER FIRST WITH 2.
bigleft  = [big[1:*],2] 	; SHIFT LEFT, BUFFER LAST WITH 2.

; AT WHAT BINS DOES THE SPECTRUM DIP BELOW THE THRESHOLD?
start = where((big eq 0) AND (bigright eq 1) AND (bigleft eq 0), startcount)
stop  = where((big eq 0) AND (bigleft eq 1) AND (bigright eq 0), stopcount)

; WE WANT TO GET THE PORTIONS OF THE SPECTRUM THAT LIVE WITHIN +/-THRESHOLD.
; START IS WHERE THESE REGIONS BEGIN, STOP WHERE THEY END.
; ADD THE FIRST AND LAST BINS AS START AND STOP POINTS.
if (startcount eq 0) $
	then start=[0] $
	else if (start[0] gt stop[0]) $
		then start=[0,start]
if (stopcount eq 0) $
	then stop=[tsize-1] $
	else if (N_elements(start)-N_elements(stop) eq 1) $
		then stop=[stop,tsize-1]

if keyword_set(watch) then begin
    plot, smoothy, ps=10, co=cyan, /xs, /ys, yr=[-1.2*threshold,max(smoothy)]
    oplot, fltarr(tsize)+threshold,co=red
    oplot, fltarr(tsize)-threshold,co=red
    oplot, start, smoothy[start], co=green, ps=5
    oplot, stop, smoothy[stop],co=orange, ps=5
endif

;========== FOLLOW THE SPECTRUM DOWN TO WHERE IT CROSSES ZERO K ==========
sign = 1-2*(smoothy lt 0)	 ; WHAT IS THE SIGN OF EACH BIN?

; WHERE DOES THE SPECTRUM CHANGE SIGN?
turn = where((sign+shift(sign,1))[1:*] eq 0, nturn)+1

stop1 = intarr(1) & start1=stop1

; MAKE BASELINE REGIONS START AT FIRST ZERO CROSSING AHEAD OF THE POINTS
; WHERE SPECTRUM ENTERS +/- THRESHOLD AND STOP AT FIRST ZERO CROSSING PRIOR
; TO WHERE SPECTRUM LEAVES +/- THRESHOLD.
for i = 0, N_elements(stop)-1 do begin
	turnindx = where((turn gt start[i]) AND (turn lt stop[i]), crossing)

	; THE SPECTRUM MAY NEVER CROSS ZERO K IN THIS REGION!
	; ALSO, IF DOES CROSS JUST ONCE, THEN FORGET IT.
	if (crossing gt 1) then begin
		if (stop[i] ne tsize-1) $
			then stop1 = [stop1,turn[turnindx[crossing-1]]-1] $
			else stop1 = [stop1,tsize-1]

		if (start[i] ne 0) $ 
			then start1 = [start1,turn[turnindx[0]]] $
			else start1 = [start1,0]
	endif
endfor

; IF THERE WERE NO DEVIATIONS FROM FLATNESS.. JUST SPLIT.
if (N_elements(start1) eq 1) then return

start = start1[1:*] & stop = stop1[1:*]		; REMOVE ZEROS AT HEAD.

v = indgen(tsize)
channel = v[start[0]:stop[0]]
for i = 1, N_elements(start)-1 do channel = [channel,v[start[i]:stop[i]]]

if keyword_set(fix) then goto, correlator_correction

baseline = t[channel]
mean = (moment(baseline, sdev=rms))[0]

if keyword_set(watch) then $
  oplot, channel, baseline*0+mean, ps=6

nsig = abs(baseline-mean)/rms		 ; HOW MANY SIGMA ARE THEY AWAY?
P=1-(gaussint(nsig)-gaussint(-1.*nsig))	 ; WHAT IS PROB. OUTSIDE nsig*SIGMA?
ndev = N_elements(baseline)*P		 ; EXPECTED # AS DEVIANT AS THIS.

rejects = where(ndev lt 0.5, nrejects)	 ; CHAUVENET SAYS ndev < .5 : REJECT!

if (nrejects eq 0) then return

baseline = baseline[where(ndev ge 0.5)]	
mean = (moment(baseline, sdev=rms))[0]

return

correlator_correction:

; SUBTRACT MEAN OF EVEN CHANNELS FROM EVEN CHANNELS.
evenchannel = channel[where(channel mod 2 eq 0)]
evenmean = (moment(t[evenchannel]))[0]
even = v[where(v mod 2 eq 0)]
t[even] = t[even] - evenmean

; SUBTRACT MEAN OF ODD CHANNELS FROM ODD CHANNELS.
oddchannel  = channel[where(channel mod 2 eq 1)]
oddmean = (moment(t[oddchannel]))[0]
odd  = v[where(v mod 2 eq 1)]
t[odd]  = t[odd]  - oddmean

end ; getmean
;==========================================================================
