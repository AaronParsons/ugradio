FUNCTION pointingtest, coor, type, alt_val, az_val, deltheta, segments, spectra, gauss_res=gauss_res, spec_sums=spec_sums
;Test function to determine Pointing Necessity

;Primary Error Checking

coo_err = 0
alt_err = 0
az_err = 0
del_err = 0
seg_err = 0
type_err = 0
spec_err = 0

IF (coor LT 0) OR (coor GT 2) THEN coo_err = 1
IF (alt_val GT 90) OR (alt_val LT -90) THEN alt_err = 1
IF (az_val GT 360) OR (az_val LT 0) THEN az_err = 1
IF (deltheta LE 0) OR (deltheta GT 50) THEN del_err = 1
IF (segments LE 0) OR (segments GT 100) THEN seg_err = 1
IF (type LT 1) OR (type GT 3) THEN type_err = 1
IF (spectra LE 0) OR (spectra GT 100) THEN spec_err = 1

any_err = coo_err + alt_err + az_err + del_err + seg_err + type_err + spec_err

IF any_err THEN print,'THERE ARE ',any_err,' INPUT ERRORS!'

IF any_err GT 0 THEN BEGIN
print,'POINTINGTEST(coor,type,alt,az,deltheta,segments,spectra,gauss_res=gauss_res,spec_sums=spec_sums)'
IF coo_err THEN print, 'Error - "coor" = 0 Alt-Az / 1 Equitorial / 2 Galactic '
IF alt_err THEN print,'Error - "alt" must be between -90 <= alt <= 90'
IF az_err THEN print,'Error - "az" must be between 0 <= az <= 360'
IF del_err THEN print,'Error - "deltheta" must be between 0 < deltheta <= 10'
IF seg_err THEN print,'Error - "segments" must be between 0 < segments <= 100'
IF type_err THEN print,'Error - "type" = 1 Single / 2 Cross / 3 segxseg array'
IF spec_err THEN print,'Error - "spectra" must be between 2 < spectra <= 100'
ENDIF

IF any_err GT 0 THEN GOTO, JUMP1

; It is first necessary to set up the points in orthogonal normal and tangent planes
; phi = ACOS(COS(alt)*COS(az))

print,alt_val,az_val

;COORDINATE TRANSFORMATION -------------------------------------------

!PATH = !PATH + ':/home/radiolab/idl_spec_code/'
!PATH = !PATH + ':/home/radiolab/spec_code/'
alt_val = FLOAT(alt_val)
az_val = FLOAT(az_val)

; Equatorial to Alt-Az
IF coor EQ 1 THEN BEGIN 
equi = eq2obs(alt_val,az_val)
alt_val = equi[1]
az_val = equi[2]
ENDIF

; Galactic to Alt-Az
IF coor EQ 2 THEN BEGIN
gal = gal2obs(alt_val,az_val)
alt_val = gal[1]
az_val = gal[2]
ENDIF

print,alt_val,az_val

; TYPE SUB ROUTINES --------------------------------------------------

deltheta = FLOAT(deltheta)
segments = FLOAT(segments)
seg_size = (deltheta / segments)
y_start = alt_val - deltheta
x_start = az_val - deltheta

gauss_sb = fltarr(4)                        ; Gaussian Fit Vars
;gauss_db = fltarr(4,2)
;gauss_fb = fltarr(4)

gauss_order = 4;

; 'TYPE' = 1 - SINGLE BAND --------------------------------------------

IF type EQ 1 THEN BEGIN

sb_data=fltarr((2*segments+1),5)
;Data array
;Row 1 contains altitude values
;Row 2 contains azimuth values
;Row 3 contains move success values for debugging, 0 > fail, 1 > success
;Row 4 contains spec average
sb_shift = 0

;Setting up the go to points
FOR count = 0, (2*segments) DO BEGIN
sb_data[count,0]=(y_start+seg_size*count)
sb_data[count,1]=az_val
sb_data[count,4] = cover(sb_data[count,0],sb_data[count,1])
IF sb_data[count,4] NE 0 THEN BEGIN
print,'Error - Position of ALT = ',sb_data[count,0],' and AZ = ',sb_data[count,1],' are outside of dish range.'
ENDIF
ENDFOR

print,total(sb_data[*,4],1)

IF total(sb_data[*,4],1) GT 0 THEN GOTO, JUMP1


help, sb_data
print, sb_data

      ;   Moving to the positions and take data
FOR count = 0, (2*segments) DO BEGIN
temp_data = point_read(sb_data[count,0],sb_data[count,1],spectra,temp)
sb_data[count,2] = temp_data[0]
sb_data[count,3] = temp_data[1]
ENDFOR

; Gaussian Fit
;gauss_sb = GAUSSFIT(sb_data[*,0],sb_data[*,3],NTERMS=gauss_order)
;plot,sb_data[*,0],sb_data[*,3]
;sb_shift = gauss_sb[1]-alt
;print,'Mean is ',gauss_sb[1]
;print,'Mean Shift is ',sb_shift
;print,'Amplitude is ',gauss_sb[0]
;print,'Sigma is ',gauss_sb[2]
;print,'Background Shift is ', gauss_sb[3]

;gauss_res = gauss_sb
spec_sums = sb_data

ENDIF

;------------------------------------------------------------------------

JUMP1: print,'Function will exit'

END