pro make_lds_cube, lcen, bcen, dl, db, VRANGE=vrange, FILENAME=filenm
;+
; NAME:
;       MAKE_LDS_CUBE
;
; PURPOSE:
;       To make an (l,b,v) cube of a subset of the Leiden/Dwingeloo Survey 
;       of Galactic neutral hydrogen.
;
; CALLING SEQUENCE:
;       make_lds_cube, lcen, bcen, dl, db [, VRANGE=[min,max]] 
;                      [, FILENAME=string]
;
; INPUTS:
;       lcen - central Galactic longitude of cube [degrees]
;       bcen - central Galactic latitude of cube [degrees]
;       dl - the half-width of the cube in the longitude direction[degrees]
;       db - the half-width of the cube in the latitude direction [degrees]
;
; KEYWORD PARAMETERS:
;       VRANGE = 2-element vector with minimum and maximum VLSR velocities 
;                [km/s] in the cube.  Default is to use entire velocity
;                range.
;       FILENAME = name of the output FITS file.  Default is to write to a
;                  file named lds_cube.fits in the current working directory.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       A FITS cube is written.
;
; PROCEDURES CALLED:
;       TABINV, FITS_ADD_AXIS_PAR
;
; EXAMPLE:
;       IDL> make_lds_cube, 90, 0, 30, 10, VRANGE=[-100,100]
;
; MODIFICATION HISTORY:
;       15 Sep 2004  Written by Tim Robishaw, Berkeley
;-

LDSDatapath = '/home/robishaw/lds/'

vlsr = 1.0305*(findgen(849)-445)
l = 0.5*lindgen(720)
b = 0.5*lindgen(361)-90.

if (N_elements(VRANGE) ne 2) then vrange = minmax(vlsr)
lrange = lcen + dl*[-1,1]
brange = bcen + db*[-1,1]

tabinv, vlsr, vrange, vindx, /FAST
tabinv, l, lrange, lindx, /FAST
tabinv, b, brange, bindx, /FAST

vindx = round(vindx)
lindx = round(lindx)
bindx = round(bindx)

nl = lindx[1]-lindx[0]+1
nb = bindx[1]-bindx[0]+1
nv = vindx[1]-vindx[0]+1

cube = dblarr(nl,nb,nv)

for i = lindx[0], lindx[1] do begin

    lfile = string(l[i]*10,format='(I4.4)')

    ; GET THE SPECTRUM.
    bv = transpose(readfits(LDSDataPath+'l'+lfile+'.fit',/silent))

    cube[i-lindx[0],*,*] = bv[bindx[0]:bindx[1],vindx[0]:vindx[1]]

endfor

; MAKE THE HEADER FOR THIS CUBE AND ADD THE AXIS PARAMETERS...
mkhdr, hdr, cube
fits_add_axis_par, l[lindx[0]:lindx[1]], hdr, 1, CTYPE='GLAT-CAR'
fits_add_axis_par, b[bindx[0]:bindx[1]], hdr, 2, CTYPE='GLON-CAR'
fits_add_axis_par, vlsr[vindx[0]:vindx[1]], hdr, 3, CTYPE='VELO-LSR'

if (N_elements(filenm) eq 0) then filenm = '~/lds_cube.fits'

; WRITE THE FITS FILE...
writefits, filenm, cube, hdr

end; make_lds_cube
