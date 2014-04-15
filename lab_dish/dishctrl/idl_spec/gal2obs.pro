;+
; NAME: gal2obs
; PURPOSE: convert from galactic to observer coordinates
; CALLING SEQUENCE: obsCoords = gal2obs(lon, lat, lst, epoch = epoch
;                                       obsLat = obsLat)
; INPUTS: lat - latitude in galactic coordinates in degrees
;         lon - longitude in galactic coordinates in degrees
;         lst (opt) - local sidereal time in hours (deafult to current lst)
;         epoch (opt) - epoch of desired coordinates (default to current year)
;         obsLat (opt) - observer latitude in degrees (default to Leuschner)
; OUTPUTS: obsCoords - two element array, with [altitude, azimuth] in degrees
; DEPENDENCIES: ra2az, ha2az, ra2ha, glactc
; MODIFICATION HISTORY: Written on 11 April 2008 by James McBride
;-

function gal2obs, lon, lat, lst = lst, epoch = epoch, obsLat = obsLat

if n_elements(lst) eq 0 then lst = ilst()
if n_elements(epoch) eq 0 then epoch = 2008 
if n_elements(obsLat) eq 0 then obsLat = 37.918333 

glactc, raHours, decDeg, epoch, lon, lat, 2

obsCoords = eq2obs(raHours, decDeg)

return, obsCoords
end
