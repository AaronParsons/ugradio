PRO hp_dvm_read, take=take, reading = reading, verbose=verbose


;+
; NAME:
;       HP_DVM_READ
;
; PURPOSE:
;       This procedure takes a reading from the HP 3478A DVM.
;
; CALLING SEQUENCE:
;
;       HP_DVM_READ, Reading = user_variable
;
; INPUTS:
;       There are no required inputs. If no inputs are provided then this
;       help screen is printed
;
; KEYWORD PARAMETERS:
;       /Take:
;              If the "/take" keyword is set a measurement will be taken. If
;              this keyword is not set no measurement will be taken even if
;              "reading" is specified.  "Reading" variable is ignored if
;              "/take" is not specified.
;
;       /Verbose:
;              If the "/verbose" keyword is set, procedure outputs various
;              diagnostic messages to assist in troubleshooting.
;
; OPTIONAL OUTPUTS:
;       Reading:
;              If the Reading is not set to a user variable then the 
;              procedure will only print the DVM measured value to the
;              screeen and it will not be output to a variable
;
; EXAMPLES:
;       Examples of how to use hp_dvm are shown below:
;
;       HP_DVM_READ, Reading = dc_volts_meas, /take
;
;       The example shown above takes a measurement from the HP 3478A DVM
;       and stores the measurement in the named variable "dc_volts_meas".
;
; MODIFICATION HISTORY:
;       Written by:    Attila Kabai, May 6, 2009
;
;-

;/home/global/ay121/idl/pc/


if keyword_set(take) then begin

addr = 17
addr = '++addr ' + STRING(addr)
if keyword_set(verbose) then print,'Addressing GPIB ...'
gpib_strg, addr

if keyword_set(verbose) then print, 'Please Wait, Taking a Reading'
gpib_strgw,'T3',ret_val=reading
print, STRCOMPRESS('HP DVM Measurement = '+STRCOMPRESS(string(reading),/remove))
reading=reading[0]
endif else begin
doc,'hp_dvm_read'
endelse

END
