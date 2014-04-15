;+
; NAME: station
;
; PURPOSE: returns the (N) long and (E) lat as floating numbers based on
; the user's .station file
;
; EXPLANATION: 
;
; CALLING SEQUENCE: station, northlat, easstlong, [path=path], [/debug]
;
; INPUTS: 
;
; OPTIONAL INPUTS
; path - the path to the .station file. if unspecified, user's home
;        directory is assumed. Path must end with '/' . e.g:
;        path='/home/heiles/', not path-'/home/heiles' .
;
; KEYWORDS: 
; debug - prints some stuff
;
; OUTPUTS: northlat, eastlong in degrees
;
; EXAMPLES:
;
; RESTRICTIONS: requires a file named ~/.station or (path + '.station')
; containing a pattern such as the following in plain ascii on the first
; two lines: 
;        nlat=37.8732 
;        elong=-122.2573. 
; These lines can be in either order. You can also specify slat or wlong
; insttead of nlat or elong. The file may contain any other info after
; these first two lines.
;
; REVISION HISTORY: 
; Erik Shirokoff (shiro@ugastro.berkeley.edu), 5/2001
; 20 Mar 2007: CH added path optinal input, updaated documentation.
;-

pro station, northlat, eastlong, path=path, debug=debug


;FIRST GET INFO FROM THE .STATION FILE
if n_elements( path) eq 0 then path= '~/'

;open the .station file for reading
openr,unit, path+ '.station', /get_lun

if keyword_set( debug) then print, path+ '.station', unit
;get the first and second lines as strings
a0=' '
a1=' '
readf,unit,a0
readf,unit,a1

a=[a0,a1]
;print,a

;close the file 
close,unit
free_lun,unit

;NOW PARSE THE STRINGS. Note we must reverse the signs of slat and
;wlong, because we want the outputs to be nlat (NORTH lat) and elong
;(EAST long). 
for nr = 0,1 do begin
    nlatpos=strpos(a[nr],'nlat=')
    if nlatpos ne -1 then northlat=double(strmid(a[nr],nlatpos+5))
    slatpos=strpos(a[nr],'slat=')
    if slatpos ne -1 then northlat=-double(strmid(a[nr],slatpos+5))
    elongpos=strpos(a[nr],'elong=')
    if elongpos ne -1 then eastlong=double(strmid(a[nr],elongpos+6))
    wlongpos=strpos(a[nr],'wlong=')
    if wlongpos ne -1 then eastlong=-double(strmid(a[nr],wlongpos+6))

endfor

if keyword_Set(debug) then print,'northlat, eastlong', northlat, eastlong

end
