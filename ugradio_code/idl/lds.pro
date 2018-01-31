;========================== SUBROUTINES ===================================

;=======================================================================;
; Procedure plotspectrum.pro 	Tim Robishaw: 4/11/98	 		;
;-----------------------------------------------------------------------;
; INPUTS:	none							;	;-----------------------------------------------------------------------;
; OUTPUTS: 	none							;
;-----------------------------------------------------------------------;
; DESCRIPTION:	Plots the LDS HI spectrum at l,b.			;
;=======================================================================;

pro plotspectrum, PS=ps
common spectrum, l, b, vlsr, v, t, originalt, vmin, vmax, tmax, tmin, title
common fitdat, nsig, mean, nrg1, cen1, wid1, hgt1, nrg2, cen2, wid2, hgt2

plot, v, t, title=title, /xstyle, /ystyle, yrange=[tmin-.07,tmax+.07], $
xtitle='V!ILSR!N [km s!E-1!N]', ytitle='T!DB!N [K]', $
ticklen=1, /xgridstyle, /ygridstyle, /nodata 

oplot, !x.crange, [0,0], color=!orange*(1-keyword_set(ps))
oplot, v, t, psym=10, color=!cyan*(1-keyword_set(ps))

if (nrg1 gt 0) then $
	indiplot, vlsr, mean, cen1, wid1, hgt1, !yellow*(1-keyword_set(ps))
if (nrg2 gt 0) then $
	indiplot, vlsr, mean, cen2, wid2, hgt2, !yellow*(1-keyword_set(ps))

end ; plotspectrum
;===========================================================================

;=======================================================================;
; Procedure zoomin.pro	Tim Robishaw: 4/11/98                           ;
;-----------------------------------------------------------------------;
; INPUTS:	none							;
;-----------------------------------------------------------------------;
; OUTPUTS: 	none							;
;-----------------------------------------------------------------------;
; DESCRIPTION:	Let's user select the range of the HI spectrum to be    ;
;		zoomed-into for a better-resolved look at a portion of	;
;		the spectrum.						;
;=======================================================================;

pro zoomin
common spectrum, l, b, vlsr, v, t, originalt, vmin, vmax, tmax, tmin, title

; Prompt to select left boundary of zoom.
b = widget_base()
command = widget_text(b, value = ' Move cursor to minimum VLSR and click left button.')
widget_control, b, /realize
cursor, vmin, y, /up

; Prompt to select right boundary of zoom.
command = widget_text(b, value = 'Move cursor to maximum VLSR and click left button. ')
cursor, vmax, y, /up
widget_control, b, /destroy

t = originalt[vtobin(vlsr,vmin):vtobin(vlsr,vmax)]
v = vlsr[vtobin(vlsr,vmin):vtobin(vlsr,vmax)]

tmax = max(t, min=tmin)

plotspectrum

end ; zoomin
;===========================================================================

;=======================================================================;
; Procedure average.pro 	Tim Robishaw: 4/11/98	 		;
;-----------------------------------------------------------------------;
; INPUTS:	none							;
;-----------------------------------------------------------------------;
; OUTPUTS: 	none							;
;-----------------------------------------------------------------------;
; DESCRIPTION: 			;
;=======================================================================;

pro average
common spectrum, l, b, vlsr, v, t, originalt, vmin, vmax, tmax, tmin, title

print, format='($, "Enter the number of channels to average ( >2 )")'
read, n

if n eq 1 then return

t = originalt

for i = 0, ((N_elements(t)-1)/n)-1 do begin 
	range = indgen(n)+n*i  
	t[range] = (moment(t[range]))[0] 
endfor 

if N_elements(t) mod n ne 1 then t[n*i:*] = (moment(t[n*i:*]))[0]

t = t[vtobin(vlsr,vmin):vtobin(vlsr,vmax)]

plotspectrum

end ; average
;===========================================================================

pro tzoomin
common spectrum, l, b, vlsr, v, t, originalt, vmin, vmax, tmax, tmin, title

tmin = min(t)
tmax = max(t)

; Prompt to select bottom boundary of zoom.
b = widget_base()
command = widget_text(b, value = ' Move cursor to minimum T and click left button.')
widget_control, b, /realize
cursor, x, tmin, /up

; Prompt to select top boundary of zoom.
command = widget_text(b, value = 'Move cursor to maximum T and click left button. ')
cursor, x, tmax, /up
widget_control, b, /destroy

tmax = max([tmax,tmin], min=tmin)

plotspectrum

end ; tzoomin
;===========================================================================

pro fitspec

common spectrum, l, b, vlsr, v, t, originalt, vmin, vmax, tmax, tmin, title
common fitdat, nsig, mean, nrg1, cen1, wid1, hgt1, nrg2, cen2, wid2, hgt2

