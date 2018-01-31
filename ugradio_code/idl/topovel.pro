pro topovel, obslongitude, obslatitude, ra, dec, julday, delvtopo
;+
;NAME:
;TOPOVEL -- GIVE THE COMPONENT OF EARTH'S SPIN VELOCITY TOWARDS THE RA, DEC
;
;PURPOSE:
;	GIVE THE COMPONENT OF EARTH'S SPIN VELOCITY TOWARDS THE RA, DEC
;
;CALLING SEQUENCE:
;	TOPOVEL, OBSLONGITUDE, OBSLATITUDE, RA_HRS, DEC_DEG, DELVTOPO
;
;INPUTS:
;	OBSLONGITUDE, OBSLATITUDE: OBSERVERS'S TERRESTRIAL LONG, LAT IN DEGREES.
;		the longitude must be WEST longitude: e.g. California has +122 degrees
;	RA, DEC, THE source's CURRENT RA,DEC--BOTH ARE IN **RADIANS**
;	JULDAY: THE JULIAN DAY IN DOUBLE PRECISION, WHICH TELLS THE EXACT TIME.
;
;OUTPUTS:
;	DELVTOPO: the incremental velocity from earth's spin
;
;HISTORY:
;	Written by Carl Heiles. 12 JUN 2000.

;CALCULATE THE OBSERVER'S LST...
ct2lst, lst, obslongitude, dummy, julday

;CALCULATE THE HOUR ANGLE IN RADIANS...
hourangle = !dtor*15.*lst - ra

delvtopo = 0.465 * cos( !dtor*obslatitude) * cos( dec) * sin( hourangle)

;print, 'LST, HOURANGLE, delvtopo', lst, hourangle, delvtopo
;print, 'vhelio, vlsr = ', vhelio, vlsr

hourangle_hrs = !radeg * hourangle/15.
;print, 'LST, HOURANGLE_HRS, delvtopo', lst, hourangle_hrs, delvtopo

;stop
return
end

