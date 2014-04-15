pro carlkill, pos, pwr, indxyes

;+
;CARLKILL: eliminate bad points interactively 
;
;PURPOSE: you have a set of data containing some bad points. use this
;to interactively select the bad points. returns the array of good points.
;
;INPUTS: POS, PWR: input positions and powers at those positions. or, 
;	think of them as x and y.
;
;OUTPUTS: the array of good data points.
;
;EXAMPLE:
;
;	CARLKILL, pos, pwr, indxyes
;
;-

common plotcolors

indx= indgen( n_elements(pos))

indxyes= indx
plot, pos, pwr, psym=-4
pwrscale= max( pwr[ indxyes])-min(pwr[ indxyes])
posscale= max( pos[ indxyes])-min(pos[ indxyes])

WHILE 1 DO BEGIN

;oplot, pos[indxyes], pwr[indxyes], psym=-4, color=red

print, 'to kill a point, move the cursor to it and left click'
print, 'otherwise, right cliek within the plot window'

cursor, posval, pwrval
if (!mouse.button ne 1) then break

;pwrscale= max( pwr[ indx[ indxyes]])-min(pwr[ indx[ indxyes]])
;posscale= max( pos[ indx[ indxyes]])-min(pos[ indx[ indxyes]])
minsum = min( (abs((posval-pos)/posscale) + $
	abs((pwrval-pwr)/pwrscale))[ indx[ indxyes]]  , indxmin)

minsum = min( (abs((posval-pos)/posscale) + $
	abs((pwrval-pwr)/pwrscale))  , indxmin)
print, 'tossed ', indxmin
plots, pos[ indxmin], pwr[ indxmin], $
	color=red , psym=2

;print, indx[ indxyes]
;print, indxyes
tst = where( indxyes ne indxmin)
indxyes= indxyes[ tst]
print, indxyes

;oplot, pos[ indx[ indxyes]], pwr[ indx[ indxyes]], psym=-4, color=red

ENDWHILE

return

end
