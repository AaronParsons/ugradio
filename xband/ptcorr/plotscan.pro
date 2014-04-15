pro plotscan, dat, yeast=yeast, ywest=ywest, uncorr=uncorr

if (n_elements( yeast) eq 0) then yeast=[0,0]
if (n_elements( ywest) eq 0) then ywest=[0,0]

yrange= [ [yeast], [ywest]]

!p.multi=[0,1,2]

dishid= [ 'EAST', 'WEST']

FOR NR=0,1 DO BEGIN

wset,nr

IF KEYWORD_SET( UNCORR) THEN BEGIN
plot, dat[nr].unalt[*,0]-dat[nr].srcalt[*,0], dat[nr].pow[*,0], psym=-4, $
	/xsty, xtit='UNALT - SRCALT, DISH ' + dishid[ nr], $
	/ysty, yrange=yrange[*,nr]
plot, dat[nr].unaz[*,1]-dat[nr].srcaz[*,1], dat[nr].pow[*,1], psym=-4, $
	/xsty, xtit='UNAZ - SRCAZ, DISH ' + dishid[ nr], $
	/ysty, yrange=yrange[*,nr]
ENDIF ELSE BEGIN
plot, dat[nr].coralt[*,0]-dat[nr].srcalt[*,0], dat[nr].pow[*,0], psym=-4, $
	/xsty, xtit='CORALT - SRCALT, DISH ' + dishid[ nr], $
	/ysty, yrange=yrange[*,nr]
plot, dat[nr].coraz[*,1]-dat[nr].srcaz[*,1], dat[nr].pow[*,1], psym=-4, $
	/xsty, xtit='CORAZ - SRCAZ, DISH ' + dishid[ nr], $
	/ysty, yrange=yrange[*,nr]
ENDELSE

ENDFOR

!p.multi=0
return
end