; WHAT ARE VELOCITY CUTOFFS ACCORDING TO CIRCULAR DIFFERENTIAL ROTATION MODEL?
model, l, b, minv, maxv

;==================== CUTOFF THE SPECTRUM ================================
t1 = originalt[0:vtobin(vlsr, minv)]
vlsr1 = vlsr[0:vtobin(vlsr, minv)]

t2 = originalt[vtobin(vlsr, maxv):*]
vlsr2 = vlsr[vtobin(vlsr, maxv):*]

getmean, originalt, mean, rms

cutoff, vlsr1, t1, mean, rms

cutoff, vlsr2, t2, mean, rms

fithi, vlsr1, t1, mean, rms, zro1, hgt1, cen1, wid1, tfit1, nrg1, problem, sigma1, sigzro1, sighgt1, sigcen1, sigwid1;, /watch

fithi, vlsr2, t2, mean, rms, zro2, hgt2, cen2, wid2, tfit2, nrg2, problem, sigma2, sigzro2, sighgt2, sigcen2, sigwid2;, /watch

cen = fltarr(1)
hgt = cen
wid = cen
sigcen = cen
sigwid = cen
sighgt = cen

if (nrg1 gt 0) then begin
    cen = [cen,cen1]
    wid = [wid,wid1]
    hgt = [hgt,hgt1]
    sigcen=[sigcen,sigcen1]
    sigwid=[sigwid,sigwid1]
    sighgt=[sighgt,sighgt1]
endif

if (nrg2 gt 0) then begin
    cen = [cen,cen2]
    wid = [wid,wid2]
    hgt = [hgt,hgt2]
    sigcen=[sigcen,sigcen2]
    sigwid=[sigwid,sigwid2]
    sighgt=[sighgt,sighgt2]
endif

if (nrg1+nrg2 gt 0) then begin
    cen=cen[1:*]
    wid=wid[1:*]
    hgt=hgt[1:*]
    sigcen=sigcen[1:*]
    sigwid=sigwid[1:*]
    sighgt=sighgt[1:*]

    print, 'vlsr','+/-','','dv','+/-','','T','+/-', format='(A4,A6,A5,A6,A5,A4,A7,A6)'

    print, [transpose(cen), transpose(sigcen),transpose(wid),transpose(sigwid),transpose(hgt), transpose(sighgt)], format='(1f7.2,1f8.2,1f8.1,1f7.1,1f10.4,1f10.4)'
endif

plotspectrum

io=dialog_message('Fit results are in the IDL window.', /info)
clear

end ; fitspec

;===========================================================================

pro ps_spec_event, ev
common PostScript, PSPath, Printers

filename = 'lds.ps'

set_plot, 'ps'
device, filename=PSPath+filename, /landscape, /bold
plotspectrum, /ps
device, /close
set_plot, 'x'

widget_control, ev.id, get_uvalue=uval

Nprinters = N_elements(Printers)

print, uval
print, Nprinters

case uval of
          1 : io=dialog_message('File is stored in '+PSPath+filename,/info)
Nprinters+2 : begin & end
       else : begin
                Printer = Printers[uval-2]
                spawn, 'lp -d '+Printer+' '+PSPath+filename
                io=dialog_message('File is being printed to '+Printer+'.',/inf)
                spawn, '/usr/bin/rm -f '+PSPath+filename
              end
endcase
widget_control, ev.top, /destroy
select
end 

pro ps_spec
common PostScript

base = widget_base(/column)
button = widget_button(base, value='Print To File', uvalue=1)

