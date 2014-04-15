;+
;
;NOTE: SOME OF THIS INFORMATION MAY BE OUT OF DATE.  PLEASE SEE
;DOCUMENTATION FOR ANALYZE.PRO FOR A FULLY UPDATED LIST OF KEYWORDS
;AND OPTIONS.
;
;
; NAME: errors
;
; PURPOSE: reads in data from SCANNER, performs a baseline and
; gaussian fit, and determines the offset in az and alt for each point.
;
; EXPLANATION: 
;
; CALLING SEQUENCE: errors,'directory',out
;
; INPUTS: directory - a string containing the name of a directory in
;                     which the SCANNER files are stored. The words
;                     SUN and MOON are used to identify these files,
;                     so this directory CANNOT contain any other files
;                     whose names contain SUN or MOON unless they are
;                     preceeded by a '.'
;
; OPTIONAL INPUTS:
;       scoop=# the number of points near the center to use for
;       fitting. 
;
; OPTIONAL INPUT KEYWORDS:
;                         /plot - plots the data (qhite) and the fitted
;                                 gaussian (red) for each pass
;
;                         /i - interactive mode.  After plotting each
;                              data file, the program stops and waits
;                              for user input.  Entering the number of
;                              one of the sub windows will add that
;                              data point to a kill file and it will
;                              not be used in the calculating the
;                              pointing offset.  This is by far the easiest
;                              way to eliminate obviously bad points.
;
;                         savename=string - saves the output structure
;                                           to user specified file.
;                                           Otherwise the default
;                                           path/errors.sav is used.
;
;                         /mixcor - returns constants with respect to
;                                   uncorected pointing, but shows the
;                                   plots with respect to the
;                                   corrected pointing
; OUTPUTS: out - a structure containing the following tags:
;
;           out.errors[nr,unit] - actual zero point minus expected position  
;           out.expected[nr,unit] - the expected alts and azs
;           out.moon[nr.unit] - 0 for the sun, 1 for the moon
;           out.reverse[nr,unit] - 0 for forward, 1 for reverse
;           out.kill[nr,unit] - 0 if the data will be used for
;                               pointing corrections, 1 for bad points
;                               which should be removed
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED - smartname, base_gauss
;
; REVISION HISTORY: written by Erik Shirokoff, 5/2001
;   13mar03: CH cosmetic changes to code to facilitate readint it
;
;-

pro errors,dir,out,i=i,silent=silent,plotit=plotit,verbose=verbose, $
   nobase = nobase, order = order, oldschool = oldschool, $
   savename = savename, usecor = usecor, mixcor = mixcor, $
   scoop = scoop, errors, expected, moon, reverse, kill

;CONSTANTS AND STUFF

verby=keyword_set(verbose)
if keyword_set(silent) ne 1 then i=1 else i=0

maxrms=.01 ;the bggst number of standard deviations away before killing points

;HANDLES MULTIPLE OR SINGLE DIR CASE
numdirs=n_elements(dir) 
if numdirs eq 1 then dir=[dir]
dirn=reform(dir)


nfiles=0L
for nr=0,numdirs-1 do begin

;GET FILENAMES IN THE DIRECTORY

    dirname=smartname('.',dir[nr])
    spawn,'/usr/bin/ls '+dirname,s
;print,'s: ',s
    sdex=where(stregex(s,'sun',/boolean) eq 1,sdk)
    mdex=where(stregex(s,'moon',/boolean) eq 1,mdk)
    if sdk then s1=s[sdex] 
    if mdk then s2=s[mdex]
    if (sdk ne 0  and mdk ne 0) then begin
        s=s[[sdex,mdex]] 
    endif else begin
        if sdk ne 0 then s=s[sdex]
        if mdk ne 0 then s=s[mdex]
    endelse



    nfiles=n_elements(s)+nfiles
    if keyword_set(sarr) then $
      sarr=[sarr,strarr(n_elements(s))+dirname+s] else $
       sarr=strarr(n_elements(s))+dirname+s
endfor

s=sarr
;print,s

if verby then print,nfiles

rmsarr=fltarr(nfiles,4)
errorarr=fltarr(nfiles,4)
expectedarr=fltarr(nfiles,4)
moonarr=fltarr(nfiles)
reversearr=fltarr(nfiles)
killfile=fltarr(nfiles,4)

;OUTER LOOP
for nr=0,nfiles-1 do begin
print,nr,'  '+s[nr]
;ANALYZE A FILE

if verby then print,s[nr]

;print,s[nr]

