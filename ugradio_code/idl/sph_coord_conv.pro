pro sph_coord_conv, longin, latin, rtot, longout, latout, inverse=inverse
;+
; NAME: sph_coord_conv
;
; PURPOSE: convert long,lat in one sph system to another using rotation
;          matrix rtot.
;
; CALLING SEQUENCE:
;sph_coord_conv, longin, latin, rtot, longout, latout, inverse=inverse
;        This routine is fully vectorized
;       All angles are in DEGREES
;
; INPUTS:
;LONGIN, a position's longitude in the original coord system 
;LATIN, a position's latitude in the original coord system 
;RTOT, the rotation matrix (from rmatrix.pro)
;
; KEYWORD PARAMETERS:
;INVERSE, use inverrse of rot (to go 'backwards')
;
; OUTPUTS:
;LONGOUT, a position's longitude in the new coord system 
;LATOUT, a position's latitude in the new coord system 
;
; EXAMPLE:
; You want to define new long and lat relative to a coord system whose pole
; lies at Galactic coords (longpole, latpole). 
;
;FIRST, get the rotation matrix rtot:
;       rmatrix, longpole, latpole, rtot, [longoffset=longoffset]
;
;NEXT: you have a position in Galactic coords (ell, bee) and you want the
;      longitude and latitude in the new system:
;       sph_coord_conv, ell, bee, rtot, longout, latout
;
;OR: you want to go 'backwaards': given then position in the new coord
;    systtem, what are (ell, bee)?
;       sph_coord_conv, longout, latout, rtot, ell, bee, /inverse
;
; MODIFICATION HISTORY:
;6 feb 2008 by carl h.
;-

resu = size( longin)
xin = fltarr( 3, resu(resu( 0)+2))
xout = xin
angout = fltarr( 2, resu( 1))
xin( 0, *) = cos(!dtor * latin) * cos(!dtor * longin)
xin( 1, *) = cos(!dtor * latin) * sin(!dtor * longin)
xin( 2, *) = sin(!dtor * latin)

if keyword_set( inverse) then $
xout = transpose( rtot) # xin $ 
else xout= rtot # xin 

longout = reform( !radeg * atan(xout( 1, *), xout( 0, *)))
latout = reform( !radeg * asin(xout( 2, *)))

if n_elements( longout) eq 1 then longout=longout[0]
if n_elements( latout) eq 1 then latout=latout[0]

return
end
