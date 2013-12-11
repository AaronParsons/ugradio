pro pointsinside, x, y, xcurve, ycurve, indx
;POINTSINSIDE: find indices of points inside a known curve.

;+
;NAME:
;	POINTSINSIDE
;
;PURPOSE:
;	Find the indices of points inside a defined curve that has been
;plotted on the terminal window.
;
;CALLING SEQUENCE:
;	POINTSINSIDE, x, y, xcurve, ycurve, indx
;
;INPUTS:
;	X: the array of x-values of the points on the plot.
;	Y: the array of y-values of the points on the plot.
;	XCURVE: the array of x-values of the points that define the curve.
;	YCURVE: the array of y-values of the points that define the curve.
;
;OUTPUTS:
;	INDX: the indices of x and y that lie within the curve defined
;	by XCURVE, YCURVE.
;indx is equivalent to what you get with the "where" function.
;
;RESTRICTIONS:
;	You cannot use this on any plot except for the most recently
;defined plot. That is, if you made a plot (nr 1) and then another one
;(nr 2), you can use it on nr 2 but not on nr 1.
;
;EXAMPLE:
;
;	You made a contour plot and want to find all points within the 
;contour. FIRST, get the vertices of the contour plot:
;
;CONTOUR, delchisq_n, dela0_v, dela1_v, levels=[2.3], $  
;        xtit='!4d!Xa!D0!N', ytit= '!4d!Xa!D1!N'    , $
;        xra = [-1.5,1.5], /xsty, yra=[-0.6,0.6], /ysty  $
;        , path_xy=path_xy, /path_data_coords, path_info=path_info 
;
;	NEXT, get rid of the points in path_xy that are garbage at the 
;beginning:
;
;xypath = fltarr( (path_info.n)[1], (path_info.n)[1])
;for nr=0,1 do xypath[ nr,*] = path_xy[ nr, (path_info.offset)[1]:*]    
;
;	FINALLY, call this routine:
;
;POINTSINSIDE, xpoints, ypoints, xypath[0,*], xypath[1,*], INDX
;
;	after all this, INDX contains the indices of (XPOINTS, YPOINSTS) 
;that lie inside the contour.
;
;RELATED PROCEDURES:
;	my GRAPHSELECT; IDL'S DEFROI
;HISTORY:
;	Written by Carl Heiles. 12 Sep 1998.
;-

;FIRST, USE DEFROI TO DEFINE THE POINTS OF INTEREST ON THE PLOT...

xycurv= convert_coord( xcurve, ycurve, /data, /to_device)
result = polyfillv( xycurv[ 0,*], xycurv[ 1,*], !d.x_size, !d.y_size)
;result = defroi(!d.x_size, !d.y_size)

;MAKE A FAKE IMAGE THAT EQUALS ZERO EVERYWHERE BUT IN THE SELECTED AREA...
;TESTIMG IS NONZERO IN THE AREA; THE AREA IS DEFINED IN **DEVICE** COORDS.
testimg = bytarr(!d.x_size, !d.y_size)
testimg[result] = 1b

;NOW CONVERT THE DATA POINTS, WHICH ARE OF COURSE IN **DATA** COORDINATES,
;	INTO DATA POINTS DEFINED IN **DEVICE** COORDINATES.
xyconv = convert_coord(x,y,/data,/to_device)
xconv = xyconv[0,*]
yconv = xyconv[1,*]

;THEN SELECT THOSE POINTS THAT LIE WITHIN THE SELECTED REGION.
indx = where( testimg[xconv, yconv] ne 0b)

return
end
