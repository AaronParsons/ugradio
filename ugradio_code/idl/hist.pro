pro hist, data, x, h,$
          ; HISTOGRAM KEYWORDS...
          BINSIZE=binsz, $
          MIN=mn, $
          MAX=mx, $
          NBINS=nbins, $
          ; KEYWORDS UNIQUE TO THIS ROUTINE...
          HISTNORMALIZED=histnormalized, $
          SCALE=scale, $
          NOPLOT=noplot, $
          BARPLOT=barplot, $
          ; PLOT KEYWORDS...
          XTITLE=xtitle, $
          LOG=log,       $
          YLOG=ylog,     $
          XLOG=xlog,     $
          COLOR=color,   $
          THICK=thick,   $
          OVERPLOT=overplot, $
          ; FILL KEYWORDS...
          FILL=fill, $
          LINE_FILL_STYLE=line_fill_style, $
          ORIENTATION=orientation, $          ; CCW DEGREES FROM HORIZ
          SPACING=spacing, $                  ; CENTIMETERS
          _REF_EXTRA=extra

;+
; NAME:
;       HIST
;     
; PURPOSE:
;       To plot or overplot the distribution of a data set.
;     
; CALLING SEQUENCE:
;       hist, data [,x][,h][,BINSIZE=binsize][,MIN=min][,MAX=max][,
;          XTITLE=xtitle][,XRANGE=xrange][,YRANGE=yrange][,/LOG][, 
;          COLOR=color][,THICK=thick][,/OVERPLOT][[,
;          /FILL][,LINE_FILL_STYLE=line_fill_style][,
;          ORIENTATION=orientation][,SPACING=spacing]]
;     
; INPUTS:
;       DATA = The vector or array for which the density function is 
;              to be computed.
;     
; OPTIONAL INPUTS:
;       X = Vector of abscissa values at which to calculate the 
;           density function.
;
;       BINSIZE = Set this keyword to the size of the bin to use. If this
;                 keyword is not specified, then a bin size of 1 is used.
;                 Has no effect if abscissa X is provided.
;
;       MIN = Set this keyword to the minimum value to consider. If this 
;             keyword is not specified, and DATA is of type byte, 0 is 
;             used. If this keyword is not specified and DATA is not of 
;             byte type, DATA is searched for its smallest value. Has no 
;             effect if abscissa X is provided.
;       
;       MAX = Set this keyword to the maximum value to consider. If this 
;             keyword is not specified, DATA is searched for its largest 
;             value. Has no effect if abscissa X is provided.
;       
;	NBINS = nr of bins. use in conjunction with MIN and MAX, and
;		don't specify BINSIZE
;
;       COLOR = The color index of the data, text, line, or solid polygon 
;               fill to be drawn. If this keyword is omitted, !P.COLOR 
;               specifies the color index.
;
;       THICK = Indicates the line thickness for both the histogram and
;               the lines filling the histogram.
;
;       LINE_FILL_STYLE = The line style used to draw lines filling 
;                         histogram: 0=Solid, 1=Dotted, 2=Dashed, 3=Dash Dot,
;                         4=Dash Dot Dot, 5=Long Dashes
;
;       ORIENTATION = Specifies the counterclockwise angle in degrees from 
;                     horizontal of the text baseline and the lines used 
;                     to fill polygons.When used with the POLYFILL procedure, 
;                     this keyword forces the "linestyle" type of fill, rather 
;                     than solid fill.
;      
;       SPACING = The spacing, in centimeters, between the parallel lines 
;                 used to fill polygons.
;     
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       X = Vector of abscissa values at which to calculate the 
;           density function.
;
;       H = Vector of histogram values.
;
; KEYWORDS:
;       /LOG : Set this keyword to specify the logarithm of the
;              histogram be displayed on a linear Y axis.
;
;       /YLOG : Set this keyword to specify a logarithmic Y axis.
;
;       /XLOG : Set this keyword to specify a logarithmic X axis.
;
;       /OVERPLOT : Set this keyword to plot density function over a 
;                   previously-drawn histogram.
;
;       /FILL : Set this keyword to indicate that histogram is to be filled.
;
; COMMON BLOCKS:
;       None.
;
; PROCEDURES CALLED:
;       None.
;
; EXAMPLE:
;       IDL> data = randomn(seed,1000)
;       IDL> hist, data, x, h, BIN=0.1, MIN=-10, MAX=10, /YLOG, $
;       IDL> /FILL, LINE_FILL_STYLE=0, SPACING=0.3, ORIENTATION=50
;
;       Now X contains the abscissa values, so we may overplot another
;       distribution:
;
;       IDL> data2 = 0.5*randomu(seed,100,/normal)
;       IDL> hist, data2, x, /OVERPLOT, /FILL
;
; NOTES:
;       This routine assumes the abscissa values are bin centers!
;
;       *ANY* of the keywords for PLOT, OPLOT, or HISTOGRAM may be
;       set or passed back to the calling function since we've
;       made use of the _REF_EXTRA keyword to allow for passing
;       keywords by reference!  Example:
;
;       IDL> hist, data, /L64, title='TEST', REVERSE_INDICES=bobo
;
;       The IDL HISTOGRAM function is peculiar.
;       If you want the histogram for bins that run from
;       [-50<=x<-25], [-25<=x<0], [0<=x<25], [25<=x<50],
;       you have to enter keywords MIN=-50, MAX=49, BINSIZE=25
;       If (MAX-MIN+1) MOD BINSIZE is not ZERO, then the final bin of
;       the histogram will not cover an entire range of size BINSIZE.
;       e.g., histogram(DATA,MIN=-50,MAX=50,BINSIZE=25) will return 
;       FIVE bins and the final bin will contain the number of times the

