pro lsrvel, ra_epoch, dec_epoch, equinox, delvlsr
;+
;NAME:
;LSRVEL -- give LSR velocity towards an ra, dec
;
;PURPOSE:
;	GIVE THE COMPONENT OF LSR VELOCITY TOWARDS THE GIVEN ELL, BEE
;	'LSR' MOVES WITH 20.000 KM/S TOWARDS ra1900, dec1900 = 18.000, 30.000
;
;CALLING SEQUENCE:
;	LSRVEL, RA_EPOCH, DEC_EPOCH, EQUINOX, VLSR
;
;INPUTS:
;	RA_EPOCH: the R.A. of the position, DECIMAL HOURS.
;	DEC_EPOCH, THE DEC IN DECIMAL DEGREES.
;	EQUINOX: THE EQUINOX OF THE POSITIONS, E.G. 2000.
;
;OUTPUTS:
;	DELVLSR: the velocity in the LSR frame.
;
;HISTORY:
;	Written by Carl Heiles. 12 JUN 2000.

;IF YOU NEED TO CONVERT FROM GALACTIC TO EQUATORIAL BEFORE ENTERING THIS:
;CONVERT INPUT GALACTIC COORDS TO 1900 EPOCH EQUATORIAL COORDS...
;	glactc, ra1900, dec1900, 1900.0, ell, bee, 1
;-


;PRECESS THE INPPUT RA, DEC, TO 1900:
ra1900_deg = ra_epoch*15.
dec1900 = dec_epoch
precess, ra1900_deg, dec1900, equinox, 1900.
ra1900 = ra1900_deg/15.

;CONVERT RA, DEC TO RADIANS...
ra = !dpi * ra1900/12.0d0
dec = !dpi * dec1900/180.0d0

;GET THE X,Y,Z VECTOR OF THE SOURCE AT EQUINOX 1900...
xx = fltarr(3)
xx[0] = cos(dec) * cos(ra)
xx[1] = cos(dec) * sin(ra)
xx[2] = sin(dec)

;...GET THE CONVENTIONAL LSR SOLAR MOTION.
;	LSR MOVES WITH 20.000 KM/S TOWARDS ra1900, dec1900 = 18.000, 30.000
ralsr = !dpi * 18.0d0/12.0d0
declsr = !dpi * 30.0d0/180.0d0
xxlsr = fltarr(3)
xxlsr[0] = cos(declsr) * cos(ralsr)
xxlsr[1] = cos(declsr) * sin(ralsr)
xxlsr[2] = sin(declsr)
vvlsr = 20.0*xxlsr
vvlsrsrc = total(xx*vvlsr)

delvlsr = -vvlsrsrc

;print, 'vrjr, vvrjrsrc, vvlsrsrc ', vrjr, vvrjrsrc, vvlsrsrc 
;print, 'vhelio, vlsr = ', vhelio, vlsr

;stop
return
end

