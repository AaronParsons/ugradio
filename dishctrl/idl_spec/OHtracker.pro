PRO OHtracker
;define ra and dec
ra=TEN([02,23,16.3])
dec=TEN([61, 38, 57])


;for 2 hours of integration time we need 20 6-minute sessions.

for i=1, 20 do begin

;re-calculate ra and dec with each integration. 

obsCoords = eq2obs(ra,dec)
alt = obsCoords[0]
az = obsCoords[1]

move_check=1
dish, alt=alt, az=az, move_check=movecheck

; only run while W3 is up


; point dish at W3
dish, alt=alt, az=az

;take spectra
takespec, 'OnSource', numSpec = 10, numfiles = 1

;point dish off source
alt = alt
az = az-6

; re-point dish, six degrees off source
dish, alt, az

;take offsource spectra
takespec, 'offsource', numSpec = 10, numfiles =1

endfor

END
