;+
; NAME: 
;	noise
; 
; PURPOSE:
;	control the noise diode on the antenna, 
;	which is used for calibration of spectra
;
; CALLING SEQUENCE:
;	noise, /on, /off, /state
;
; KEYWORDS:
;	on - if set, the noise diode will be turned on
;	off - if set, the noise diode will be turned off
;	state - if set, returns the present state of the diode
;
; NOTES:
;	Only one keyword should be set 
;
; MODIFICATION HISTORY:
;	Written on 15 April 2008 by James McBride
;-

pro noise, on = on, off = off, state = state

call = '/home/global/ay121/leuschner/idl/point2/noise '

if keyword_set(on) then begin
	setting = 'on'
endif else begin
	if not keyword_set(state) then setting = 'off' else setting = 'state'
endelse

spawn, call + setting

end
