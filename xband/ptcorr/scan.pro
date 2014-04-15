;+
; NAME:  
;	scan.pro
;
; PURPOSE:
;	This procedure performs an alt-az scan of the sun or moon
;	with both east and west 12 GHz antenna. it defines various
;	structure parameters and writes them out to a save file.
;
; CALLING SEQUENCE:
;	SCAN, fname, head, dat $
;	[, size=, space=, /reverse, /nocorrect, /moon]
;		
;
; INPUTS:
;	fname:	File data is save to.  Paths may be included.
;		Otherwise the current directory is assumed.
;
; KEYWORDS:
;	size:	The size (number or samples performed in both
;		the altitude and azimuth directions) of the cross.
;		Default is a 10x10.
;	space	The spacing between adjacent samples of the cross.
;		Default is 0.5 degrees.
;	reverse:  Perform the cross with the antennas in reverse mode.
;		Default is forward mode
;	nocorrect:  Perform the sampling without pointing corrections.
;	moon:	Perform a drift curve of the moon.  Otherwise, the
;		sun is used as an object.
;
; OUTPUTS:
;	HEAD, DAT: the data files that are written to the output file fname.
;
; EXAMPLE:
;	THIS EXAMPLE IS NOT APPLICABLE...DOC NEEDS WORK!!
;	DRIFTER
;		Preform drift curve with default values for everything.
;	
;	DRIFTER, 'sun100for.dat', /reverse, /nocorrect, /moon, size=15, space=0.2
;		Perform a scan of the moon, in reverse mode, without
;		correcting for pointing errors, 15 elements in both
;		directions, with samples spaced 0.2 degrees apart, and 
;		save the data into the file 'sun100for.dat'.
;
; MODIFICATION HISTORY:
;	Original procedure (sunfinder.pro) by Murray Brown, 10/97
;	Extensive rewriting by Curtis Frank and Carl Heiles, (drifter.pro) 11/97
;	moon added, Curtis Frank, (drifter.pro) 11/25/98
;	Rewritten and redocumented (again), Curtis Frank, 4/20/99
;       rewritten Erik Shirokoff 5/23/01
;
;	rewrite/mods ch mar 12 2003
;-



pro scan, fname, $		;  File name
	  head, $
	  dat, $
          size=size, $		;  Grid Size
          space=space, $        ;  Grid Spacing
          reverse=reverse, $	;  Reverse pointing
          nocorrect=nocorrect, $ ;  Tell the pointing software not to make pointing corrections
          moon=moon, $		;  Look at the moon
          win_num=win_num,  $     ;  Secret, undocumented window number keyword
          debug=debug            ; prints out lots of info

debug=keyword_set(debug)

;  Determine size of arrays
if not (keyword_set(size)) then $
  size = 10


;  Open the nodes, and configure relays
;result = call_external('idlmira.so', 'open', 'mira')
;result = call_external('idlpc.so', 'open', 'quasar')
;result = call_external('idlpc.so', 'xmit', 'dig configure', /s_value)		

;  Initialize the data structure for both the east and west dishes.  dat[0].xxx
;  corresponds to the east dish, dat[1].xxx corresponds to the west dish.
;  dat[*].pow[*,0] corresponds to the vertical portion of the cross.  dat[*].pow[*,1]
;  corresponds to the horizontal portion.





head = {size: 		0, $
        space:		0.0, $
        reverse:	0, $
        nocorrect:	0, $
        moon:		0, $
        lon:		0.d, $  ;  Source longitude
        s_ra:		0.0, $  ;  Source RA
        s_dec:		0.0, $  ;  Source dec
        s_alt:          0.0,$ 
        s_az:           0.0, $
	juldate:	0.0d0, $;  scan Julian day nr
        udate:          ''}     ;  Scan Universal Date
;;      corval:         fltarr(16)}   ; current pointing corrections

