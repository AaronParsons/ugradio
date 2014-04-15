;+
; NAME: 
;       eq2obs
;
; PURPOSE: 
;       convert right ascension, declination to azimuth, altitude,
;       or equatorial coordinates to observer coordinates
;
; CALLING SEQUENCE: 
;       obsCoords = eq2obs(ra, dec)
;
; INPUTS: 
;       ra - right ascension, in hours 
;       dec - declination, in degrees 
;	coordEpoch (opt) - epoch of coordinates, defaults to 2000
;       lst (opt) - local sidereal time, in hours, defaults to current lst 
;       obsLat (opt) - observer latitude, in degrees, defaults to Campbell
;
; OUTPUTS: 
;       obsCoords - observer coordinates in [alt, az] format
;
; DEPENDENCIES:
;       ra2ha, ha2az
;
; MODIFICATION HISTORY: 
;       Written on 7 April 2009 by James McBride
;-

function eq2obs, ra, dec, coordEpoch = coordEpoch, lst = lst, obsLat = obsLat

; latitude of Campbell Hall is set if no latitude is input
if not keyword_set(obsLat) then obsLat = 37.918333
if not keyword_set(lst) then lst = ilst()
if not keyword_set(coordEpoch) then coordEpoch = 2000

; get current epoch sftp://radiolab:@leuschner.berkeley.edu:3000//home/radiolab/idl_spec_code/eq2obs.pro
time = systime()
splitTime = strsplit(time, /extract)
currentEpoch = splitTime[4]

; precess coordinates
raDeg = ten(ra) * 15
print, dec
decDeg = ten(dec)
precess, raDeg, decDeg, coordEpoch, currentEpoch
raHours = raDeg / 15.

; convert to observer coordinates
haAng = ra2ha(raHours, decDeg, lst, outDecAng = outDecAng)
az = ha2az(haAng, outDecAng, alt, obsLat = obsLat)
obsCoords = [alt, az]

return, obsCoords 
end
