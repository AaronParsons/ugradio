pro remove_n_fit, params, name_num, fit, head, dat

;  Restore that data file!
restore, params.fnames[name_num]

;  Define resultant data structure
fit = replicate	({linfit:  make_array(head.size, /float), $
                  gaussfit:make_array(head.size, /float), $
                  rms:     99999999.9, $
                  zro:     0.0, $
                  hgt:     0.0, $
                  cen:     0.0, $
                  wid:     0.0, $
                  left:    0, $
                  right:   0, $
                  exps:    make_array(params.order + 1, /float), $
                  cen_err: 0.0}, 4)

;  Define midpoint of the array and other stuff
look = -1
wd0 = 2.0
lin_fit = make_array(4, head.size, value=0.0D)
pow = make_array(4, head.size, /float)
coord = make_array(4, head.size, /float)
exps = make_array(4, params.order + 1, /float)
    
;  Unload power data and coordinate data from dat
;  structure into something more usuable
pow[0,*] = dat[0].pow[*,0]	;  Altitude, East
pow[1,*] = dat[1].pow[*,0]	;  Altitude, West
pow[2,*] = dat[0].pow[*,1]	;  Azimuth, East
pow[3,*] = dat[1].pow[*,1]	;  Azimuth, West

if params.coords_flag then begin
    coord[0,*] = dat[0].unalt[*,0] ;  Altitude, East
    coord[1,*] = dat[1].unalt[*,0] ;  Altitude, West
    coord[2,*] = dat[0].unaz[*,1] ;  Azimuth, East
    coord[3,*] = dat[1].unaz[*,1] ;  Azimuth, West
endif else begin
    coord[0,*] = dat[0].coralt[*,0] ;  Altitude, East
    coord[1,*] = dat[1].coralt[*,0] ;  Altitude, West
    coord[2,*] = dat[0].coraz[*,1] ;  Azimuth, East
    coord[3,*] = dat[1].coraz[*,1] ;  Azimuth, West
endelse

;  Set values of left and right maxes and mins for no baseline
;  fitting.  Because the params structure isn't updated for theparams.l_max + params.r_max
;  base widget in the procedure, I don't worry about changing
;  these.  Also create other needed arrays for baseline removal
if NOT(params.remove_flag) then begin
    params.l_min = 0
    params.l_max = 0
    params.r_min = 0
    params.r_max = 0
endif

for left = params.l_min, params.l_max do begin
    for right = params.r_min, params.r_max do begin
        if params.remove_flag then begin
            x = make_array(left + right, /float)
            y = make_array(left + right, /float)
        endif

        for count = 0, 3 do begin
            if params.remove_flag then begin ;  Make baseline fit function or set to zero.
                for numcount = 0, left - 1 do begin
                    x[numcount] = coord[count, numcount]
                    y[numcount] = pow[count, numcount]
                endfor
                
                for numcount = left + right - 1, left, -1 do begin
                    x[numcount] = coord[count, head.size - left - right + numcount]
                    y[numcount] = pow[count, head.size - left - right + numcount]
                endfor
                
                                ;  Adjust the order of the fit to take
                                ;  into account the number of points
                                ;  available to fit.
                if (left + right) GE params.order + 1 then $
                  order = params.order $
                else $
                  order = left + right - 1
                
                exps[count, 0:order] = svdfit(x, y, order + 1)
                
                                ;  Compose the fit function without
                                ;  the offset term.
                lin_fit[*,*] = 0.0D
                for numcount = 0, order do begin
                  lin_fit[count,*] = lin_fit[count, *] + exps[count, numcount] * coord[count, *] ^ numcount
              endfor
                
            endif else  lin_fit[*,*] = 0.0  ;  or set to zero

                                ;  Determine where the max/min value
                                ;  is.  This assumes that the most
                                ;  negative or positive value in the
                                ;  data corresponds to the center of
                                ;  the scan.
            if params.pow_dir then $
              trash = max(-1.0 * (pow[count,*] - lin_fit[count, *]), pos) $
            else $
              trash = max(pow[count,*] - lin_fit[count, *], pos)
                                ;  Fit each direction (east alt, west
                                ;  alt, east az, west az) with a Gaussian.  
            gfit, look, coord[count, *], pow[count, *] - lin_fit[count, *], $ ;  x and y data arrays
              pow[count, 0], pow[count, pos] - pow[count, 0], coord[count, pos], wd0, $
              tempfit, temprms, tempzro, temphgt, tempcen, tempwid
                                ;  Compare fit RMS with previous RMS
                                ;  and select fit with the smallest
                                ;  RMS and with a height of the same
                                ;  sign as indicated by params.pow_dir
            do_it = 0
            if params.pow_dir then begin ;  Power increases negatively
                if temphgt[0] LT 0.0 then do_it = 1
            endif else begin    ;  Power increases positively
                if temphgt[0] GT 0.0 then do_it = 1
            endelse

            if temprms LT fit[count].rms AND do_it then begin
                fit[count].linfit[*] = lin_fit[count, *]
                fit[count].gaussfit[*] = tempfit[*]
                fit[count].rms = temprms[0]
                fit[count].zro = tempzro[0]
                fit[count].hgt = temphgt[0]
                fit[count].cen = tempcen[0]
                fit[count].wid = tempwid[0]
                fit[count].left = left
                fit[count].right = right
                fit[count].exps[*] = exps[count,*]
                fit[count].cen_err = fit[count].cen - coord[count, head.size/2]
            endif
        endfor        
    endfor
endfor
    