restore,s[nr],verbose=verby

;create temporary files for holding plotting stuff
;note the the dimensions may change later on if more than one
;head.size variable was in the requested data sets.
if nr eq 0 then begin
    if keyword_set(scoop) then begin
        bigsc=fltarr(nfiles,4,scoop)
        bigsp=fltarr(nfiles,4,scoop)
        bigslf=fltarr(nfiles,4,scoop)
    endif
    bigc=fltarr(nfiles,4,head.size)
    bigp=fltarr(nfiles,4,head.size)
    biglf=fltarr(nfiles,4,head.size)
    bigea=fltarr(nfiles,4,head.size)
endif

base_gauss,head,dat,fit,order=order,nobase=nobase,usecor=usecor, $
  oldschool = oldschool, scoop = scoop


errorarr[nr,0]=fit[0].cen_err
errorarr[nr,1]=fit[1].cen_err
errorarr[nr,2]=fit[2].cen_err
errorarr[nr,3]=fit[3].cen_err
moonarr[nr]=head.moon
reversearr[nr]=head.reverse
expectedarr[nr,0]=fit[0].expected
expectedarr[nr,1]=fit[1].expected
expectedarr[nr,2]=fit[2].expected
expectedarr[nr,3]=fit[3].expected
for nw=0,3 do rmsarr[nr,nw]=fit[nw].rms

if (keyword_set(plotit) or keyword_Set(i)) then begin

    !p.multi=[0,2,2]
    ;change of notation
    pow=fltarr(head.size,4)
    pow[*,0] = dat[0].pow[*,0]	;  Altitude, East
    pow[*,1] = dat[1].pow[*,0]	;  Altitude, West
    pow[*,2] = dat[0].pow[*,1]	;  Azimuth, East
    pow[*,3] = dat[1].pow[*,1]	;  Azimuth, West

    titlestr=strarr(4)
    titlestr[0]='East Altitude'
    titlestr[1]='West Altitude'
    titlestr[2]='East Azimuth'  
    titlestr[3]='West Azimuth'

    if head.reverse then titlestr[*]=titlestr[*]+' (reverse)'
;now lets plot things
;first calculate the coords again, since I'm foolish and didn't return
;them from base_gauss

coord = fltarr(4, head.size)
;usecor=0

if (keyword_set(usecor) or keyword_set(mixcor)) then begin 
;RETURN DIFFERENCE WRT CORRECTIONS...
        coord[0,*] = dat[0].coralt[*,0] ;  Altitude, East
        coord[1,*] = dat[1].coralt[*,0] ;  Altitude, West
        coord[2,*] = dat[0].coraz[*,1] ;  Azimuth, East
        coord[3,*] = dat[1].coraz[*,1] ;  Azimuth, West
endif else begin ; RETURN ABSOLUTE DIFFERENCES
        coord[0,*] = dat[0].unalt[*,0] ;  Altitude, East
        coord[1,*] = dat[1].unalt[*,0] ;  Altitude, West
        coord[2,*] = dat[0].unaz[*,1] ;  Azimuth, East
        coord[3,*] = dat[1].unaz[*,1] ;  Azimuath, West
endelse

;scoopy coordinates
if keyword_Set(scoop) then begin
scoopcoord=fltarr(4,scoop)
scooppow=fltarr(4,scoop)

scoopcoord[0,*] = fit[0].scoopcoord[*]  ;  Altitude, East
scoopcoord[1,*] = fit[1].scoopcoord[*]  ;  Altitude, West
scoopcoord[2,*] = fit[2].scoopcoord[*]   ;  Azimuth, East
scoopcoord[3,*] = fit[3].scoopcoord[*]   ;  Azimuath, West

scooppow[0,*] = fit[0].scooppow[*]  ;  Altitude, East
scooppow[1,*] = fit[1].scooppow[*]  ;  Altitude, West
scooppow[2,*] = fit[2].scooppow[*]   ;  Azimuth, East
scooppow[3,*] = fit[3].scooppow[*]   ;  Azimuath, West
endif

;NON SCOOPY
if keyword_set(scoop) eq 0 then begin
    for nra=0,3 do begin
    plot,coord[nra,*],pow[*,nra],/ys,/xs,xtitle=strn(nra)+' - ' +titlestr[nra]
    oplot,coord[nra,*],fit[nra].gaussfit+fit[nra].linfit,color=255
    expx=[1.,1.]*expectedarr[nr,nra]
    dexpy=(!y.crange[1]-!y.crange[0])*.1
    expy=[!y.crange[0]+dexpy,!y.crange[1]-dexpy]
    plots,expx,expy,color=16776960
