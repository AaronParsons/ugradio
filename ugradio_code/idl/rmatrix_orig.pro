pro rmatrix, longpole, latpole, rtot

;+
;NAME: RMATRIX
;
;PURPOSE: this defines the rotation matrix for a new coordinate system
;         whose pole is centered on the Galactic coordinates
;         (l,b)=(longpole, latpole) [or the equqatorial coordinates
;         (ra,dec)=(longpole, latpole)].
;
;CALLING SEQUENCE:: 
;       rmatrix, longpole, latpole, rtot
;
;INPUTS
;LONGPOLE, the Galactic longitude or equatorial RA of the pole of the new system
;LATPOLE, the Galactic latitude or equatorial DEC of the pole of the new system

;OUTPUTS: 
;RTOT, the rotation matrix that converts between the original and new
;systems.

;NOTES: in the code, the angles phi, theta, and chi are as defined in
;       Goldstein's CLASSICAL MECHANICS; the relevant pages are
;       reproduced in the handout ay120coord.ps . Specifically:
;               longpole: phi = 90 deg plus the longitude of the new pole
;               latpole: theta = 90 - the latitude of the new pole
;               chi 'turns around' th new pole; we assume chi=0
;-

rtot = fltarr(3,3)
r1 = rtot
r2 = rtot
r3 = rtot
r4 = rtot
phi = !dtor * (90. + longpole)
theta = !dtor * (90. - latpole)
chi = !dtor * 90.

;the indiceds are in (row, column) order!!!!!
r1( 0, 0) = cos( phi)
r1( 1, 1) = r1( 0, 0)
r1( 0, 1) = sin( phi)
r1( 1, 0) = -r1( 0, 1)
r1( 2, 2) = 1.0

r2( 1, 1) = cos( theta)
r2( 2, 2) = r2( 1, 1)
r2( 1, 2) = sin( theta)
r2( 2, 1) = -r2( 1, 2)
r2( 0, 0) = 1.0


r3( 0, 0) = cos( chi)
r3( 1, 1) = r3( 0, 0)
r3( 0, 1) = sin( chi)
r3( 1, 0) = -r3( 0, 1)
r3( 2, 2) = 1.0

r4( 0, 0) = 1.
r4( 1, 1) = -1.
r4( 2, 2) = 1.

rtot = r3 # (r2 # r1)
;print, rtot

return
end