;
;       In small-number statistics, one might wish to avoid
;       misrepresenting the *density* of the last bin by cutting off
;       the histogram at the abscissa value MAX!  Unless specified,
;       the X range is enforced to be from MIN to MAX.
;
; IDL'S HISTOGRAM FUNCTION IS IN ESSENCE LEFT JUSTIFIED.
; LEFT EDGES OF BINS ARE DETERMINED BY:
; LBIN = MIN + BINSIZE * FINDGEN((MAX-MIN)/BINSIZE+1)
; RBIN = (LBIN + BINSIZE) < MAX
; LBIN <= DATA < RBIN
; THUS, (1) THE ABSCISSA VALUES ARE THE CENTERS OF EACH BIN:
; NBINS = (MAX-MIN)/BINSIZE + 1
; BINCEN = MIN + BINSIZE * (0.5 + FINDGEN(NBINS))
; THIS DOESN'T EXACTLY MAKE SENSE SINCE THE RIGHTMOST BIN DOES NOT
; HAVE THE SAME THE BIN WIDTH AS THE REST OF THE BINS.  THE ONLY WAY
; FOR THE HITOGRAM TO MAKE SENSE IS TO FORCE THE MAXIMUM TO:
; MAX = NBINS*BINSIZE + MIN
; THIS IS HOW THE RETURNED ABSCISSA CAN HAVE A FINAL BIN CENTER THAT
; IS BEYOND THE MAX VALUE SENT IN.
; IF THE USER WANTS AN EXACT
;
; MODIFICATION HISTORY:
;       Written Tim Robishaw, Berkeley 5 Sep 2001
;       Added keywords passed by reference. TR 24 Jan 2002
;       Completely revamped and souped up. TR 26 Feb 2004
;-

on_error, 0
; RETURN TO CALLER ON ERROR...
;on_error, 2

;!!!!!!!!!!!!
; TRY FILLING SOLID... DO WE WANT TO ADD BASELINE AT ZERO FOR NON-LOG???

; MAYBE WE WANT A DIFFERENT FILL COLOR?

; IF YOU WANT THE AXES TO BE AN ODD COLOR, SET THE COLOR USING !P.COLOR

;!!!!!!!!!!!!
; MAY HAVE PROBLEMS IF X VAL'S <= 0 AND /XLOG
; DO WE WANT FEATURE TO HAVE LOGARITHMIC BINS???
; THEN WE CAN USE /XLOG AND HAVE EQUAL BINSIZE...
; EQUIVALENT TO SENDING IN ALOG10(DATA)...
; DO WE NEED NBINS KEYWORD...



; DOES DATA ARRAY EXIST...
if (N_elements(data) eq 0) then message, 'Array DATA is empty.'

if (N_elements(BINSZ) gt 0) AND (N_elements(NBINS) gt 0) AND (N_elements(MX) gt 0)$
  then message, 'Conflicting keywords: NBINS BINSIZE MAX'

; IF BOTH LOG AND YLOG SET, WARN USER...
if (keyword_set(LOG) AND keyword_set(YLOG)) $
  then message,'Conflicting keywords: LOG YLOG'

; GET THE DATA TYPE...
; HISTOGRAM FUNCTION STRONGLY SUGGESTS THAT MIN, MAX AND BINSIZE
; HAVE THE SAME DATA TYPE AS THE DATA ARRAY... 
datatype = size(data,/TYPE)

; ARE THE MAX AND MIN VALUES SET...
datamin = fix(((N_elements(MN) eq 0) ? min(data,/NAN) : mn),TYPE=datatype)
datamax = fix(((N_elements(MX) eq 0) ? max(data,/NAN) : mx),TYPE=datatype)

if (datamax le datamin) then message, 'You suck!'