dat = replicate	({pow:		fltarr(size,2), $ ;  Power from antenna
         unalt:	fltarr(size,2), $ ;  Uncorrected alt from point2
         unaz:	fltarr(size,2), $ ;  Uncorrected az from point2
         coralt:fltarr(size,2), $ ;  Corrected alt from point2
         coraz:	fltarr(size,2), $ ;  Corrected az from point2
         alt:		fltarr(size,2), $ ;  Alt sent to point2
         az:		fltarr(size,2), $ ;  Az sent to point2
         srcalt:fltarr(size,2), $ ;  true source alt from scan_it_all
         srcaz:	fltarr(size,2), $ ;  true source az from scan_it_all
         lst:		fltarr(size,2)}, 2) ;  Average LST of data point

;  LONGITUDE OF CAMPBELL HALL	
station, lat, long
head.lon= - long
;head.lon = 122.d + 14.d/60.d + 44.d/3600.d

;  Get Universal date and time, also the Julian day...
;spawn, 'date -u', temp
;head.udate = temp[0]
head.udate= systime(/utc)
head.juldate= systime(/julian,/utc)

;GET THE POINTING OFFSETS IN CASE ANYONE EVER NEEDS THEM
;a=' '
;count=0
;val=fltarr(8)
;openr, unit2, '/home/shiro/idl/point.config',/get_lun
;while NOT eof(unit2) do begin
;    readf, unit2, a
;    if NOT ((strmid(a, 0, 1) EQ ';') OR (strlen(a) EQ 0)) then begin
;        val[count] = float(a) 
;        count = count + 1
;    endif
;endwhile
;close, unit2
;free_lun,unit2
;head.corval=val

;  Determine what keywords have been set or set defaults

if not (keyword_set(size)) then $
  head.size = 10 $	
else $
  head.size = size

if not (keyword_set(space)) then $
  head.space = 0.5 $
else $
  head.space = space

if keyword_set(reverse)	 then $
  head.reverse = 1 $
else $
  head.reverse = 0

if NOT(keyword_set(nocorrect)) then $
  head.nocorrect = 0 $
else $
  head.nocorrect = nocorrect

if keyword_set(moon) then $
  head.moon = 1 $
else $
  head.moon = 0

if not(keyword_set(win_num)) then $
  win_num = -1

;  Get the RA, dec coordinates of the sun or moon.  It is assumed
;  that the RA and dec of the sun or moon do not change appreciably
;  during the course of one drift scan.  Also note that the outputs
;  of moonpos and sunpos are in degrees for both RA and dec.  All
;  coordinates are geocentric, and the topocentric conversion is
;  generally necessary for lunar coordinates.

;DO THE MOON, OR THE SUN, DEPENDING...
IF KEYWORD_SET(MOON) THEN BEGIN
;imoon, aamoon,topo_ra,topo_dec
imoon, topo_ra,topo_dec
head.s_ra = topo_ra
head.s_dec = topo_dec
s_name = 'moon'
ENDIF ELSE BEGIN
isun,ra,dec
head.s_ra = ra 
head.s_dec = dec
s_name = 'sun'
ENDELSE

if debug then print,'ra,dec:',head.s_ra,head.s_dec

lst=lstnow()

if debug then print,'lst:',lst
ha = lst - head.s_ra

;stop

;print,'scan line 211, sending the dishes home using HOMER'
;homer
;surehome

;endfor
scan_it_all, head, dat, 0, win_num
scan_it_all, head, dat, 1, win_num


;  Hmmmm.  The data are taken.  Probably should save them.
print, 'Saving data to ', fname, '.'

;LET'S ALSO RECORD THE POINTING CORRECTIONS - SOMEDAY WE MAY WANT
                                    ;         THEM!
IF (STRPOS(FNAME, '.DAT') EQ -1) THEN BEGIN
    save, head, dat, filename=fname
ENDIF ELSE BEGIN
    openw, unit1, fname,/get_lun
    printf, unit1, head
    printf, unit1, dat
    close, unit1
    free_lun,unit1
ENDELSE

;NOW PLOT THE DATA...
plotscan, dat

;  Reset the  status window.
    if NOT(win_num EQ -1) then $
      scan_progress, win_num, head.size, head.space


end







