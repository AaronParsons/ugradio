PRO findmoontrig, ra, dec, r, ra1, dec1

; ra, dec always in degrees

; we are using local mean sidereal time here instead of local apparent
; sidereal time as we should.  It makes a very small difference. 
; (See almanac B6,7)
;  lst, th
  th = 5.5*15.                   ;convert hours to degrees

; coordinates of Campbell Hall, Berkeley, CA
  lathms = '+37 52 40'           ; +-8 arcsec 
  lonhms = '-122 14 44'         ; +-12 arcsec
  
  lat = 37.8;hms2dec(lathms)
  lon = -122.25;hms2dec(lonhms)

  rho = 6.37814D+6              ; 1998 almanac E88 (meters)


  x = r*cos(dec/!radeg)*cos(ra/!radeg) - rho*cos(lat/!radeg)*cos(th/!radeg)
  y = r*cos(dec/!radeg)*sin(ra/!radeg) - rho*cos(lat/!radeg)*sin(th/!radeg)
  z = r*sin(dec/!radeg)                - rho*sin(lat/!radeg)

  r    = sqrt(x^2 + y^2 + z^2)
  ra1  = atan(y, x)*!radeg
  dec1 = asin(z/r)*!radeg

  return
END


PRO findmoon

  get_juldate, jd
  ; r is in earth radii
  moonpos, jd, rarad, decrad, r

  rho = 6.37814D+6              ; 1998 almanac E88 (meters)
  r = r*rho ; now distance in meters
stop
  ra  = rarad*!radeg
  dec = decrad*!radeg
stop
  findmoontrig, ra, dec, r, ra1, dec1

  print, 'Geocentric position of Moon:  (equinox of date)'
  print, 'RA=', dec2hms(ra/15.), '   dec=', dec2hms(dec)

  print
  print, 'Apparent position of Moon from Berkeley, CA: (eqx of date)'
  print, ra, dec, ' (degrees)'
  print, 'RA=', dec2hms(ra1[0]/15.), '   dec=', dec2hms(dec1[0])


  return
END
