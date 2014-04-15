;edited by ES on 5/2001

pro repeat_scanner, $
                    params, $
                    increment

;print,'top of repeat_Scanner';DEBUG

lon = 122.d + 14.d/60.d + 44.d/3600.d	

ra = make_array(2, /float)
dec = make_array(2, /float)
ha = make_array(2, /float)
aa = make_array(2, 2, /float)


;  Definitions
minalt = 10.0
maxalt = 98.0
fwdazmin = 50.0
fwdazmax = 310.0
revazdead = 50.0

field = make_array(4, /string)

ka = make_array(2, 2, /int, value = 0)

increment = 0

;get_juldate, jd
jd=jdnow(/reduced)
sunposred, jd, ratemp, dectemp
ra[0] = ratemp / 15.
dec[0] = dectemp

moonposred, jd, ratemp, dectemp, dis
geo2topo, ratemp / 15., dectemp, dis, topo_ra, topo_dec
ra[1] = topo_ra
dec[1] = topo_dec

;get_juldate, jd
;ct2lst, lst, lon, dummy, jd
lst=lstnow()

for count = 0, 1 do begin
    ha[count] = (lst - ra[count])
    
    aa[*, count] = hd2aa(15.0 * ha[count], dec[count])
    
                                ;  Decide what's visible, which mode (forward or reverse or both)
                                ;  to view it in.
                                ;  See if alt is in range.
    if ((aa[0, count] GT minalt) AND $
        (aa[0, count] LT maxalt)) then begin
                                ;  See if az is in range, forward.
        if ((aa[1, count] GT fwdazmin) AND $
            (aa[1, count] LT fwdazmax)) then begin
            ka[0, count] = 1
                                ;  See if az is in range, reverse.
            if ((aa[1, count] LT 180.0 - revazdead) OR $
                (aa[1, count] GT 180.0 + revazdead)) then $
              ka[1, count] = 1
        endif
    endif
endfor

;  Adjust for user selections...
;  Pointing mode (forward)
if (params.a_mode EQ 0) then $
  ka[1, *] = 0

;  Pointing mode (reverse)
if (params.a_mode EQ 1) then $
  ka[0, *] = 0

;THIS HAS BEEN CHANGED.  NOW AUTO DOES ONLY ONE IF ONLY ONE IS POSSIBLE
;  Pointing mode (auto)  Only goes when both
;  forward and reverse modes are possible.
;if (params.a_mode EQ 2) then begin
;    if NOT(ka[0, 0] AND ka[1, 0]) then ka[*, 0] = 0
;    if NOT(ka[0, 1] AND ka[1, 1]) then ka[*, 1] = 0
;endif


;  Object (sun)
if (params.a_source EQ 0) then $
  ka[*, 1] = 0

;  Object (moon)
if (params.a_source EQ 1) then $
  ka[*, 0] = 0

;  Get local file number
widget_control, params.auto_fnum, get_value=local_fnum

;  Determine auto/manual parameters
if params.auto_id NE 0L then begin
  fpath = params.a_fpath 
  correct = params.a_correct
endif else begin
  fpath = params.m_fpath
  correct = params.m_correct
endelse

;  Do the drift curves
;  Sun, forward
if (ka[0, 0] EQ 1) then begin
;print,'SUN FORWARD MODE';DEBUG
                                ;  Put together the file name
    result = where(params.fields[0:2, 1] EQ 0, count)
    if count NE 0 then field[result] = 'sun'
    result = where(params.fields[0:2, 1] EQ 1, count)
    if count NE 0 then field[result] = 'for'
    result = where(params.fields[0:2, 1] EQ 2, count)
    if count NE 0 then field[result] = strtrim(local_fnum, 2)
    if params.fields[3, 1] EQ 0 then $
      field[3] = '.sav' $
    else $
      field[3] = '.dat'
    fname = fpath + field[0] + field[1] + field[2] + field[3] 

;print,'hey - I am in sun forward mode';;DEBUG

    if NOT(params.test) then $
;print, 'hey - I am attempting to scan' ;;DEBUG
      scan, 	fname, $
      size 	= params.size, $
      space 	= params.space, $
      reverse	= 0, $
      nocorrect = correct, $
      moon	= 0, $
      win_num	= params.win_num
endif

;  Sun, reverse
if (ka[1, 0] EQ 1) then begin
                                ;  Put together the file name
    result = where(params.fields[0:2, 1] EQ 0, count)
    if count NE 0 then field[result] = 'sun'
    result = where(params.fields[0:2, 1] EQ 1, count)
    if count NE 0 then field[result] = 'rev'
    result = where(params.fields[0:2, 1] EQ 2, count)
    if count NE 0 then field[result] = strtrim(local_fnum, 2)
    if params.fields[3, 1] EQ 0 then $
      field[3] = '.sav' $
    else $
      field[3] = '.dat'
    fname = fpath + field[0] + field[1] + field[2] + field[3] 
    
    if NOT(params.test) then $
      scan, 	fname, $
      size 	= params.size, $
      space 	= params.space, $
      reverse	= 1, $
      nocorrect = correct, $
      moon	= 0, $
      win_num	= params.win_num
endif

;  Moon, forward
if (ka[0, 1] EQ 1) then begin
                                ;  Put together the file name
    result = where(params.fields[0:2, 1] EQ 0, count)
    if count NE 0 then field[result] = 'moon'
    result = where(params.fields[0:2, 1] EQ 1, count)
    if count NE 0 then field[result] = 'for'
    result = where(params.fields[0:2, 1] EQ 2, count)
    if count NE 0 then field[result] = strtrim(local_fnum, 2)
    if params.fields[3, 1] EQ 0 then $
      field[3] = '.sav' $
    else $
      field[3] = '.dat'
    fname = fpath + field[0] + field[1] + field[2] + field[3] 
    
    if NOT(params.test) then $
      scan, 	fname, $
      size 	= params.size, $
      space 	= params.space, $
      reverse	= 0, $
      nocorrect = correct, $
      moon	= 1, $
      win_num	= params.win_num
endif

;  Moon, reverse
if (ka[1, 1] EQ 1) then begin
                                ;  Put together the file name
    result = where(params.fields[0:2, 1] EQ 0, count)
    if count NE 0 then field[result] = 'moon'
    result = where(params.fields[0:2, 1] EQ 1, count)
    if count NE 0 then field[result] = 'rev'
    result = where(params.fields[0:2, 1] EQ 2, count)
    if count NE 0 then field[result] = strtrim(local_fnum, 2)
    if params.fields[3, 1] EQ 0 then $
      field[3] = '.sav' $
    else $
      field[3] = '.dat'
    fname = fpath + field[0] + field[1] + field[2] + field[3] 
    
    if NOT(params.test) then $
      scan, 	fname, $
      size 	= params.size, $
      space 	= params.space, $
      reverse	= 1, $
      nocorrect = correct, $
      moon	= 1, $
      win_num	= params.win_num
endif

if total(ka) GT 0 then $
  increment = 1

if params.test then $
  increment = 1

end


