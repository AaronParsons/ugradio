function move_it, cmd, alt_e, az_e, alt_w, az_w, noeast = noeast, $
                  nowest = nowest

;+
;modified from original move_it to use idlpc.so by Erik SHirokoff,
;april 2001.  Original file can be found in old_point2 folder
;cleaned up by ch 27 mar03
;-

common point2_common

if keyword_set(noeast) then begin 
  alt_e = -2.0  
  az_e = -2.0
endif 
if keyword_set(nowest) then begin 
  alt_w = -2.0 
  az_w = -2.0
endif

;  FORM STRING SENT TO PC
str = cmd

if (alt_e EQ -2.0) then str = str + '' else $
  if (alt_e GT -1.0) then str = str + ' alt_e=' + strtrim(alt_e, 2)

if (az_e EQ -2.0) then str = str + '' else $
  if (az_e GT -1.0) then str = str + ' az_e=' + strtrim(az_e, 2)

if (alt_w EQ -2.0) then str = str + '' else $
  if (alt_w GT -1.0) then str = str + ' alt_w=' + strtrim(alt_w, 2)

if (az_w EQ -2.0) then str = str + '' else $
  if (az_w GT -1.0) then str = str + ' az_w=' + strtrim(az_w, 2)

;  SEND MESSAGE TO PC
if (VERBOSE_) then print, 'Message to pc:  ', str
;print, 'Message to pc:  ', str

sendpc='/home/global/instrument/sendpc/sendpc'

if NOT(NOSEND_) then spawn, 'echo '+str+' | '+sendpc, result else $
  result = 'Msg from pc here.'

return, result

end









