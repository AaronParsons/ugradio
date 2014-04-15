PRO HOMER, tries = tries, woohoo = woohoo, doh = doh, verbose=verbose
;+
; NAME:
;     HOMER
; PURPOSE:
;     Home the X-band interferometer successfully.
;
; CALLING SEQUENCE:
;     HOMER [, tries = tries]
;
; INPUTS:
;     None
;
; KEYWORD PARAMETERS:
;     TRIES -- Maximum number of attempts.
;     WOOHOO -- Set to 1 if succesful homing.
;     DOH -- Set to number of tries if unsuccessful at any point.
; OUTPUTS:
;     Happily homed telescopes.
;
; MODIFICATION HISTORY:
;       Written -- Based on a program by Erik Shirokoff (surehome.pro)
;       Thu Apr 11 12:05:05 2002, Erik Rosolowsky <eros@ttauri>
;
;		
;   
;-

sendpc='/home/global/instrument/sendpc/sendpc'
ntries=1

if n_elements(tries) eq 0 then tries = 5

if keyword_set(verbose) then print, 'Homing attempt: ', ntries
doh = 0

; Pre-position the telescope for maximum homerage
r = point2(az=180, alt=45)
if r then begin
    print, 'WARNING!!!: Unsuccesful pre-pointing - proceeding anyways'
endif else begin 
    print, 'Pre-pointing successful!'
endelse

; Try the generic homing call.
spawn, 'echo home alt_e az_e alt_w az_w | '+sendpc, out
check = stregex(out, 'done home', /boolean)

; If there's a probem then we begin the joy of error checking.

WHILE (1B-CHECK[0] AND (DOH LT TRIES)) DO BEGIN
  err1 = (stregex(out,'\ ([^\ ]){1,20}limit',/ex))[0]
  name = stregex(err1, '([^\ ]){1,5}=', /ex)
  name = (strmid(name, 0, strlen(name)-1))[0]
;  stop
  spawn, 'echo point | '+sendpc, posn_str
  value = stregex(posn_str, name+'=(.+)', /ex)
  value = (float(strmid(value, strpos(value, '=')+1, strlen(value))))[0]
; Check if it's an alt drive
  if stregex(name, 'alt', /bool) then alt = 1b else alt = 0b
  targ = 0
; Put the alt drive up 30 if it's on a negative limit or down thirty
; if it's on a positive limit.
  if alt then begin
    if stregex(err1, 'positive', /bool) or $
      (stregex(err1, 'started', /bool) and value gt 45) then targ = value-30 $
    else begin
      if stregex(err1, 'negative', /bool) or $
        (stregex(err1, 'started', /bool) and value lt 45) then targ = value+30
    endelse 
; Put the az drive west 50 if it's on a negative limit or east fifty
; if it's on a positive limit.
  endif else begin
    if stregex(err1, 'positive', /bool) or $
      (stregex(err1, 'started', /bool) and value gt 180) then $
      targ = value-(90+(doh*10)) $
    else begin
      if stregex(err1, 'negative', /bool) or $
        (stregex(err1, 'started', /bool) and value lt 180) then $
        targ = (value+90+(doh*10)*(doh lt 10)+$
        (randomu(seed, 1)-0.5)*180*(doh gt 10))[0]
    endelse
  endelse 
; If nothing catches, just try a random pointing...
  if not(targ) then targ = (value+40*((randomu(seed, 1))-0.5))[0]

  value = strcompress(string(targ), /rem)
  print, 'echo point '+name+'='+value+' | '+sendpc
  spawn, 'echo point '+name+'='+value+' | '+sendpc, msg
  spawn, 'echo home '+name+' | '+sendpc, msg
  check = stregex(msg, 'done home', /boolean)
  spawn, 'echo home alt_e az_e alt_w az_w | '+sendpc, msg
  check = stregex(msg, 'done home', /boolean)
  doh = doh+1
  if tries eq doh then return

ntries= ntries+ 1
print, 'Homing attempt: ', ntries
ENDWHILE

;NOW POINT THE DAMNED THINGS STRAIGHT UP...
spawn, 'echo point alt_e=90 alt_w=90 az_e=180 az_w=180 | '+sendpc
woohoo = 1b
return

END

