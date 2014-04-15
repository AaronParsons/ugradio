pro centroid_find, fpath, fname, head, dat, fit, coords_flag

;  Define midpoint of the array
mid = head.size / 2

;  Unload power data from dat structure into something more usuable
pow = make_array(4, head.size)
pow[0,*] = dat[0].pow[*,0] - fit[0]	;  Altitude, East with baseline removed
pow[1,*] = dat[1].pow[*,0] - fit[1]	;  Altitude, West with baseline removed
pow[2,*] = dat[0].pow[*,1] - fit[2]	;  Azimuth, East with baseline removed
pow[3,*] = dat[1].pow[*,1] - fit[3]	;  Azimuth, West with baseline removed

;  Get coordinates
coord = make_array(4, head.size)
if coords_flag then begin
	coord[0,*] = dat[0].unalt[*,0]	;  Altitude, East
	coord[1,*] = dat[1].unalt[*,0]	;  Altitude, West
	coord[2,*] = dat[0].unaz[*,1]	;  Azimuth, East
	coord[3,*] = dat[1].unaz[*,1]	;  Azimuth, West
endif else begin
	coord[0,*] = dat[0].coralt[*,0]	;  Altitude, East
	coord[1,*] = dat[1].coralt[*,0]	;  Altitude, West
	coord[2,*] = dat[0].coraz[*,1]	;  Azimuth, East
	coord[3,*] = dat[1].coraz[*,1]	;  Azimuth, West
endelse

;  Other definitions
look = -1
wd0 = 2.0

for count = 0, 3 do begin
	gfit, look, coord[count, *], pow[count, *], $	;  x and y data arrays
		pow[count, 0], pow[count, mid] - pow[count, 0], coord[count, mid], wd0, $
		tempfit, temprms, tempzro, temphgt, tempcen, tempwid
endfor

gauss_fit = {	linfit:		fit, $
		gaussfit:	tempfit, $
		rms:		temprms, $
		cen:		tempcen, $
		zro:		tempzro, $
		hgt:		temphgt, $
		wid:		tempwid, $

end
