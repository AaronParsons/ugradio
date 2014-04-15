FUNCTION check_lims, alt, az

;  Declare common block
common point2_common

;  Initializations
altlim_min = 7.0
altlim_max = 170.0
azlim_min = 40.0
azlim_max = 320.0
zenith_deadband = 2.0
flag = FALSE

;  Check altitude
if (alt GT -1.0) then begin
    if (alt LE altlim_min) OR (alt GE altlim_max) then begin
        print, 'Altitude out of range:  ', strtrim(alt, 2)
        flag = TRUE
    endif

    if abs(alt - 90.0) lt zenith_deadband then begin
;	if (alt GE (90.0 - zenith_deadband)) AND (alt LE (90.0 + zenith_deadband)) then begin
        print, 'Within zenith deadband (alt = 90.0 +/- ', $
          strtrim(zenith_deadband, 2), ' degrees.'
        flag = TRUE
    endif
endif

;  Check azimuth
if (az GT -1.0) then begin
	if (az LE azlim_min) OR (az GE azlim_max) then begin
		print, 'Azimuth out of range:  ', strtrim(az, 2)
		flag = TRUE
	endif
endif

return, flag

END
