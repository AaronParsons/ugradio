pro explot

x = findgen(10)
y = 2.*x
z = fltarr(10)
for i=0,9 do z[i]=randomu(seed)

y = y+2.*z-1.

startplot, 'ex4.ps'
plot, x, y, ps=7, /xs, /ys, xr=[0,10], yr=[0,20], $
  xtitle='x-axis label (units)', ytitle='y-axis label (units)', $
  title='Title for entire plot'

;oplot theory
yth = 2*x
oplot, x, yth, lines=2

;oplot errors
yerr = fltarr(10) + 1.
oploterr, x, y, yerr

;use xyouts for guide
oplot,  [6.8], [6.1], ps=7
xyouts, 7.0, 6.0, 'data points'

oplot, [6.5,6.9],[5.5,5.5], lines=2
xyouts, 7.0, 5.4, 'theory

oplot, [6.8,6.8],[4.6,5.1]
xyouts, 7.0, 4.8, 'error bars'

endplot

end