;  If plot window is open, plot it all
if params.data_id NE 0L then begin

    loadct, 39
    !p.multi = [0,1,2]

                                ;  Plot Raw Data, East
    wset, params.data_win[0]
    plot, coord[0,*], pow[0,*], xmargin=[5,2], ymargin=[3,1], yticks=2, xticks=4, $
      xtitle='Altitude [degrees]', /nodata, xr=[min(coord[0,*]), max(coord[0,*])], $
      yr=[min(pow[0,*]), max(pow[0,*])]
    oplot, coord[0,*], pow[0,*], color=100
    oplot, coord[0,*], fit[0].linfit, color=160
    plot, coord[2,*], pow[2,*], xmargin=[5,2], ymargin=[3,1], yticks=2, xticks=4, $
      xtitle='Azimuth [degrees]', /nodata, xr=[min(coord[2,*]), max(coord[2,*])], $
      yr=[min(pow[2,*]), max(pow[2,*])]
    oplot, coord[2,*], pow[2,*], color=100
    oplot, coord[2,*], fit[2].linfit, color=160

                                ;  Plot Raw Data, West
    wset, params.data_win[1]
    plot, coord[1,*], pow[1,*], xmargin=[5,2], ymargin=[3,1], yticks=2, xticks=4, $
      xtitle='Altitude [degrees]', /nodata, xr=[min(coord[1,*]), max(coord[1,*])], $
      yr=[min(pow[1,*]), max(pow[1,*])]
    oplot, coord[1,*], pow[1,*], color=100
    oplot, coord[1,*], fit[1].linfit, color=160
    plot, coord[3,*], pow[3,*], xmargin=[5,2], ymargin=[3,1], yticks=2, xticks=4, $
      xtitle='Azimuth [degrees]', /nodata, xr=[min(coord[3,*]), max(coord[3,*])], $
      yr=[min(pow[3,*]), max(pow[3,*])]
    oplot, coord[3,*], pow[3,*], color=100
    oplot, coord[3,*], fit[3].linfit, color=160

                                ;  Plot Fitted data and Gaussian, east
    wset, params.data_win[2]
    plot, coord[0,*], pow[0,*] - fit[0].linfit, xmargin=[5,2], ymargin=[3,1], yticks=2, $
      xticks=4, xtitle='Altitude [degrees]', /nodata, xr=[min(coord[0,*]), max(coord[0,*])], $
      yr=[min(pow[0,*] - fit[0].linfit), max(pow[0,*] - fit[0].linfit)]
    oplot, coord[0,*], pow[0,*] - fit[0].linfit, color=65
    oplot, coord[0,*], fit[0].gaussfit, color=135
    vline = [[coord[0, head.size/2], min(fit[0].gaussfit)], [coord[0, head.size/2], $
                                                            max(fit[0].gaussfit)]]
    oplot, vline[0,*], vline[1,*], ps=-3, color=255

    plot, coord[2,*], pow[2,*] - fit[2].linfit, xmargin=[5,2], ymargin=[3,1], yticks=2, $
      xticks=4, xtitle='Azimuth [degrees]', /nodata, xr=[min(coord[2,*]), max(coord[2,*])], $
      yr=[min(pow[2,*] - fit[2].linfit), max(pow[2,*] - fit[2].linfit)]
    oplot, coord[2,*], pow[2,*] - fit[2].linfit, color=65
    oplot, coord[2,*], fit[2].gaussfit, color=135
    vline = [[coord[2, head.size/2], min(fit[2].gaussfit)], [coord[2, head.size/2], $
                                                            max(fit[2].gaussfit)]]
    oplot, vline[0,*], vline[1,*], ps=-3, color=255
    
                                ;  Plot Fitted data and Gaussian, west
    wset, params.data_win[3]
    plot, coord[1,*], pow[1,*] - fit[1].linfit, xmargin=[5,2], ymargin=[3,1], yticks=2, $
      xticks=4, xtitle='Altitude [degrees]', /nodata, xr=[min(coord[1,*]), max(coord[1,*])], $
      yr=[min(pow[1,*] - fit[1].linfit), max(pow[1,*] - fit[1].linfit)]
    oplot, coord[1,*], pow[1,*] - fit[1].linfit, color=65
    oplot, coord[1,*], fit[1].gaussfit, color=135
    vline = [[coord[1, head.size/2], min(fit[1].gaussfit)], [coord[1, head.size/2], $
                                                            max(fit[1].gaussfit)]]
    oplot, vline[0,*], vline[1,*], ps=-3, color=255
    plot, coord[3,*], pow[3,*] - fit[3].linfit, xmargin=[5,2], ymargin=[3,1], yticks=2, $
      xticks=4, xtitle='Azimuth [degrees]', /nodata, xr=[min(coord[3,*]), max(coord[3,*])], $
      yr=[min(pow[3,*] - fit[3].linfit), max(pow[3,*] - fit[3].linfit)]
    oplot, coord[3,*], pow[3,*] - fit[3].linfit, color=65
    oplot, coord[3,*], fit[3].gaussfit, color=135
    vline = [[coord[3, head.size/2], min(fit[3].gaussfit)], [coord[3, head.size/2], $
                                                            max(fit[3].gaussfit)]]
    oplot, vline[0,*], vline[1,*], ps=-3, color=255

endif

;  Save the fit data and parameters

pos = strpos(params.fnames[name_num], '.sav')
newfname = strmid(params.fnames[name_num], 0, pos) + 'fit.sav'
save, fit, filename=newfname

end











