;+
; NAME: base_gauss
;
; PURPOSE: takes drift scan data structures from SCANNER and returns
; the offset in alt and az for both dishes and the expected value of
; the alt and az.
;
; EXPLANATION: 
;
; CALLING SEQUENCE: base_gauss,head,dat,fit
;
; INPUTS: head, dat - structures returned by SCANNER
;
; OPTIONAL INPUTS:
;       scoop - the number of points near the center to use for the
;               gaussian fit.  If set equal to 1, then the default
;               value will be used.
;
; OPTIONAL INPUT KEYWORDS: order=# - order of polynomial to use for
;                                    for baseline removal 
;                          /nobase - does not attempt baseline fitting
;
; OUTPUTS: fit - a structure containing the following tags:
;                fit[count].linfit[*]  = baseline fit
;                fit[count].gaussfit[*] = gaussian fit
;                fit[count].rms = RMS of gaussian fit
;                fit[count].zro = zero position of gaussian
;                fit[count].hgt = height of gaussian
;                fit[count].cen = center of gaussian
;                fit[count].wid = width of gaussian
;                fit[count].left = 
;                fit[count].right = 
;                fit[count].exps[*] =
;                fit[count].cen_err = offset from center (pointing error)
;                fit[count].expected= expected center coordinates 
;
;                Count is the dish and coordinate, according to the
;                following scheme: 0 - altitude east dish
;                                  1 - altitude west dish
;                                  2 - azimuth east
;                                  3 - azimuth west

;
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED
;
; REVISION HISTORY:
;
; this program removes a baseline and then applies a gaussian fit to
; the data
;
;This is a modified version of remove_n_fit, part of Curtis Frank's ptcorr
;series.
;By ES, 5/2001
;modified to include the scoop option and to iterate the gaussian fit,
;ES 7/2001
;
;-

pro base_gauss2,head,dat,fit,order=order,nobase=nobase,plot=plot,usecor=usecor,oldschool=oldschool,scoop=scoop,maxrms=maxrms

;CONSTANTS AND OPTIONS STUFF
if keyword_set(maxrms) eq 0 then maxrms=.1
nocorrect=keyword_set(nobase)

niter=100 ; max number of iterations to make gfit go through. smaller is faster but may miss some fits.

if keyword_set(scoop) then begin
    if scoop eq 1 then scoop=5 else scoop=fix(scoop); default
endif else begin
    scoop=0
endelse

if keyword_Set(order) eq 0 then order=1

;set left and right linear fitted point limits
if keyword_set(nocorrect) eq 0 then begin
    lmin=1
    lmax=fix(head.size/4.)
    rmin=1
    rmax=fix(head.size/4.)
endif else begin ; or set the limits to the same number for less loops
    lmin=1
    lmax=1
    rmin=1
    rmax=1
endelse


powdirneg=1 ;power increases negatively


;  Restore that data file!
;restore,fname
;restore, params.fnames[name_num]

;help,/structure,head



;  Define resultant data structure

if keyword_set(scoop) then scoopfit=fltarr(Scoop) else scoopfit=0
if keyword_set(scoop) then scoopcoord=fltarr(Scoop) else scoopcoord=0
if keyword_set(scoop) then scooppow=fltarr(Scoop) else scooppow=0
if keyword_set(scoop) then slinfit=fltarr(Scoop) else slinfit=0

fit = replicate	({linfit:  make_array(head.size, /float), $
                  gaussfit:make_array(head.size, /float), $
                  rms:     99999999.9, $
                  zro:     0.0, $
                  hgt:     0.0, $
                  cen:     0.0, $
                  wid:     0.0, $
                  left:    0, $
                  right:   0, $
                  exps:    make_array(order + 1, /float), $
                  cen_err: 0.0, $
                  expected: 0.0, $
                  scoop:scoop, $  ; size of chunk actually fitted 
                  scoopfit:scoopfit, $
                  scooppow:scooppow, $
                  scoopcoord:scoopcoord, $
                  slinfit:slinfit, $
                  scoopoff:0}, 4) ; offset of that chunk

