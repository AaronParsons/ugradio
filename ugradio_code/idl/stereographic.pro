pro stereographic, long, lat, x, y, southpole=southpole, $
        inverse=inverse, gnomic=gnomic, radius=radius     ;, lefthand=lefthand, 

;+
; NAME: STEREOGRAPHIC PURPOSE: Convert long and lat to X,Y, or vice-versa,
; using a stereographic projection. Also does a Gnomic projection.
;
; EXPLANATION:
;       The output X and Y coordinates are normalized so that latitude 0
;       (the equator) lies at radius R=1 [R = sqrt(x^2 + y^2)] The pole has
;            R=0 and lies at lat=90.
;       Output points can be centered on the north pole or south pole.
;
; CALLING SEQUENCE:
;       STEREOGRAPHIC, long, lat, X, Y, $
;        [ /SOUTHPOLE ], [ /INVERSE ], [ /GNOMIC]
;
; INPUTS:
;       long - longitude - scalar or vector, in degrees
;       lat - latitude - same number of elements as long, in degrees
;
; OUTPUTS:
;       X - X coordinate, same number of elements as long.   X is normalized
;           so that 90 deg away from the pole occurs at radius = 1
;       Y - Y coordinate, same number of elements as long.  Y is normalized
;           like X
;
; KEYWORDS:
;       /SOUTHPOLE - Keyword to indicate that the plot is to be centered on
;                    the south pole instead of the north pole.
;       /INVERSE - go from X,Y to long, lat
;       /GNOMIC - do Gnomic instead of Stereographic projection
;-

if keyword_set( lefthand) then xmult=-1. else xmult=1.

if keyword_set( gnomic) then begin
   two=1. 
   half=1.
endif else begin
   two=2.
   half=0.5
endelse

if keyword_set(inverse) then begin
   radius= sqrt( x^2 + y^2)

   if keyword_set( southpole) then begin
      lat= -90.+ two*!radeg*atan(radius)
      long=!radeg*atan( y, -x* xmult)  
           endif else begin
         lat= 90.- two*!radeg*atan(radius)
         long=!radeg*atan( y, x* xmult) 
      endelse
      return
 endif


if keyword_set( southpole) then begin
   radius = tan( !dtor* half* (-90.-lat))
   x= xmult* radius* cos(!dtor* long)
   y= -radius* sin(!dtor* long)

endif else begin
   radius = tan( !dtor* half* (90.-lat))
   x= xmult* radius* cos(!dtor* long)
   y= radius* sin(!dtor* long)
endelse

;stop
return
end

