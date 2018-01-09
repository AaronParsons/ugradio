PRO hp_dvm_mode,mode=mode,zero=zero, verbose=verbose

;+
; NAME:
;       HP_DVM_MODE
;
; PURPOSE:
;       This procedure controls most of the functionality of the 
;       HP 3478A DVM.
;
; CALLING SEQUENCE:
;
;       HP_DVM, Mode = integer, Range = integer, Reading = user_variable
;
; INPUTS:
;       There are no required inputs. If no inputs are provided then this
;       help screen is printed
;
; OPTIONAL INPUTS:
;       Mode:
;              If mode is not specified, the mode that the DVM is currently
;              in is what will be used
;
;              These are the following modes that are available:
;
;                    Mode = 1    Measures DC Volts
;                    Mode = 2    Measures AC Volts
;                    Mode = 3    Measures DC Amps
;                    Mode = 4    Measures AC Amps
;                    Mode = 5    Measures 2-Wire Ohms
;                    Mode = 6    Measures 4-Wire Ohms
;
; KEYWORD PARAMETERS:
;       /Zero:
;              If the "/zero" keyword is set the DVM will be zeroed after
;              after the mode and range is changed. Should only be used
;              when disconected from any source. If used while connected
;              to a source, measurement will be equal to zero even if a
;              voltage is present.
;
;       /Verbose:
;              If the "/verbose" keyword is set, procedure outputs various
;              diagnostic messages to assist in troubleshooting.
;
; EXAMPLES:
;       Examples of how to use hp_dvm are shown below:
;
;       HP_DVM_MODE, Mode = 1, /Zero
;
;       The example shown above sets the HP 3478A DVM to measure
;       DC Volts and zeros the measurement
;
; MODIFICATION HISTORY:
;       Written by:    Attila Kabai, May 6, 2009
;
;-


if n_elements(mode) eq 0  and (not keyword_set(zero)) then begin
doc,'hp_dvm_mode'
endif else begin
if n_elements(mode) ne 0 then begin
error = 1
for n=1,6 do if mode eq n then error=0

if error eq 0 then begin

addr = 17
addr = '++addr ' + STRING(addr)
if keyword_set(verbose) then print,'Addressing GPIB ...'
gpib_strg, addr

mode_strg='F'+STRCOMPRESS(string(mode),/remove)
mode_strg=STRCOMPRESS(mode_strg)
if keyword_set(verbose) then print,STRCOMPRESS('Please Wait, Changing to Mode '+string(mode))
gpib_strg,mode_strg
if keyword_set(verbose) then print,'Mode Changing successful'
if keyword_set(zero) then begin
if keyword_set(verbose) then print,'Please Wait, Zeroing HP DVM!'
gpib_strg,'Z1'
if keyword_set(verbose) then print,'HP DVM has been successfully Zeroed'
endif

endif else begin
print,'Error - "mode" must be an integer value from 1 to 6'
print,'Run "dvm_mode" without any arguments to print help screen'
endelse
endif

endelse

END