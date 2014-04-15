pro scan_progress, win, size, space

!p.multi=[0,0,0]

;  Scan progress window stuff.  Nothing exciting here!
blahalt = make_array(2 * size, /float, value=0.0)
blahaz = make_array(2 * size, /float, value=0.0)

for index = 0, 1 do begin
	for count = 0, (size - 1) do begin
        	;  Calculate offset then make calculations to get alt-az.
        	offset = (count - size / 2) * space

	        ;  Calculate coordinates to send to point2
		if (index) then begin
	        	blahalt[count + size * index] = 0.
			blahaz[count + size * index] = offset
		endif else begin
		        blahalt[count + size * index] = offset
			blahaz[count + size * index] = 0.
		endelse
	endfor
endfor

;  Make 0.5 degree circle
r = 1.0
theta = indgen(37) * 10
ciry = r * sin(theta * !dtor)
cirx = r * cos(theta * !dtor)
;print, 'scan_prog', win
wset, win
plot, blahaz, blahalt, psym=6, /ynozero, xtitle='Az Offset (deg)', ytitle='Alt Offset (deg)', $
  /nodata
oplot, cirx, ciry, color=160
oplot, blahaz, blahalt, psym=6, color=50

end