autobin = (N_elements(NBINS) eq 0) AND (N_elements(BINSZ) eq 0)

; DETERMINE THE BINSIZE...
binsize = (N_elements(BINSZ) gt 0) ? fix(binsz,TYPE=datatype) : $
;          ((N_elements(NBINS) eq 0) ? (datamax-datamin)/9. : $
          ((N_elements(NBINS) eq 0) ? (datamax-datamin)/sqrt(2*N_elements(data)) : $
           (datamax-datamin)/(nbins-1))

tryagain:

; DETERMINE NUMBER OF BINS...
nbins = (N_elements(NBINS) eq 0) $
        ? floor((datamax-datamin)/binsize,/L64)+1 : long64(nbins)

help, binsize, datamin, datamax, nbins
;return

; RETURN X AS THE ABSCISSA VALUES AT CENTERS OF BINS...
; IF NOT INTEGER TYPE DATA, THEN CENTER JUSTIFY THE BINS...
not_integer=1
;not_integer = (datatype ge 4) AND (datatype le 11)
x = binsize*dindgen(nbins) + datamin + not_integer*0.5*binsize
h = histogram(data, BINSIZE=binsize, $
              MIN=datamin, MAX=datamax, /NAN, _EXTRA=extra)



if N_elements(x) ne N_elements(h) then stop, 'Yikes!'
if (total(h) eq 0.0) then message, 'Poorly chosen MIN/MAX/BINSIZE!'

; DO WE WANT TO NORMALIZE THE HISTOGRAM...
; MIGHT BE INTERESTED IN COMPARING PDFS OVER A GIVEN RANGE...
; THIS CASE SHOWS US THAT WE DON'T NORMALIZE BY THE TOTAL NUMBER
; OF POINTS IN THE HISTOGRAM, RATHER THE TOTAL NUMBER OF DATAPOINTS
; (MANY DATAPOINTS MAY BE REJECTED BY MIN/MAX, BUT THEY SHOULD
; STILL AFFECT THE NORMALIZATION OF THE HISTOGRAM!)
if keyword_set(HISTNORMALIZED) then h = h / total(finite(data),/DOUBLE)
;if keyword_set(HISTNORMALIZED) then h = h / total(h,/DOUBLE)

; DO WE WANT TO SCALE THE HISTOGRAM...
if (N_elements(SCALE) gt 0) then h = h * scale / double(max(h))

; IF YOU ONLY WANT THE HISTOGRAM AND BIN CENTERS THEN SPLIT...
if keyword_set(NOPLOT) then return

if (nbins gt 500000LL) then message, 'Too many bins, douchebag!', /INFO


;==================================
; NOW PLOT THE HISTOGRAM...

; DO WE WANT TO TAKE THE LOGARITHM...
; WE WANT TO REPLACE ZEROS WITH THE MINIMUM REPRESENTABLE
; DOUBLE-PRECISION FLOATING POINT VALUE... THIS WILL PREVENT
; ANY CHOKING WHEN LOGARITHMS ARE TAKEN...
buffer = keyword_set(LOG) OR keyword_set(YLOG) ? (machar(/DOUBLE)).xmin : 0
histo  = h>buffer
if keyword_set(LOG) then begin
    histo = alog10(histo)
    buffer = alog10(buffer)
endif

; SET UP THE HISTOGRAM AXES...
if not keyword_set(OVERPLOT) then begin

    ; IF PASSED IN AS KEYWORD BY REFERECE, THAT YTITLE WILL HAVE PRECEDENCE...
    ytitle = keyword_set(LOG) ? 'log N' : 'N'

    ; IF NOT SPECIFIED, ENFORCE THE XRANGE TO COVER MIN TO MAX...
    ; IF PASSED IN AS KEYWORD BY REFERECE, THAT XRANGE WILL HAVE PRECEDENCE...
;    xrange = [min(data,/NAN)>datamin,max(data,/NAN)<datamax]
    xrange = [datamin,datamax] + binsize*[-1,1]

    ; IF NOT SPECIFIED, ENFORCE THE CONVENIENT YRANGE...
    ; IF PASSED IN AS KEYWORD BY REFERECE, THAT YRANGE WILL HAVE PRECEDENCE...
    ; THE HISTOGRAM WILL ALWAYS HAVE AT LEAST ONE NON-NEGATIVE VALUE
    case 1 of
        keyword_set(LOG) : yrange = alog10([0.7*min(h[where(h gt 0)]),max(h)])
        keyword_set(YLOG): yrange = [0.7*min(h[where(h gt 0)]),max(h)]
        else : yrange = [min(h),max(h)]
    endcase

    ; SET UP THE PLOTTING AXES...
    ; DEFAULT IS TO EXTEND THE AXIS RANGES...
    plot, [0], /NODATA, $
          XSTYLE=7, XRANGE=xrange, XLOG=keyword_set(XLOG), $
          YSTYLE=7, YRANGE=yrange, YLOG=keyword_set(YLOG), $
          _EXTRA=extra

endif

; GET THE RANGES OF AXES...
xrange = !x.type ? 1d1^(!x.crange) : !x.crange
yrange = !y.type ? 1d1^(!y.crange) : !y.crange

; USE THE SYSTEM COLOR IF NOT SET...
if (N_elements(COLOR) eq 0) then color=!p.color
if (N_elements(THICK) eq 0) then thick=1

; FILL IN THE HISTOGRAM...
if keyword_set(FILL) then begin

    ; FIND ALL THE VERTICES OF THE HISTOGRAM...
    xaxis = reform(transpose([[x-0.5*binsize],$
                              [x+0.5*binsize]]),N_elements(x)*2)
    yaxis = reform(transpose([[histo],[histo]]),N_elements(histo)*2)

    ; ENFORCE SHADING INSIDE AXES...
    xaxis = [xaxis[0],xaxis,xaxis[N_elements(xaxis)-1]]<xrange[1]>xrange[0]
    yaxis = [buffer,yaxis,buffer]<yrange[1]>yrange[0]

    ; FILL IN THE HISTOGRAM WITH POLYGONS...
    polyfill, xaxis, yaxis, COLOR=color, $
              THICK=thick, $
              LINESTYLE=line_fill_style, $
              SPACING=spacing, $
              ORIENTATION=orientation

endif

; OVERPLOT THE HISTOGRAM...
oplot, [x[0]-binsize,x,x[N_elements(x)-1]+binsize], [buffer,histo,buffer], $ 
;       PSYM=10, COLOR=color, THICK=thick, _EXTRA=extra
       PSYM=10, COLOR=!cyan, THICK=thick, _EXTRA=extra

x = [x[0]-binsize,x,x[N_elements(x)-1]+binsize]
y = [buffer,histo,buffer]

th = floor(thick)
xthick = (th gt 1) ? ([-1,1]*th/2+[0,th mod 2 eq 1]) / !x.s[1] / !d.x_vsize : 0
ythick = (th gt 1) ? ([-1,1]*th/2+[0,th mod 2 eq 1]) / !y.s[1] / !d.y_vsize : 0

; DRAW TOPS OF BINS...
for i = 0, N_elements(x)+1 do $
    plots, x[[i,i+1]]-0.5*binsize+xthick, y[[i,i]]>yrange[0], COLOR=color, THICK=thick

; DRAW SIDE OF BINS...
for i = 0, N_elements(x) do $
    plots, x[[i,i]]+0.5*binsize, (y[[i,i+1]]+ythick)>yrange[0], COLOR=color, THICK=thick

; DO WE WANT TO DRAW BINS IN BARPLOT FASHION...
if keyword_set(BARPLOT) then $
  for i = 0, N_elements(histo)-2 do $
     plots, x[i]*[1,1]+0.5*binsize, [histo[i],buffer]>yrange[0], $
            COLOR=color, THICK=thick

if keyword_set(OVERPLOT) then return

; TO AVOID PROBLEMS WITH !P.MULTI WE NEED TO USE AXIS INSTEAD OF PLOT...
; WE PLOT AXES AFTER HISTOGRAM SO THAT TICKMARKS AREN'T OVERWRITTEN...
axis, XAXIS=0, XSTYLE=1, XRANGE=xrange, XLOG=!x.type, COLOR=!p.color, $
      XTITLE=xtitle, _EXTRA=extra
axis, XAXIS=1, XSTYLE=1, XRANGE=xrange, XLOG=!x.type, COLOR=!p.color, $
      XTICKFORMAT='(A1)', _EXTRA=extra
axis, YAXIS=0, YSTYLE=1, YRANGE=yrange, YLOG=!y.type, COLOR=!p.color, $
      YTITLE=ytitle, _EXTRA=extra
axis, YAXIS=1, YSTYLE=1, YRANGE=yrange, YLOG=!y.type, COLOR=!p.color, $
      YTICKFORMAT='(A1)', _EXTRA=extra

end; hist

;if keyword_set(XLOG) then begin
;    n = floor((alog10(datamax/datamin))/binsize,/L64)+1
;    x = 10d^(binsize*dindgen(n)) + datamin
;    round_data = double(round(alog10(data)/binsize,/L64))
;    h = histogram(round_data, BINSIZE=1d0, $
;                  MIN=alog10(datamin)/binsize, $
;                  MAX=alog10(datamax)/binsize, $
;                  /NAN, _EXTRA=extra)
;endif