;help,/structure,fit

;  Define midpoint of the array and other stuff
look = -1
wd0 = 2.0
lin_fit = make_array(4, head.size, value=0.0D)
pow = make_array(4, head.size, /float)
coord = make_array(4, head.size, /float)
exps = make_array(4, order + 1, /float)
    
;  Unload power data and coordinate data from dat
;  structure into something more usuable
pow[0,*] = dat[0].pow[*,0]	;  Altitude, East
pow[1,*] = dat[1].pow[*,0]	;  Altitude, West
pow[2,*] = dat[0].pow[*,1]	;  Azimuth, East
pow[3,*] = dat[1].pow[*,1]	;  Azimuth, West

if keyword_set(usecor) then begin ;RETURN DIFFERENCE WRT CORRECTIONS
    if head.nocorrect eq 0 then begin
        coord[0,*] = dat[0].unalt[*,0] ;  Altitude, East
        coord[1,*] = dat[1].unalt[*,0] ;  Altitude, West
        coord[2,*] = dat[0].unaz[*,1] ;  Azimuth, East
        coord[3,*] = dat[1].unaz[*,1] ;  Azimuth, West
    endif else begin
        coord[0,*] = dat[0].coralt[*,0] ;  Altitude, East
        coord[1,*] = dat[1].coralt[*,0] ;  Altitude, West
        coord[2,*] = dat[0].coraz[*,1] ;  Azimuth, East
        coord[3,*] = dat[1].coraz[*,1] ;  Azimuth, West
    endelse
endif else begin ; RETURN ABSOLUTE DIFFERENCES
        coord[0,*] = dat[0].unalt[*,0] ;  Altitude, East
        coord[1,*] = dat[1].unalt[*,0] ;  Altitude, West
        coord[2,*] = dat[0].unaz[*,1] ;  Azimuth, East
        coord[3,*] = dat[1].unaz[*,1] ;  Azimuath, West
endelse

;GET THE SOURCE ALT AND AZ, OR IF THAT ISN'T POSSIBLE BECAUSE ITS AN
;OLD DATA SET, APPROXIMATE IT USING THE CENTER POSITION
sourceaa=fltarr(4)
if keyword_set(oldschool) then begin
    sourceaa[0]=coord[0, head.size/2]    
    sourceaa[1]=coord[1, head.size/2]
    sourceaa[2]=coord[2, head.size/2]
    sourceaa[3]=coord[3, head.size/2]
endif else begin
    sourceaa[0]=head.s_alt
    sourceaa[1]=head.s_alt
    sourceaa[2]=head.s_az
    sourceaa[3]=head.s_az
endelse

;SPIKE REMOVAL

