;+
; NAME: isUp
; PURPOSE: returns whether an object is up or not
; CALLING SEQUENCE: up = isUp(alt, az)
; INPUTS: alt - altitude in degrees
;         az - azimuth in degrees
; OUTPUTS: up - array where one corresponds to up, zero to down
; MODIFICATION HISTORY: Written on 11 April 2008 by James McBride
;-

function isUp, alt, az

restore, 'alt_limit.sav'

negAz = where(az lt 0)
if n_elements(negAz) eq 1 then begin
   if negAz eq -1 then az = az else az[negAz] = az[negAz] + 360
endif else begin
    az[negAz] = az[negAz] + 360
endelse

up = where(alt gt alt_limit[round(az)] + 1)
if n_elements(up) eq 1 then begin
    if up eq -1 then up = 0 else up = 1
endif 

return, up
end