;    print,expx,expy
    endfor

endif else begin
;SCOOPINESS
     for nra=0,3 do begin
    ;mm1=minmax(pow[*,nra])
    ;mm2=minmax(fit[nra].scoopfit+fit[nra].slinfit)
    ;mm=minmax([mm1,mm2])
    ;plot,fit[nra].slinfit
    plot,coord[nra,*],pow[*,nra],/ys,/xs, $
      xtitle = strn(nra)+' - ' +titlestr[nra] ;  ,yr=[mm[0],mm[1]]
    oplot,scoopcoord[nra,*],scooppow[nra,*],psym=4
    oplot,scoopcoord[nra,*],fit[nra].scoopfit+fit[nra].slinfit,color=255
    expx=[1.,1.]*expectedarr[nr,nra]
    dexpy=(!y.crange[1]-!y.crange[0])*.1
    expy=[!y.crange[0]+dexpy,!y.crange[1]-dexpy]
    plots,expx,expy,color=16776960
;    print,expx,expy
    endfor

    !p.multi=[0,1,1]
;coord[nra,*],fit[nra].gaussfit+fit[nra].linfit


endelse



print,'You will have a chance to approve all these fits later.'

;COPY THE THINGS WE WILL NEED TO DISPLAY IN ORDER TO PLOT LATER

pow=transpose(pow) ;sloppy, but easier than fixing it everywhere

;let's check the sizes of our arrays and make corrections
sizenow=n_elements(pow[0,*])
sizethen=n_elements(bigp[0,0,*])
if sizenow gt sizethen then begin ; remake arrays
;       rename the old ones
    abigc=bigc
    abigp=bigp
    abiglf=biglf
;       make some new ones
    bigc=fltarr(nfiles,4,sizenow)
    bigp=fltarr(nfiles,4,sizenow)
    biglf=fltarr(nfiles,4,sizenow)
;       transfer the info
    bigc[nr,*,0:sizenow-1]=abigc
    bigc[nr,*,sizenow-1:*]=bigc[nr,*,sizenow-1]
    bigp[nr,*,0:sizenow-1]=abigp
    bigp[nr,*,sizenow-1:*]=bigp[nr,*,sizenow-1]
    if keyword_Set(scoop) eq 0 then begin
        biglf[nr,*,0:sizenow-1]=abiglf
        biglf[nr,*,sizenow-1:*]=biglf[nr,*,sizenow-1]
    endif
endif




for nra=0,3 do begin
if keyword_Set(scoop) then begin
    bigsc[nr,nra,*]=scoopcoord[nra,*]
    bigsp[nr,nra,*]=scooppow[nra,*]
    bigslf[nr,nra,*]=fit[nra].scoopfit+fit[nra].slinfit
endif
bigea[nr,nra]=expectedarr[nr,nra]
bigc[nr,nra,0:n_elements(coord[nra,*])-1]=coord[nra,*]
;print,'line 252 in errors'
;help,coord,bigc
bigp[nr,nra,0:n_elements(pow[nra,*])-1]=pow[nra,*]
biglf[nr,nra,0:n_elements(pow[nra,*])-1]=fit[nra].gaussfit+fit[nra].linfit

;help,sizenow,sizethen
if sizenow le sizethen then begin

    a=bigc[nr,nra,sizenow-1]
    bigc[nr,nra,sizenow-1:*]=a
    a=bigp[nr,nra,sizenow-1]
    bigp[nr,nra,sizenow-1:*]=a
    if keyword_set(scoop) eq 0 then begin
        a=biglf[nr,nra,sizenow-1]
        biglf[nr,nra,sizenow-1:*]=a
    endif

endif

;help,bigp,pow,sizenow,sizethen

endfor



;    plot,dat.pow
;    plots,[1*head.size,1*head.size],[-10,10],lines=2
;    plots,[2*head.size,2*head.size],[-10,10],lines=2
;    plots,[3*head.size,3*head.size],[-10,10],lines=2
;    oplot,fit.gaussfit+fit.linfit,color=255
endif



endfor


for nr=0,nfiles-1 do begin
    print,nr