;    sourceaa[nr]=monotonic(pow[nr,*],removed)
;    pow[nr]=monotonic(por[nr,*]


;  Set values of left and right maxes and mins for no baseline
;  fitting.  Because the params structure isn't updated for theparams.l_max + params.r_max
;  base widget in the procedure, I don't worry about changing
;  these.  Also create other needed arrays for baseline removal
;if NOT(params.remove_flag) then begin
;    lmin = 0
;    params.l_max = 0
;    params.r_min = 0
;    params.r_max = 0
;endif

for left = lmin, lmax do begin
    for right = lmin, rmax do begin
        if not(keyword_set(nocorrect)) then begin
            x = make_array(left + right, /float)
            y = make_array(left + right, /float)
        endif

        for count = 0, 3 do begin
            if not(keyword_set(nocorrect)) then begin ;  Make baseline fit function or set to zero.
                for numcount = 0, left - 1 do begin
                    x[numcount] = coord[count, numcount]
                    y[numcount] = pow[count, numcount]
                endfor
                
                for numcount = left + right - 1, left, -1 do begin
                    x[numcount] = coord[count, head.size - left - right + numcount]
                    y[numcount] = pow[count, head.size - left - right + numcount]
                endfor
                
                                ;  Adjust the order of the fit to take
                                ;  into account the number of points
                                ;  available to fit.
                if (left + right) GE order + 1 then $
                  order = order $
                else $
                  order = left + right - 1
                
                exps[count, 0:order] = svdfit(x, y, order + 1)
                
                                ;  Compose the fit function without
                                ;  the offset term.
                lin_fit[*,*] = 0.0D
                for numcount = 0, order do begin
                  lin_fit[count,*] = lin_fit[count, *] + exps[count, numcount] * coord[count, *] ^ numcount
              endfor
                
            endif else  lin_fit[*,*] = 0.0  ;  or set to zero

                                ;  Determine where the max/min value
                                ;  is.  This assumes that the most
                                ;  negative or positive value in the
                                ;  data corresponds to the center of
                                ;  the scan.
            if powdirneg then $
              trash = max(-1.0 * (pow[count,*] - lin_fit[count, *]), pos) $
            else $
              trash = max(pow[count,*] - lin_fit[count, *], pos)
                                ;  Fit each direction (east alt, west
                                ;  alt, east az, west az) with a Gaussian.  
            if powdirneg then $
              trash = min(-1.0 * (pow[count,*] - lin_fit[count, *]), postop) $
            else $
              trash = min(pow[count,*] - lin_fit[count, *], postop)



;********8
;NONSCOOPY STUFF HERE

;if keyword_Set(scoop) eq 0 then begin

;LET'S MAKE A FEW STARTING ESTIMATES for the gaussians
            tempzro=pow[count,postop]-lin_fit[count,postop]
            temphgt=pow[count,pos]-tempzro-lin_fit[count,pos]
            tempcen=coord[count,pos]
            mm=minmax(coord[count,*])
            tempwid=(mm[1]-mm[0])/2.
            
;NOW DO THE FITS
if keyword_set(scoop) eq 0 then begin
    flag=0
    nr=0
    temprms=-1000
    oncemore=0
    while flag eq 0 do begin
        if oncemore eq 1 then flag=1
        prevrms=temprms
        gfit2, look, coord[count,*],pow[count,*]-lin_fit[count,*],tempzro,temphgt,tempcen,tempwid,tempfit, temprms, tempzro, temphgt, tempcen, tempwid,rc=rc,/silent
;print,'tempwid',tempwid
                                ;print,'l262 base_gauss2',temprms
        if temprms le maxrms then begin
            if temprms eq prevrms then flag=1
            if rc eq 0 then oncemore=1
        endif
        nr=nr+1
        if nr ge niter then flag=1
    endwhile
    
;           gfit, look, coord[count, *], pow[count, *] - lin_fit[count, *], $ ;  x and y data arrays
;              pow[count, 0], pow[count, pos] - pow[count, 0], coord[count, pos], wd0, $
;              tempfit, temprms, tempzro, temphgt, tempcen, tempwid
                                ;  Compare fit RMS with previous RMS
                                ;  and select fit with the smallest
                                ;  RMS and with a height of the same
                                ;  sign as indicated by powdirneg
    do_it = 0
    if powdirneg then begin     ;  Power increases negatively
        if temphgt[0] LT 0.0 then do_it = 1
    endif else begin            ;  Power increases positively
        if temphgt[0] GT 0.0 then do_it = 1
    endelse
    
    if temprms LT fit[count].rms AND do_it then begin
        fit[count].linfit[*] = lin_fit[count, *]
        fit[count].gaussfit[*] = tempfit[*]
        fit[count].rms = temprms[0]
        fit[count].zro = tempzro[0]
        fit[count].hgt = temphgt[0]
        fit[count].cen = tempcen[0]
        fit[count].wid = tempwid[0]
        fit[count].left = left
        fit[count].right = right
        fit[count].exps[*] = exps[count,*]
        fit[count].cen_err = fit[count].cen - sourceaa[count]
        fit[count].expected= sourceaa[count]
    endif
    
endif

;*******
;SCOOPINESS BEGINS HERE
       if keyword_set(scoop) then begin

;SCOOPINESS

           smin=pos-floor(scoop/2.)
           smax=pos+floor(scoop/2.)
           if smin le 0 then begin
               smin=0
               smax=smin+scoop-1
           endif
           if smax ge head.size-1 then begin
               smax=head.size-1
               smin=smax-scoop+1
           endif

           if floor(scoop/2.)+floor(scoop/2.) eq scoop then $
             smax=smax-1

;           help,smin,smax,scoop

           ;print,'line 296 in base_gauss2'
           ;help,coord
           ;print,'smin,smax',smin,smax

           scoopcoord=coord[count,smin:smax]
           scoopoff=smin
           scooppow=pow[count,smin:smax]
           scooppow=reform(scooppow)
           slin_fit=lin_fit[count,smin:smax]
        
;print,count
;plot,coord[count,*],pow[count,*]
;oplot,scoopcoord,scooppow,color=255
;r=get_kbrd(1)

;LET'S MAKE A FEW STARTING ESTIMATES for the gaussians
;LET'S MAKE A FEW STARTING ESTIMATES for the gaussians


  if powdirneg then $
              trash = max(-1.0 * (scooppow - slin_fit), spos) $
            else $
              trash = max(scooppow - slin_fit, spos)
                                ;  Fit each direction (east alt, west
                                ;  alt, east az, west az) with a Gaussian.  
            if powdirneg then $
              trash = min(-1.0 * (scooppow - lin_fit[count, *]), spostop) $
            else $
              trash = min(scooppow - slin_fit, spostop)




;HERES THE ORINGIAL FITTING ROUTINE           
;NOW DO THE FITS

            ;help,scoopcoord,slin_fit,scoop
            flag=0
            ns=0
            temprms=1.
            oncemore=0
           while flag eq 0  do begin
               if oncemore eq 1 then flag=1
               prevrms=temprms
               gfit2, look, scoopcoord,scooppow-slin_fit,tempzro,temphgt,tempcen,tempwid,tempfit, temprms, tempzro, temphgt, tempcen, tempwid,rc=rc,/silent
               if temprms le maxrms then begin
                   if temprms eq prevrms then flag=1
                   if rc eq 0 then oncemore=1
               endif
               ;print,'line 374 basegauss2,count,XSRC,temprms',count,rc,temprms
               ns=ns+1
               if ns ge niter then flag=1
           endwhile


;nterms=min(scoop-1,six)
;scoopfit=gaussfit(scoopcoord,scooppow-slin_fit,coefs,nterms=3)

;           print,tempzro,temphgt,tempwid
           
;           gfit, look, coord[count, *], pow[count, *] - lin_fit[count, *], $ ;  x and y data arrays
;              pow[count, 0], pow[count, pos] - pow[count, 0], coord[count, pos], wd0, $
;              tempfit, temprms, tempzro, temphgt, tempcen, tempwid
                                ;  Compare fit RMS with previous RMS
                                ;  and select fit with the smallest
                                ;  RMS and with a height of the same
                                ;  sign as indicated by powdirneg
           do_it = 0
           if powdirneg then begin ;  Power increases negatively
               if temphgt[0] LT 0.0 then do_it = 1
           endif else begin     ;  Power increases positively
               if temphgt[0] GT 0.0 then do_it = 1
           endelse
           ;help,scoop,tempfit
           if temprms LT fit[count].rms AND do_it then begin
               fit[count].linfit = lin_fit[count, *]
               fit[count].gaussfit = fltarr(head.size)
               fit[count].rms = temprms[0]
               fit[count].zro = tempzro[0]
               fit[count].hgt = temphgt[0]
               fit[count].cen = tempcen[0]
               fit[count].wid = tempwid[0]
               fit[count].left = left
               fit[count].right = right
               fit[count].exps[*] = exps[count,*]
               fit[count].cen_err = fit[count].cen - sourceaa[count]
               fit[count].expected= sourceaa[count] 
               fit[count].scoop=scoop
               fit[count].scoopfit=tempfit
               fit[count].scoopcoord=scoopcoord
               fit[count].scoopoff=scoopoff
               fit[count].scooppow=scooppow
               fit[count].slinfit=slin_fit

           endif
       endif
   endfor
endfor
endfor








end











