pro displaymap, ps=ps

;READ THE DATAFILE...
file1='galmap.sav'
file2='galmap_axes.sav'
restore,file1
restore,file2
radlsr=26000.
;save,galmap,galmapvel,rlyarr,rpxarr,binmask,spec,file='galmap.sav'

;WE HAVE ALREADY DEFINED:
;ps = keyword_set(ps) ? 1 : 0
imgsz=size(galmap)

brtimg=galmap

whitemap=fltarr((size(galmap))[1],(size(galmap))[2])
w0=where(brtimg eq 0)
whitemap[w0]=255

colimg=galmapvel
colimg[w0]=0

brtimg= rebin(brtimg,563,563)
colimg= rebin(colimg,563,563)

;ra_axis=rlyarr[*,imgsz[2]/2]
;dec_axis=rlyarr[imgsz[1]/2,*]
ra_axis=horiz*(-1.)
dec_axis=vert+.33d4

ra_axis= rebin(ra_axis, 563)
dec_axis= rebin(dec_axis, 563)

;========== THE FOLLOWING SECTION MAKES NECESSARY DEFINNITIONS =======
;MAKE SURE WE ARE USING DECOMPOSED COLOR (3 INDEP COLOR TABLES)
device, /decomp
loadct,0

;TAKE CARE OF PS DETAILS...
if n_elements( ps) eq 0 then ps=0
;DEFINE PS OUTPUT FILENAME...
psfigname= '2dcolor_galmap.ps'

;DEFINE PLOTTING PARAMS--IMAGE CONTRAST, STRETCH...
gamma = 0.548    ;the contrast
brtmin = 0.08   ;see above
;brtmin=0
brtmax = max(galmap)    ;see above
colmin = min(galmapvel)   ;see above
colmax = max(galmapvel)   ;see above

;DEFINE LABEL FOR X-DIRECTION OF COLORBAR...
cbar_xtitle= 'Velocity [Km/s]'

;----SPECIFY THE WINDOW SIZE AND POSITIONS IN TERMS OF IMAGE SIZE
;--(SEE DOC FOR 'IMG_CBAR_POSNS' AND/OR IACIDL [ANNOTATED IMAGES HANDOUT])--
sz= size( brtimg)
countra= sz[1]  ;nr pixels in RA, EQUAL TO 541 IN THIS EXAMPLE
countdec= sz[2] ;nr pixels in DEC, EQUAL TO 470 IN THIS EXAMPLE
;DEFINE THE BORDERS, IMAGE, AND COLORBAR POSITIONS
w_left=0.16
w_rght=0.05
w_bot=0.16
w_top=0.14
space=0.03
width=0.1
img_cbar_posns, w_left, w_rght, w_bot, w_top, space, width, $
  imgposn, cbarposn, f_hor, f_ver

;PREDEFINE LINE WIDTHS, FONTS, ETC. USING SYSTEM VARIABLES...
!p.font=ps-1
!p.thick=20
!x.thick=16
!y.thick=16
!p.charsize=3
plotcolor= ps*!black+ (1-ps)*!white

;================ THE FOLLOWING SECTION DOES THE WORK ==================

;FIND THE IMAGE SIZE IN PIXELS...
sz= size( colimg)
countra= sz[1]  ;nr pixels in RA, EQUAL TO 541
countdec= sz[2] ;nr pixels in DEC, EQUAL TO 470

;USE THE POSITIONS TO OPEN AN X WINDOW OR A PS WINDOW DEPENDING ON VALUE OF PS...
;WINDOW. WE FOLLOW THE HANDOUT ``MAKING ANNOTATED IMAGES...''
;OPEN AN X WINDOW OR A PS WINDOW DEPENDING ON VALUE OF PS...
if ps then $
   psopen, psfigname, xsize=f_hor*countra/100., ysize=f_ver*countdec/100., $
           /inch, /color, /times, /bold, /isolatin1 $