!p.multi=[0,2,2]
;NON SCOOPY
    if keyword_set(scoop) eq 0 then begin
        for nra=0,3 do begin
            print,'line 327 in errors.pro'
            ;help,bigc,bigp
            ;print,'totals',total(bigc),total(bigp)
            ;            mm=minmax(bigc[nr,nra,*])
            plot,bigc[nr,nra,*],bigp[nr,nra,*],/ys, $
              xtitle = strn(nra)+' - ' +titlestr[nra], /xs 
                  ;  xr=[mm[0]-3,mm[1]+3],/xs
            oplot,bigc[nr,nra,*],biglf[nr,nra,*],color=255
            expx=[1.,1.]*bigea[nr,nra]
            dexpy=(!y.crange[1]-!y.crange[0])*.1
            expy=[!y.crange[0]+dexpy,!y.crange[1]-dexpy]
            plots,expx,expy,color=16776960
            ;big rms auto removal
            if abs(rmsarr[nr,nra]) ge maxrms then begin
                killfile[nr,nra]=1
                plots,!x.crange,!y.crange,color=255
                plots,reverse(!x.crange),!y.crange,color=255
            endif
        endfor
        
    endif else begin
;SCOOPINESS
        for nra=0,3 do begin
                             ;mm1=minmax(pow[*,nra])
                             ;mm2=minmax(fit[nra].scoopfit+fit[nra].slinfit)
                             ;mm=minmax([mm1,mm2])
                             ;plot,fit[nra].slinfit
            plot,bigc[nr,nra,*],bigp[nr,nra,*],/ys, $
              xtitle = strn(nra)+' - ' +titlestr[nra], /xs 
                 ; ;/xs,  ,yr=[mm[0],mm[1]]

            ;help,bigc,bigp
            ;print,bigc

            oplot,bigsc[nr,nra,*],bigsp[nr,nra,*],psym=4
            oplot,bigsc[nr,nra,*],bigslf[nr,nra,*],color=255
            expx=[1.,1.]*bigea[nr,nra]
            dexpy=(!y.crange[1]-!y.crange[0])*.1
            expy=[!y.crange[0]+dexpy,!y.crange[1]-dexpy]
            plots,expx,expy,color=16776960
            ;print,expx,expy
            ;auto rms spike killing below
            if abs(rmsarr[nr,nra]) ge maxrms then begin
                killfile[nr,nra]=1
                plots,!x.crange,!y.crange,color=255
                plots,reverse(!x.crange),!y.crange,color=255
            endif
            ;auto test for one minima below
            nmin=monotonic(bigsp[nr,nra,*],/check)
            if nmin ne 1. then begin
                killfile[nr,nra]=1
                plots,!x.crange,!y.crange,color=255
                plots,reverse(!x.crange),!y.crange,color=255
            endif  
        endfor
    endelse
        
    !p.multi=[0,1,1]
    
    
;interactive mode - lets user add points to the kill file
    none=0
    while none eq 0 and keyword_set(i) eq 1 do begin
        print,' '
        print,'type 0 through 3 to kill the data in that sub window.'  
        print,'type u to undo all kills for this window'
        print,'type s to stop all these questions'
        print,'any other key to accept these fits.'
        key=get_kbrd(1)
        wait,.1
        zero=strcmp(key,'0')
        one=strcmp(key,'1')
        two=strcmp(key,'2')
        three=strcmp(key,'3')
        undo=strcmp(key,'u')
        besilent=strcmp(key,'s')
        print,key
        if (zero +one +two +three+undo) ge 1 then none=0 else none=1
        if zero then killfile[nr,0]=1
        if one then killfile[nr,1]=1
        if two then killfile[nr,2]=1
        if three then killfile[nr,3]=1
        if undo then killfile[nr,*]=0
        if (none eq 0) and (undo eq 0) and (besilent eq 0) then $
          print, 'Adding record '+strn(key)+' of data set '+strn(nr)+' to the kill file.  Any others?'
        if undo eq 1 then $
          print, 'All four of these sub windows have been removed from the kill file.'
        if besilent then begin
            i=0
            plotit=1
        endif
    endwhile
endfor 



;;OKAY, DONE PLOTTING. NOW PACKAGE AND SAVE THE RESULTS


out={errors:errorarr,$
     expected:expectedarr,$
     moon:moonarr,$
     reverse:reversearr,$
     kill:killfile, $
     rms:rmsarr}

if n_params() ge 3 then begin
    errors=out.errors
    expected=out.expected
    moon=out.moon
    reverse=out.reverse
    kill=out.kill
endif


dirname=smartname('.',dir[0])

if keyword_set(savename) then $
  name1=smartname(dirname,savename,'.sav') else $
   name1=smartname(dirname,'errors','.sav')

save,filename=name1,out






end

















