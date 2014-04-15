;+
; NAME: correct
;
; PURPOSE: performs pointing corrections for the interferometer, used
; by point2
;
;the formulae assumed are (for east; west is identical):
;
;az_sky= az_enc- az_e_dial- [mult* az_e_skew_const/ cos(alt_enc* !dtor)]
;alt_sky=  alt_enc- alt_e_dial- [alt_e_flop_const* cos(alt_enc* !dtor)]
;
;alt_enc = alt_sky + alt_e_dial + alt_e_flop_const* cos(alt_sky* !dtor)
;az_enc = az_sky + az_e_dial+ mult* az_e_skew_const/ cos(alt_sky* !dtor)
;
;NOTE THAT THE correction is not precisely reversible, because we assume that 
;alt_sky = alt_enc in the term that contains cos(alt). wo we are
;assuming that the alt correction is small.
;
; EXPLANATION: this program uses the point2_common block, and should
; only be used in conjunction with the point2 program
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; OPTIONAL INPUT KEYWORDS:
;
; OUTPUTS: 
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED:
;
; REVISION HISTORY:  probably written by Curtis Frank.  Modified to
; seperate the forward and reverse case and other small changes by
; Erik Shirokoff, 5/2001.
;  * changed the sign of the alt dial offset, ES, Aug 6,2001

; 14 mar03. cosmetic changes to make code more readable. ch
;also, eliminated the fxroot compliation, ie we assume corrections are
;small. see comments under the old program, which is called 
;correct_pre-carl.pro
;
;-

PRO CORRECT, dir, alt_e, az_e, alt_w, az_w, buggy=buggy

;turn this on for debugging
if (n_elements(buggy) eq 0) then buggy=0

;buggy=1

common point2_common

;  Initializations
mult = 1.0
phase = 0.0
a = ''
val = fltarr(16)
count = 0

;  Load pointing correction values
openr, unit1, '/home/global/ay121/idl/xband/point2/point.config2',/get_lun

while NOT eof(unit1) do begin
    readf, unit1, a
    if NOT ((strmid(a, 0, 1) EQ ';') OR (strlen(a) EQ 0)) then begin
        val[count] = float(a) 
        count = count + 1
    endif
endwhile

close, unit1
free_lun,unit1

;stop

;  Set pointing correction values.

rev1=fix(keyword_set(REVERSE_) * 8) 
;determines whether the first or second eight rows are used.

alt_e_dial = val[0+rev1]
alt_e_flop_const = val[2+rev1]
;alt_e_flop = alt_e_flop_const * cos (alt_e * !dtor)

az_e_dial = val[1+rev1]
az_e_skew_const=val[3+rev1]
;az_e_dskew = val[3+rev1] / cos (alt_e * !dtor)

alt_w_dial = val[4+rev1]
alt_w_flop_const = val[6+rev1]
;alt_w_flop = alt_w_flop_const * cos (alt_e * !dtor)

az_w_dial = val[5+rev1]
az_w_skew_const=val[7+rev1]
;az_w_dskew = val[7+rev1] / cos (alt_e * !dtor)

if buggy then begin
    print,'alt_e_dial',alt_e_dial
    print,'alt_e_flop_const',alt_e_flop_const
    print,'az_e_dial',az_e_dial
    print,'az_e_skew_const',az_e_skew_const

    print,'alt_w_dial',alt_w_dial
    print,'alt_w_flop_const',alt_w_flop_const
    print,'az_w_dial',az_w_dial
    print,'az_w_skew_const',az_w_skew_const
endif

if (REVERSE_) then begin
    mult=-1.0
    phase=180.0
end

;print, 'phase, mult ', phase, mult

if buggy then begin
    print,' '
    print,'before corrections:'
    print,'alt_e,az_e=',alt_e,az_e  
    print,'alt_w,az_w=',alt_w,az_w
endif

;  Perform corrections depending on direction
CASE DIR OF
  SKY_TO_ENC:  BEGIN

;APPLY PHASE AND MULT CORRECTIONS, WHICH DEPEND ONLY ON FORWARD/REVERSE...
           alt_e_u = phase + mult* alt_e
           az_e_u = phase + az_e
           alt_w_u = phase + mult* alt_w
           az_w_u = phase + az_w

    CASE NOCORRECT_ OF

      TRUE:   BEGIN       ;  NO CORRECTIONS
           alt_e = alt_e_u
           az_e = az_e_u
           alt_w = alt_w_u
           az_w = az_w_u
      END

      2:      BEGIN       ;  DIAL CORRCTIONS ONLY!
           alt_e = alt_e_u+ alt_e_dial 
           az_e = az_e_u+ az_e_dial
           alt_w = alt_w_u+ alt_w_dial 
           az_w = az_w_u+ az_w_dial
	;print, 'dial corr only, sky_to_enc!'
	;print, alt_e, alt_e_u, alt_e_dial
      END

      FALSE:  BEGIN      
           alt_e = alt_e_u+ alt_e_dial + alt_e_flop_const* cos(alt_e* !dtor)
           az_e = az_e_u+ az_e_dial+ mult* az_e_skew_const/ cos(alt_e* !dtor)

           alt_w = alt_w_u+ alt_w_dial + alt_w_flop_const* cos(alt_w* !dtor)
           az_w = az_w_u+ az_w_dial+ mult* az_w_skew_const/ cos(alt_w* !dtor)
      END
;    ELSE:
      ENDCASE
END

    ENC_TO_SKY: BEGIN

;APPLY PHASE AND MULT CORRECTIONS, WHICH DEPEND ONLY ON FORWARD/REVERSE...
           alt_e_u = alt_e
           az_e_u =  az_e
           alt_w_u = alt_w
           az_w_u = az_w

    CASE NOCORRECT_ OF

      TRUE:   BEGIN       ;  NO CORRECTIONS
           alt_e = alt_e_u
           az_e = az_e_u
           alt_w = alt_w_u
           az_w = az_w_u
      END

      2:      BEGIN       ;  DIAL CORRCTIONS ONLY!
           alt_e = alt_e_u- alt_e_dial 
           az_e = az_e_u- az_e_dial
           alt_w = alt_w_u- alt_w_dial 
           az_w = az_w_u- az_w_dial
	;print, 'dial corr only, enc_to_sky!'
	;print, alt_e, alt_e_u, alt_e_dial
      END

      FALSE:  BEGIN      
           alt_e = alt_e_u- alt_e_dial- alt_e_flop_const* cos(alt_e* !dtor)
           az_e = az_e_u- az_e_dial- mult* az_e_skew_const/ cos(alt_e* !dtor)

           alt_w = alt_w_u- alt_w_dial- alt_w_flop_const* cos(alt_w* !dtor)
           az_w = az_w_u- az_w_dial- mult* az_w_skew_const/ cos(alt_w* !dtor)
      END
;    ELSE:
      ENDCASE

;APPLY PHASE AND MULT CORRECTIONS, WHICH DEPEND ONLY ON FORWARD/REVERSE...
           alt_e = phase + mult* alt_e
           az_e = -phase + az_e
           alt_w = phase + mult* alt_w
           az_w = -phase + az_w

END
ENDCASE

;  Make damn sure that azimuths fall within 0 <= az < 360
az_e = pmod(az_e, 360.0)
az_w = pmod(az_w, 360.0)

if buggy then begin
    print,' '
    print,'after. corrections:'
    print,'alt_e,az_e=',alt_e,az_e  
    print,'alt_w,az_w=',alt_w,az_w
endif

end













