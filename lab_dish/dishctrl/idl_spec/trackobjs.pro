;+
; NAME: 
;       trackObjs
;
; PURPOSE: 
;	
;
; CALLING SEQUENCE: 
;       trackObjs, raAr, decAr, coordEpoch
;
; INPUTS: 
;	raAr - array of right ascensions, in decimal hours
;	decAr - array of declinations, in decimal degrees
;	coordEpoch - epoch in which coordinates are given
;
; KEYWORDS: 
;           
; DEPENDENCIES: 
;	ra2ha, ha2az, eq2obs, takedata
;               
; MODIFICATION HISTORY: 
;       Written 7 April 2009 by James McBride
;	Partially updated 5 February 2011 by JM, but not fully tested
;-

pro trackObjs, raAr, decAr, coordEpoch

; set defaults
numIter = 3            ; number of iterations for each object

running = 1
saveName = 'statusobs.sav'
save, filename = saveName, running

numObjs = n_elements(raAr)

; set counter for file naming purposes
count = 1

while running eq 1 do begin

    for i = 0, numObjs - 1 do begin

        obsCoords = eq2obs(raAr[i], decAr[i])
	move_check = 1
	dish, alt = obsCoords[0], az = obsCoords[1], move_check = move_check
            
        if move_check eq 1 then begin

            dish, alt = obsCoords[0], az = obsCoords[1]
            
            raParts = strsplit(string(raAr[i]), '.', /extract)
            decParts = strsplit(string(decAr[i]), '.', /extract)

            filename = 'ra' + strcompress(raParts[0], /remove) + 'dec' + $ 
                strcompress(decParts[0], /remove) + '_' + $
                strcompress(count, /remove) + '_'
            print, filename
            takespec, filename, numIter = numIter

        endif

        wait, 5

    endfor

    count += 1

    restore, savename

endwhile

dish, /home

end
