PRO set_srs, frq=frq, vpp=vpp, dbm=dbm, off=off, phs=phs, srs2=srs2, help=help

;+
; NAME:   set_srs
;
; PURPOSE:   All-in-one program to control SRS DS345 function generators
;
; CALLING SEQUENCE:  set_srs [, frq=value] [, vpp=value] [, dbm=value]
;                    [, off=value] [, phs=value] [,/srs2] [,/help]
;
; INPUTS:  None
;
; OPTIONAL INPUTS:
;                      frq - desired frequency [Hz]
;                      vpp - desired peak-to-peak voltage [V]
;                      dbm - desired milli-deciBel [dbm]
;                      off - desired DC offset [V]
;                      phs - desired phase [degrees]
;
; KEYWORD PARAMETERS:
;                      /srs2 - control the SRS2 function generator,
;                              default controls SRS1.
;                      /help - prints the help screen
; OUTPUTS:   None
;
; RESTRICTIONS:
;                      frq: 0 < frq < 30e6 Hz
;                      vpp: -5  < vpp < 5 V, but may clip if off is large
;                      dbm: -36 < dbm < +23 dBm
;                      off: -5 < off < 5 V, but may clip if vpp is large
;                      phs: 0 < phs < 7200 degrees
;
;                      If vpp and dbm are both specified, priority is
;                      given to dbm setting.
;
; EXAMPLE:
;                      set_srs, frq=1e6, vpp=3, /srs2
;                      Sets SRS2 to a 1 MHz sine wave with peak-to-peak 
;                      amplitude=3V.
;
; MODIFICATION HISTORY:
;
;                      29 Jan 2008 - Created by DWL
;                      13 Mar 2008 - Removed n_params() for strlen() to
;                                    print help
;-

val = n_elements(frq) + n_elements(vpp) + n_elements(dbm) + n_elements(off) + n_elements(phs)

; Set GPIB Address / controller mode / EOS Mode

if keyword_set(srs2) then addr = '21' else addr = '19'

if val ne 0 then begin
addr = '++addr ' + STRING(addr)
gpib_strg, addr
mode = '++mode 1'
gpib_strg, mode
eos = '++eos 2'
gpib_strg, eos
endif

; Create and Send the command to SRS

; ----- frq ---------------

if n_elements(frq) ne 0 then begin
if (frq GT 0.000001) and (frq LT 30e6) then begin
frq_arg = 'FREQ ' + string(frq,FORMAT='(f0.6)')
gpib_strg,frq_arg
endif else begin
print, 'FREQUENCY INPUT ERROR => 1 uHz < FREQUENCY < 30 MHz'
print, 'FREQUENCY REMAINS UNCHANGED'
endelse
endif

; ----- frq ---------------

; ----- vpp and dbm -------

if (n_elements(vpp) ne 0) and (n_elements(dbm) ne 0) then begin

if n_elements(dbm) ne 0 then begin
if (dbm GT -36) and (dbm LT 23) then begin
print, 'WARNING - VPP and DBM can not be both specified at the same time'
print, 'Will default to DBM and VPP will be ignored'
dbm_arg = 'AMPL ' + string(dbm,FORMAT='(f0.2)')+' DB'
gpib_strg,dbm_arg
endif else begin
if (vpp GT -5) and (vpp LT 5) then begin
print, 'WARNING - VPP and DBM can not be both specified at the same time'
print, 'DBM is out of range, VPP will be used'
vpp_arg = 'AMPL ' + string(vpp,FORMAT='(f0.2)')+' VP'
gpib_strg,vpp_arg
endif else begin
print, 'WARNING - VPP and DBM can not be both specified at the same time'
print, 'VPP AMPLITUDE INPUT ERROR => -5 Vpp < AMPLITUDE < 5 Vpp'
print, 'DBM AMPLITUDE INPUT ERROR => -36 dBm < AMPLITUDE < 23 dBm'
print, 'AMPLITUDE REMAINS UNCHANGED'
endelse
endelse
endif

endif else begin

if n_elements(vpp) ne 0 then begin
if (vpp GT -5) and (vpp LT 5) then begin
vpp_arg = 'AMPL ' + string(vpp,FORMAT='(f0.2)')+' VP'
gpib_strg,vpp_arg
endif else begin
print, 'AMPLITUDE INPUT ERROR => -5 Vpp < AMPLITUDE < 5 Vpp'
print, 'AMPLITUDE REMAINS UNCHANGED'
endelse
endif

if n_elements(dbm) ne 0 then begin
if (dbm GT -36) and (dbm LT 23) then begin
dbm_arg = 'AMPL ' + string(dbm,FORMAT='(f0.2)')+' DB'
gpib_strg,dbm_arg
endif else begin
print, 'AMPLITUDE INPUT ERROR => -36 dBm < AMPLITUDE < 23 dBm'
print, 'AMPLITUDE REMAINS UNCHANGED'
endelse
endif

endelse

; ----- vpp and dbm -------

; ----- off ---------------

if n_elements(off) ne 0 then begin
if (off GT -5) and (off LT 5) then begin
off_arg = 'OFFS ' + string(off,FORMAT='(f0.2)')
gpib_strg,off_arg
endif else begin
print, 'OFFSET INPUT ERROR => -5 V < OFFSET < 5 V'
print, 'OFFSET REMAINS UNCHANGED'
endelse
endif

; ----- off ---------------

; ----- phs ---------------

if n_elements(phs) ne 0 then begin
if (phs GE 0) and (phs LT 7200) then begin
phs_arg = 'PHSE ' + string(phs,FORMAT='(f0.3)')
gpib_strg,phs_arg
endif else begin
print, 'PHASE INPUT ERROR => 0 deg < OFFSET < 7200 deg'
print, 'PHASE REMAINS UNCHANGED'
endelse
endif

; ----- phs ---------------

; Print help if no arguments are given

if val eq 0 or keyword_set(help) then begin
    doc, 'set_srs'
    return
endif

END

