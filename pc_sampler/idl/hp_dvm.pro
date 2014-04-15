PRO hp_dvm, mode=mode, range=range, zero=zero, reading=reading, take=take, verbose=verbose

;+
; NAME:
;       HP_DVM
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
;       Range:
;              If the range is not set, the DVM will stay at the range
;              that was last used.
;
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
;       /Zero:
;              If the "/zero" keyword is set the DVM will be zeroed after
;              after the mode and range is changed. Should only be used
;              when disconected from any source. If used while connected
;              to a source, measurement will be equal to zero even if a
;              voltage is present.
;
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
;       HP_DVM, Mode = 1,Range = -1,/take, Reading = dc_volts_meas
;
;       The example shown above sets the HP 3478A DVM to measure
;       DC Volts, Sets the Range to 300mV, and stores the measurement
;       in the named variable "dc_volts_meas".
;
;       HP_DVM, /take
;
;       The example shown above takes a measurement. This example uses
;       the same settings that were in effect before the procedure was
;       executed.
;
;       HP_DVM, /zero
;
;       The example shown above zeros the DVM and leaves all other modes
;       unchanged.
;
; MODIFICATION HISTORY:
;       Written by:    Attila Kabai, May 6, 2009
;
;-

arg_sel = 0;

arg_sel=n_elements(mode)+n_elements(range)+keyword_set(zero)+keyword_set(take)
if arg_sel eq 0 then begin
doc,'hp_dvm'
endif else begin

mode_error = 1
range_error = 1

if n_elements(mode) ne 0 then for n=1,6 do if mode eq n then mode_error=0     ;MODE Error checking - Allowable values
if n_elements(range) ne 0 then for n=-2,8 do if range eq n then range_error=0   ;RANGE Error checking - Allowable values

if n_elements(mode) ne 0 and mode_error ne 0 then begin
print,'Error - "MODE" must be an integer value from 1 to 6'		;MODE error messages
print,'Run "hp_dvm" without any arguments to print the help screen'
goto,JUMP1
endif

if n_elements(range) ne 0 and range_error ne 0 then begin
print,'Error - "RANGE" must be an integer value from -2 to 8'		;RANGE error messages
print,'Run "hp_dvm" without any arguments to print the help screen'
goto,JUMP1
endif

addr = 17                                     ;Sets prologix address to 17
addr = '++addr ' + STRING(addr)
if keyword_set(verbose) then print,'Addressing GPIB ...'
gpib_strg, addr

dvm_com = ''

;  Sets up the "MODE" part of the command
if n_elements(mode) ne 0 and mode_error eq 0 then begin
mode_arg = STRCOMPRESS(('F' + String(mode)),/remove)
dvm_com = dvm_com + mode_arg
endif


;  Sets up the "RANGE" part of the command
if n_elements(range) ne 0 and range_error eq 0 then begin
if range ne 8 then begin
range_arg = STRCOMPRESS(('R' + String(range)),/remove)
endif else begin
range_arg = 'RA'
endelse
dvm_com = dvm_com + range_arg
endif

dvm_com = dvm_com + 'N4'

;  Sets up the "zero" part of the command
if keyword_set(zero) then dvm_com = dvm_com + 'Z1'

;  Sets up the 'take" part of the command
if keyword_set(take) then dvm_com = dvm_com + 'T3'

;  Actually sends the command
dvm_com = STRCOMPRESS(dvm_com,/remove)
if keyword_set(verbose) then print,'The following command will be sent to HP DVM =>',dvm_com
if keyword_set(verbose) then print,'Please Wait, Performing Requested Operations'
if keyword_set(take) then gpib_strgw, dvm_com, ret_val=reading else gpib_strg, dvm_com
if keyword_set(take) then print,('Measured Value = ' + STRCOMPRESS(string(reading),/remove))
if keyword_set(take) then reading=reading[0]
endelse

if keyword_set(verbose) then print,'Done!'
JUMP1:

END
