function mjd2jd, input, reverse=reverse

;+
;name: mjd2jd
;
;purpose: convert MJD to JD, or vice versa.
;
;calling sequence: JD = mjd2jd( MJD) or MJD = mjd2jd( JD, /reverse)
;
;Given MJD, returns JD
;Gioven JD, returns MJD if /reverse is set
;-

if keyword_set( reverse) then begin $
    output= input - 2400000.5d0  ;output is mjd, input is jd
endif else begin
    output= input + 2400000.5d0  ;output is jd, input is mjd
endelse

return, output

end
