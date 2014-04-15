pro corr_consts, $
  name_num, $
  params

sunflag = 0
moonflag = 0

fitname = make_array(n_elements(name_num), /string)

;  Determine if sun or moon files are there
for count = 0, n_elements(name_num) - 1 do begin
                                ;  Make fit filenames
    pos = strpos(params.fnames[name_num[count]], '.sav')
    fitname[count] = strmid(params.fnames[name_num[count]], 0, pos) + 'fit.sav'
    case 1 of
        (name_num[count] EQ 1): begin
            restore, fitname[count - 1]
            sunforfit = fit
            fit = 0
            restore, fitname[count]
            sunrevfit = fit
            fit = 0
            sunflag = 1
        end
        (name_num[count] EQ 3): begin
            restore, fitname[count - 1]
            moonforfit = fit
            fit = 0
            restore, fitname[count]
            moonrevfit = fit
            fit = 0
            moonflag = 1
        end
        else:
    endcase
endfor

if sunflag then begin
    s_alt = sunforfit[0].cen - sunforfit[0].cen_err
    s_az = sunforfit[2].cen - sunforfit[2].cen_err

    ealt_dial = (sunforfit[0].cen_err + sunrevfit[0].cen_err) / 2.0
    eaz_dial = (sunforfit[2].cen_err + sunrevfit[2].cen_err) / 2.0
    eflop = (sunforfit[0].cen_err - sunrevfit[0].cen_err) / 2.0 / cos(s_alt * !dtor)
    eskew = (sunforfit[2].cen_err - sunrevfit[2].cen_err) / 2.0 * cos(s_alt * !dtor)

    walt_dial = (sunforfit[1].cen_err + sunrevfit[1].cen_err) / 2.0
    waz_dial = (sunforfit[3].cen_err + sunrevfit[3].cen_err) / 2.0
    wflop = (sunforfit[1].cen_err - sunrevfit[1].cen_err) / 2.0 / cos(s_alt * !dtor)
    wskew = (sunforfit[3].cen_err - sunrevfit[3].cen_err) / 2.0 * cos(s_alt * !dtor)

    trash = findfile(params.corr_log, count=count)
    if count then begin
        openw, lun, params.corr_log, /get_lun, /append
    endif else begin
        openw, lun, params.corr_log, /get_lun
        printf, lun, format='(2a6, 18a8)', ' moon?', ' num', ' s_alt', ' s_az', ' foral_e', ' foral_w', ' foraz_e', ' foraz_w', ' reval_e', ' reval_w', ' revaz_e', ' revaz_w', ' ealdial', ' eazdial', ' eflop', ' eskew', ' waldial', ' wazdial', ' wflop', ' wskew'
    endelse
    printf, lun, format='(2a6, 18f8.3)', '0', strtrim((*params.ref)[0], 2), s_alt, s_az, sunforfit[0].cen_err, sunforfit[1].cen_err, sunforfit[2].cen_err, sunforfit[3].cen_err, sunrevfit[0].cen_err, sunrevfit[1].cen_err, sunrevfit[2].cen_err, sunrevfit[3].cen_err, ealt_dial, eaz_dial, eflop, eskew, walt_dial, waz_dial, wflop, wskew
    close, lun, /all
endif

if moonflag then begin
    s_alt = moonforfit[0].cen - moonforfit[0].cen_err
    s_az = moonforfit[2].cen - moonforfit[2].cen_err

    ealt_dial = (moonforfit[0].cen_err + moonrevfit[0].cen_err) / 2.0
    eaz_dial = (moonforfit[2].cen_err + moonrevfit[2].cen_err) / 2.0
    eflop = (moonforfit[0].cen_err - moonrevfit[0].cen_err) / 2.0 / cos(s_alt * !dtor)
    eskew = (moonforfit[2].cen_err - moonrevfit[2].cen_err) / 2.0 * cos(s_alt * !dtor)

    walt_dial = (moonforfit[1].cen_err + moonrevfit[1].cen_err) / 2.0
    waz_dial = (moonforfit[3].cen_err + moonrevfit[3].cen_err) / 2.0
    wflop = (moonforfit[1].cen_err - moonrevfit[1].cen_err) / 2.0 / cos(s_alt * !dtor)
    wskew = (moonforfit[3].cen_err - moonrevfit[3].cen_err) / 2.0 * cos(s_alt * !dtor)

    trash = findfile(params.corr_log, count=count)
    if count then begin
        openw, lun, params.corr_log, /get_lun, /append 
    endif else begin
        openw, lun, params.corr_log, /get_lun
        printf, lun, format='(2a6, 18a8)', ' moon?', ' num', ' s_alt', ' s_az', ' foral_e', ' foral_w', ' foraz_e', ' foraz_w', ' reval_e', ' reval_w', ' revaz_e', ' revaz_w', ' ealdial', ' eazdial', ' eflop', ' eskew', ' waldial', ' wazdial', ' wflop', ' wskew'
    endelse
    printf, lun, format='(2a6, 18f8.3)', '1', strtrim((*params.ref)[0], 2), s_alt, s_az, sunforfit[0].cen_err, sunforfit[1].cen_err, sunforfit[2].cen_err, sunforfit[3].cen_err, sunrevfit[0].cen_err, sunrevfit[1].cen_err, sunrevfit[2].cen_err, sunrevfit[3].cen_err, ealt_dial, eaz_dial, eflop, eskew, walt_dial, waz_dial, wflop, wskew
    close, lun, /all
endif


end