else if wopen(2) eq 0 then window,2, xs= f_hor*countra, ys= f_ver*countdec

;STRETCH AND CONTRAST THE INTENSITY IMAGE...
brtimgxx= ( ((brtimg > brtmin) < brtmax)- brtmin)/(brtmax-brtmin)
brtimgx= brtimgxx^ gamma

;CREATE THE INTENSITY-MODULATED COLOR IMAGE WITH THE FOLLOWING SIX STEPS:
; 0. LOAD THE PSEUDO COLOR TABLE...
pseudo_ch, colr ;COLR is 256 X 3: 256 intensities in the 3 colors (r,g,b)
; 1. BYTSCL THE COLOR IMAGE...
colimgb= bytscl( colimg, min=colmin, max=colmax)
; 2. DEFINE THE (R,G,B) COMPONENTSOF THE VELOCITY (COLOR) IMAGE. NOTE HOW WE USE INDICES!
redimg= colr[ colimgb, 0]
grnimg= colr[ colimgb, 1]
bluimg= colr[ colimgb, 2]
; 3. USING INDICES AS ABOVE CREATES VECTORS of length 541 X 470 = 254270,
; 4. WHICH MUST BE CONVERTED TO IMAGES...
redimg= reform( redimg, countra, countdec)
grnimg= reform( grnimg, countra, countdec)
bluimg= reform( bluimg, countra, countdec)
; 5. MODULATE THE VELOCITY (COLOR) IMAGE BY THE INTENSITY IMAGE...
r_img= byte( round( brtimgx* redimg) )
g_img= byte( round( brtimgx* grnimg) )
b_img= byte( round( brtimgx* bluimg) )

;LOAD GREYSCALE COLOR TABLE...
loadct,0

;WRITE THE COLORBAR...
colorbar, pos=cbarposn, crange=[colmin, colmax], rgb=colr, color=plotcolor, $
  xtit=cbar_xtitle, $
  irange=[brtmin, brtmax], igamma=gamma, ytit=textoidl('T [kelvin]'), $
          yticks=2, yminor=1, charsize=2
sharpcorners

;WRITE THE IMAGE BEFORE CALLING SETCOLORS...
tv, [ [[r_img]], [[g_img]], [[b_img]] ] , true=3, $
imgposn[0], imgposn[1], /norm, xsize=1./f_hor, ysize=1./f_ver

;Make the black parts white
;tvscl,whitemap, channel=1, $
;tv,[ [[whitemap]], [[whitemap]], [[whitemap]] ], true=3, $
;imgposn[0], imgposn[1], /norm, xsize=1./f_hor, ysize=1./f_ver

;CALL SETCOLORS FOR THE VECTORIZED PORTION OF PS; THEN ANNOTATE...
loadct,0
setcolors, /sys
plot, ra_axis, dec_axis, position=imgposn, /nodata, /noerase, $
        /xsty, xtit='Distance From Black Hole [ly]', xra= reverse( minmax(ra_axis)), $
        /ysty, ytit='Distance From Black Hole [ly]' , color=plotcolor, $
        sub='Neutral Hydrogen Map of the Milky Way Galaxy'
oplot, [-1d6,1d6],[0,0],color=255
oplot,[0,0],[-1d6,1d6],color=255
blanktick=strarr(20)+' '
plot, ra_axis, dec_axis, position=imgposn, /nodata, /noerase, /xsty, /ysty, color=255, $
  xtickname=blanktick, ytickname=blanktick
sharpcorners
tvcircle,radlsr,0,0,255,/data
!p.thick=10
tvcircle,2.5d3,0,radlsr-.2d4,255,/data

;RETURN TO X WINDOWS...
loadct,0
if ps then begin & psclose & setcolors, /sys & endif

;RETURN EVERYTHING BACK TO NORMAL...
!p.font=-1
!p.thick=0
!x.thick=0
!y.thick=0


end
