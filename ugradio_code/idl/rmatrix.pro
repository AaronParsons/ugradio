pro rmatrix, longpole, latpole, rtot, longoffset=longoffset, $
             noleft=noleft

;+
;NAME: RMATRIX
;
;PURPOSE: this defines the rotation matrix for a new coordinate system
;         whose pole is centered on the Galactic coordinates
;         (l,b)=(longpole, latpole) [or the equqatorial coordinates
;         (ra,dec)=(longpole, latpole)].
;
;CALLING SEQUENCE:: 
;       rmatrix, longpole, latpole, rtot, [longoffset=longoffset]
;
;INPUTS
;LONGPOLE, the old system's longitude of the new system's pole, DEGREES 
;LATPOLE, the old system's latitude of the new system's pole, DEGREES 
;
;OPTIONAL INPUT;
;LONGOFFSET, sets the zero point of the output longitude system, DEGREES
;NOLEFT: Dewfault is for output coordinates to be left-handed. This is
;the normal astronomical convention. Set NOLEFT=1 for right-handed output.
;
;OUTPUTS: 
;RTOT, the rotation matrix that converts between the original and new
;systems.

;NOTES: 
;(1)    in the code, the angles phi, theta, and chi are as defined in
;       Goldstein's CLASSICAL MECHANICS; the relevant pages are
;       reproduced in the handout ay120coord.ps . Specifically:
;               longpole: phi = 90 deg plus the longitude of the new pole
;               latpole: theta = 90 - the latitude of the new pole
;               chi 'turns around' th new pole; we assume chi=0
;
;(2) The zero point of the new coordinate system's longitude will
;occur at the line of nodes. To define a different origin, use
;LONGOFFSET. For example, if you were using this procedure to convert
;between Equatorial and Galactic
;coordinates, you need...
;        the right ascension of the Galactic pole, 192.85948 deg
;        the declination of the Galactic pole, 27.128302 deg
;        the longitude offset, 57.068063831052626255768d0 deg
;
;(3) rtot is defined as COLUMN-MAJOR, which is NOT the IDL
;convention. When used in sph_coord_conv it is used as column major, so the
;matrix multiplication is done with single pound signs. This enables us to
;use arrays of input variables in sph_coord_conv.  -

loffset=0.
if n_elements( longoffset) ne 0 then loffset=longoffset

rtot = fltarr(3,3)
r1 = rtot
r2 = rtot
r3 = rtot
r4 = rtot
phi = !dtor * (-90. + longpole)
;phi = !dtor * (0. + longpole)
theta = !dtor * (90. - latpole)
;chi = !dtor * 90.
chi = !dtor * (90. + loffset)

;chi = !dtor * 0.

;the indiceds are in (row, column) order!!!!!
r1( 0, 0) = cos( phi)
r1( 1, 1) = r1( 0, 0)
r1( 0, 1) = sin( phi)
r1( 1, 0) = -r1( 0, 1)
r1( 2, 2) = 1.0

r2( 1, 1) = cos( theta)
r2( 2, 2) = r2( 1, 1)
;r2( 1, 2) = sin( theta)
r2( 1, 2) = -sin( theta)
r2( 2, 1) = -r2( 1, 2)
r2( 0, 0) = 1.0


r3( 0, 0) = cos( chi)
r3( 1, 1) = r3( 0, 0)
r3( 0, 1) = sin( chi)
r3( 1, 0) = -r3( 0, 1)
r3( 2, 2) = 1.0

r4( 0, 0) = 1.
if keyword_set( noleft) then r4( 1, 1) = 1. else r4( 1, 1) = -1.
r4( 2, 2) = 1

rtot = r3 # (r2 # r1)

;print, rtot
;print, phi, theta, chi
;print, r1
;print, r2
;print, r3

return
end