for i = 0, N_elements(Printers)-1 do $
useless = execute('button = widget_button(base, value='''+printers[i]+''', uvalue='+strtrim(i+2,2)+')')

useless = execute('button = widget_button(base, value=''Back to Menu'', uvalue='+strtrim(i+2,2)+')')

widget_control, base, /realize
xmanager, 'ps_spec', base

end                             ; ps_spec

;===========================================================================

;=======================================================================;
; Procedure select.pro		Tim Robishaw: 4/11/98	 		;
;-----------------------------------------------------------------------;
; INPUTS:	none							;	;-----------------------------------------------------------------------;
; OUTPUTS: 	none							;
;-----------------------------------------------------------------------;
; DESCRIPTION:	
;=======================================================================;

pro select_event, ev

common spectrum, l, b, vlsr, v, t, originalt, vmin, vmax, tmax, tmin, title

widget_control, ev.id, get_uvalue=uval
case uval of
	1 : zoomin
	2 : begin
		t = originalt
		v = vlsr
		plotspectrum
	    end
	3 : tzoomin
	4 :  begin
		tmin = min(t)-.07
		tmax = max(t)+.07
		plotspectrum
	     end
	5 : average
	6 : begin 
              cursor, x, y, /up
              io=dialog_message('v: '+strtrim(x,2)+', T: '+strtrim(y,2),/info)
	    end
	7 : fitspec
	8 : begin
                widget_control, ev.top, /destroy
                ps_spec
            end
	9 : begin
		widget_control, ev.top, /destroy & wdelete
            end
endcase
clear
end 

pro select

base = widget_base(/column)
button = widget_button(base, value='V: Zoom In ', uvalue=1)
button = widget_button(base, value='V: Zoom Out', uvalue=2)
button = widget_button(base, value='T: Zoom In ', uvalue=3)
button = widget_button(base, value='T: Zoom Out', uvalue=4)
button = widget_button(base, value='Smooth', uvalue=5)
button = widget_button(base, value='Get (v,T)', uvalue=6)
button = widget_button(base, value='Fit', uvalue=7)
button = widget_button(base, value='Print', uvalue=8)
button = widget_button(base, value='QUIT', uvalue=9)
widget_control, base, /realize
xmanager, 'select', base

end 
;===========================================================================

;=======================================================================;
; Function roundtohalf		Tim Robishaw: 6/16/98	 		;
;-----------------------------------------------------------------------;
; INPUTS:	angle	:	[degrees]				;
;-----------------------------------------------------------------------;
; DESCRIPTION: The input angle is rounded to the nearest half-degree.	;
;=======================================================================;

function roundtohalf, angle

if (angle lt 0) then negative = 1 else negative = 0
angle = abs(angle)
case 1 of
	angle - fix(angle) ge .75 : angle = 1. + fix(angle)	
	angle - fix(angle) lt .25 : angle = 0. + fix(angle)
	else : angle = .5 + fix(angle)
endcase
if negative then angle = -angle
return, angle

end ; roundtohalf
;==========================================================================

pro lds, l0, b0, maxt, NSIGMA=nsigma, HANNING=hanning, CROSS=cross, DAP=dap
;+
; NAME:
;       LDS
;     
; PURPOSE:

;     
; EXPLANATION:

;     
; CALLING SEQUENCE:

;     
; INPUTS:

;     
; OPTIONAL INPUTS:

;     
; OUTPUTS:

;
; OPTIONAL OUTPUTS:

;
; KEYWORDS:

;
; COMMON BLOCKS:

;
; SIDE EFFECTS:

;
; RESTRICTIONS:

;
; PROCEDURES CALLED:
;       PLOTSPECTRUM
;       ZOOMIN
;       AVERAGE
;       TZOOMIN
;       FITSPEC
;       PS_SPEC_EVENT
;       PS_SPEC
;       SELECT_EVENT
;       SELECT
;
;       ROUNDTOHALF
;       VTOBIN
;
;       GETMEAN
;       CUTOFF
;       MODEL
;       INDIPLOT
;       CLEAR
;       FITLDS
;       EDGECORRECTION
;       GFIT
;       GCURV
;
; EXAMPLE:

;
; NOTES:

;
; RELATED PROCEDURES:

;
; MODIFICATION HISTORY:
;       Written Tim Robishaw, Berkeley
;-


; TIM ROBISHAW 3/21/99
; GET AN LDS SPECTRUM.  DISPLAY AND MANIPULATE IT!

on_error, 1 ; RETURN TO MAIN LEVEL IF AN ERROR OCCURS

; USE ROBISHAW'S SETCOLORS TO DEFINE COLOR SYSTEM VARIABLES...
setcolors, /SYSTEM_VARIABLES, /SILENT

common spectrum, l, b, vlsr, v, t, originalt, vmin, vmax, tmax, tmin, title
common fitdat, nsig, mean, nrg1, cen1, wid1, hgt1, nrg2, cen2, wid2, hgt2
common PostScript, PSPath, Printers

;================ WHERE ARE THE LDS SPECTRA KEPT? ===================
LDSDataPath = getenv('LDS_PATH')
if (LDSDataPath eq '') then begin
    print, '  Set the environment variable LDS_PATH to the '
    print, '  directory where the Leiden/Dwingeloo Survey  '
    print, '  is stored. (May want to set this in .idlenv) '
    return
endif
;====================================================================


; MAKE A LIST OF AVAILABLE PRINTERS...
spawn, 'lpstat -v', Printers
Nprinters = N_elements(Printers)
for i = 0, Nprinters-1 do begin
    start = strpos(Printers[i], 'for ')+4
    stop  = strpos(Printers[i], ':')
    Printers[i] = strmid(Printers[i], start, stop-start)
endfor
Printers = Printers[sort(Printers)]
if (Printers[Nprinters-1] eq 'poster') $
  then Printers = Printers[0:Nprinters-2]

;===================== WHERE ARE LDS DATA KEPT? ===========================
LDSDataPath = getenv('LDS_PATH')
if (LDSDataPath eq '') then begin
    print, '  Set the environment variable LDS_PATH to the '
    print, '  directory where the Leiden/Dwingeloo Survey  '
    print, '  is stored. (May want to set this in .idlenv) '
    return
endif
;==========================================================================

;=========== STICK POSTSCRIPT FILES IN CURRENT DIRECTORY!  ================
cd, current=PSPath & PSPath=PSPath+'/'
;==========================================================================

if (N_elements(l0) eq 0) or (N_elements(b0) eq 0) then begin
    print, 'You need to enter latitude AND longitude!'
    print, 'Calling sequence: '
    print, 'IDL> lds, l, b [, Tmax]'
    return
endif

if (l0 lt 0) or (l0 gt 360) then begin
    print, 'Longitude out of range! [0:360]'
    return
endif

if (b0 lt -90) or (b0 gt 90) then begin
    print, 'Latitude out of range! [-90:+90]'
    return
endif

l0 = [l0]
b0 = [b0]

nrg1 = 0
nrg2 = 0

if keyword_set(nsigma) then nsig = nsigma else nsig = 4.0

title=''

if keyword_set(cross) then begin
    l0 = [l0, l0, l0, l0+.5, l0-.5]
    b0 = [b0, b0+.5, b0-.5, b0, b0]
    title='5-point Cross Averaged '
endif

for i = 0, N_elements(l0)-1 do begin

    ;================= ROUND l & b TO NEAREST HALF-DEGREE ===============
    l = roundtohalf(l0[i])
    b = roundtohalf(b0[i])

    if keyword_set(DAP) then begin
        if (i eq 0) $
          then title=title+'LDS Spectrum at !12l!3 = '+$
          string(l, format='(1f5.1)')+', !12b!3 = '+string(b, format='(1f5.1)')

        ; FORMAT THE FILENAME.
        lfile = string(fix(l*10),FORMAT='(I4.4)')

        ; GET THE SPECTRUM.
        t0 = (readfits(LDSDataPath+'l'+lfile+'.fit', h, /silent))[*,(b+90)*2]

        if keyword_set(hanning) $
          then t0 = convol(t0, [.25,.5,.25], /edge_truncate) $
          else getmean, t0, /fix

        nv = 849

    endif else begin

        if (i eq 0) $
          then title=title+'LAB Spectrum at !12l!3 = '+$
          string(l, format='(1f5.1)')+', !12b!3 = '+string(b, format='(1f5.1)')

        labdatapath=getenv('LAB_PATH')

;stop
	; get the header... they've goofed up the order...
	labhdr = headfits(LABDataPath+'lab.fits')
	baxis = sxpar(labhdr,'CDELT2')*(lindgen(361)+1-sxpar(labhdr,'CRPIX2')) $
	        + sxpar(labhdr,'CRVAL2')
	laxis = sxpar(labhdr,'CDELT3')*(lindgen(721)+1-sxpar(labhdr,'CRPIX3')) $
	        + sxpar(labhdr,'CRVAL3')

	laxis = laxis + 360*(laxis lt 0)

	bindx = where(baxis eq b)
	lindx = where(laxis eq l)

;stop

    ; USING THE NEW LAB SURVEY...
        if keyword_set(HANNING) $
          then t0 = (readfits(LABDataPath+'lab_han.fits',h,/SILENT,NSLICE=lindx))[*,bindx] $
          else t0 = (readfits(LABDataPath+'lab.fits',h,/SILENT,NSLICE=lindx))[*,bindx]

        ;!!!!!!!!!
        ; THIS AIN'T GONNA WORK WHEN AVERAGING DATA ACROSS DISCONTINUITIES...

        ; ONLY DISPLAY GOOD VALUES...
        goodindx = where(t0 ne sxpar(h,'BLANK'),nv)
        t0 = t0[goodindx]

    endelse

    if (i eq 0) then t = t0 else t = t0+t

endfor

t = t/N_elements(l0)
originalt = t

l = median(l0)
b = median(b0)

    ; DEFINE THE VELOCITY RANGE OF THE SPECTRA...
    dv = sxpar(h,'CDELT1')
    vpix = sxpar(h,'CRPIX1')
    voff = sxpar(h,'CRVAL1')
    vlsr = 0.001*(dv*(findgen(nv)+1-vpix) + voff) ; km/s

spawn, 'clear'

window, 0, xpos = 0, ypos = 30, xsize = 1100, ysize = 540, title = 'LDS SPECTRUM'

if (N_params() eq 3) then tmax = maxt else tmax = max(t) 
tmin = min(t)

v = vlsr

vmin = min(vlsr)
vmax = max(vlsr)

; PLOT THE SPECTRUM...
plotspectrum

; USE WIDGET MENU TO SELECT ACTION...
select

end
;==========================================================================

