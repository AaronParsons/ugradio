PRO hp_dvm_range, range=range, verbose=verbose


;+
; NAME:
;       HP_DVM_RANGE
;
; PURPOSE:
;       This procedure controls the Range of the HP 3478A DVM.
;
; CALLING SEQUENCE:
;
;       HP_DVM_RANGE, Range = integer
;
; INPUTS:
;       There are no required inputs. If no inputs are provided then this
;       help screen is printed
;
; OPTIONAL INPUTS:
;       Range:
;              These are the following ranges that are available:
;
;                    Range = -2  30mV DC Range
;                    Range = -1  300mv AC/DC or 300mA AC/DC Range
;                    Range =  0  3 V AC/DC or 3 A AC/DC Range
;                    Range =  1  30 V AC/DC or 30 Ohm Range
;                    Range =  2  300 v AC/DCor 300 Ohm Range
;                    Range =  3  3K Ohm Range
;                    Range =  4  30K Ohm Range
;                    Range =  5  300K Ohm Range
;                    Range =  6  3M Ohm Range
;                    Range =  7  30M Ohm Range
;                    Range =  8  Auto-Range
;
; KEYWORD PARAMETERS:
;       /Verbose:
;              If the "/verbose" keyword is set, procedure outputs various
;              diagnostic messages to assist in troubleshooting.
;
; EXAMPLES:
;       Examples of how to use hp_dvm are shown below:
;
;       HP_DVM_RANGE, Range = 8
;
;       The example shown above sets the range of the HP 3478A DVM to
;       Auto-Range.
;
; MODIFICATION HISTORY:
;       Written by:    Attila Kabai, May 6, 2009
;
;-




if n_elements(range) eq 0 then begin
doc,'hp_dvm_range'
endif else begin

if n_elements(range) ne 0 then begin
error = 1
for n=-2,8 do if range eq n then error=0

if error eq 0 then begin

addr = 17
addr = '++addr ' + STRING(addr)
if keyword_set(verbose) then print,'Addressing GPIB ...'
gpib_strg, addr

if range eq 8 then begin
if keyword_set(verbose) then print, 'Please Wait, Changing Range to Autorange'
gpib_strg,'RA'
if keyword_set(verbose) then print, 'Range Successfully changed to Autorange'
endif else begin
range_strg='R'+STRCOMPRESS(string(range),/remove)
range_strg=STRCOMPRESS(range_strg)
if keyword_set(verbose) then print,STRCOMPRESS('Please Wait, Changing to Range '+string(range))
gpib_strg,range_strg
if keyword_set(verbose) then print,'Range Changing Successful'
endelse
endif else begin
print,'Error - "range" must be an integer value from -2 to 6'
print,'Run "dvm_range" without any arguments to print help screen'
endelse
endif

endelse

END