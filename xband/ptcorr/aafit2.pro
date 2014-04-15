;+
; NAME: aafit
;
; PURPOSE: performs least squares fitting for the dial and flop
; constants used in interferometer pointing corrections.  Replaces
; altfit and azfit.
;
; EXPLANATION: generally used as a subroutine of POINTFIT
;
; CALLING SEQUENCE: azfit,delta,alt,moon,reverse,kill,dial,skew,sigma
;
; INPUTS: key - the moon/sun/forward/reverse numeric identifier
;         delta - array of the object center minus the dial reading
;         alt - array of azimuth in degrees
;         reverse - an array which is 1 whenever data was taken in
;                   reverse mode and 0 when in forward mode
;         moon - an array which is 1 whenever the object was the moon
;                and zero when it was the sun
;         kill - an array which is 1 whenever a data point should NOT
;                be used for fitting, and which is 0 otherwise
; OPTIONAL INPUT KEYWORDS:
;
; OUTPUTS: dial - the constant offset correction
;          flop - the sinusoidal multiplier  
;          sigma - an array of fit sigmas: [dial sigma,flop sigma]
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED: 
;       KEYKILL - groups data points by category
;       FITGEN - function to generate the s arrays used in fitting.
;                Edit fitgen.pro if you want to fit to another function.
;
; REVISION HISTORY: written by Erik Shirokoff, 5/2001
;-


pro aafit2,key,delta,alt,az,reverse,moon,kill,a,sigma,points,plotit=plotit,ewd=ewd,constant=constant,aac=aac

;aac = 1 for alt, =2 for az
if keyword_set(aac) eq 0 then begin
    print,'assuming altitude fit. Specify aac for az fit.'
    aac=1
endif

;CONSTANTS AND OPTIONS

common plotcolors


;USE KEYKILL TO FORMAT THINGS
;keykill the alt
keykill,key,delta,alt,reverse,moon,kill,tdelta,talt,treverse,itworked,killdex
;keykill the az
keykill,key,delta,az,reverse,moon,kill,tdelta,taz,treverse,itworked,killdex


if itworked eq 1 then begin

    points=n_elements(tdelta)

;FITTING:

    revdex=where(treverse eq 1,count)
    rev=talt*0.0+1.0
    if count ne 0 then begin
        rev[where(treverse eq 1)]= -1
        talt[where(treverse eq 1)]=180.-talt[where(treverse eq 1)]
    endif


    ;LOOP FOR USER REMOVAL OF POINTS
    onceagain=1
    while onceagain eq 1 do begin

        ;TAKE OUT THE ELIMINATED POINTS
        if keyword_Set(mouse) then begin
            kill[killdex[midx]]=1 ; CHANGE THE KILL FILE
            ntot=n_elements(talt)
            if midx eq 0 then begin
;                print,'zero'
                talt=talt[1:*]
                taz=taz[1:*]
                tdelta=tdelta[1:*]
                treverse=treverse[1:*]
                rev=rev[1:*]
            endif else begin
                if midx eq ntot-1 then begin
                    talt=talt[0:ntot-2]
                    taz=taz[0:ntot-2]
                    tdelta=tdelta[0:ntot-2]
                    treverse=treverse[0:ntot-2]
                    rev=rev[0:ntot-2]
                endif else begin
                   ; print,midx
                    talt=[talt[0:midx-1],talt[midx+1:*]]
                    taz=[taz[0:midx-1],taz[midx+1:*]]
                    tdelta=[tdelta[0:midx-1],tdelta[midx+1:*]]
                    treverse=[treverse[0:midx-1],treverse[midx+1:*]]
                    rev=[rev[0:midx-1],rev[midx+1:*]]
                endelse
            endelse
        endif


;    num=n_elements(talt)


;       DO THE FITTING

        s=fitgen(talt,taz,aac,rev=rev,constant=constant)
        t=tdelta
        
        m=2
        num=n_elements(talt)
        n=num
        
        SS=transpose(S)##S
        ST=transpose(S)##transpose(T)
        SSI=invert(SS)
        A=SSI##ST
        
        BT=S##A
        
        sigsq=total((T-BT)^2)/(N-M)
        sigsq=float(sigsq)
        sigdcsq=sigsq*SSI[(M+1)*indgen(M)]
        
;        dial=a[0]
        if keyword_Set(constant) then skew=0.0001 else skew=a[1]
       
        sigma=sqrt(sigdcsq)
        
;PLOTING STUFF
        
        if keyword_Set(plotit) then begin
            
;GET FORWARD AND REVERSE INDEXES
            revidx=where(treverse eq 1,rk) 
            foridx=where(treverse eq 0,fk)
            if rk ne 0 then rk=1
            if fk ne 0 then fk=1
            
;        print,'rk,fk',rk,fk
;        print,'itworked',itworked
;        help,treverse
;        help,talt
;        print,revdex  
;make titles:
            
            if key eq 0 then ptit='0 - forward sun correction'
            if key eq 1 then ptit='1 - reverse sun correction'
            if key eq 2 then ptit='2 - combined f&r sun correction'
            if key eq 3 then ptit='3 - forward moon correction'
            if key eq 4 then ptit='4 - reverse moon correction'
            if key eq 5 then ptit='5 - combined f&r moon correction'
            if key eq 6 then ptit='6 - forward sun and moon correction'
            if key eq 7 then ptit='7 - reverse sun and moon correction'
            if key eq 8 then ptit='8 - combined f&r sun&moon correction'
            if aac eq 1 then ptit=ptit+' - altitude'
            if aac eq 2 then ptit=ptit+' - azimuth'
            if keyword_Set(ewd) eq 0 then ptit=ptit+' - east dish'
            if keyword_Set(ewd) eq 1 then ptit=ptit+' - west dish'
            
            
            
           
                                ;MAKE FAKE DATA
            faketalt=findgen(80)
            faketaz=fltarr(80)+190.
            faketdeltaf=fitgen(faketalt,faketaz,aac,rev=fltarr(80)+1.)
            for nr=0,1 do faketdeltaf[nr,*]=a[nr]*faketdeltaf[nr,*]
            faketdeltaf=total(faketdeltaf,1)
            faketdeltar=fitgen(faketalt,faketaz,aac,rev=fltarr(80)-1.)
            for nr=0,1 do faketdeltar[nr,*]=a[nr]*faketdeltar[nr,*]
            faketdeltar=total(faketdeltar,1)


;            print,stopithere
;            if keyword_Set(constant) then begin
;                faketdeltaf=a[0]+fltarr(80)
;                faketdeltar=a[0]+fltarr(80)
;            endif else begin
;                faketdeltaf=a[0]+a[1]*1/(cos(faketalt*!dtor))
;                faketdeltar=a[0]-a[1]*1/(cos(faketalt*!dtor))
;            endelse

;MAKE A MORNING/EVENING DISTINCTION 
;(actually, just a list of morning points to oplot)
;            sortdex=sort(taz)
;            sortedalt=talt(sortdex)
;            sorteddelta=tdelta(sortdex)
;            middex=where(sortedalt eq max(sortedalt))
;            middex=reform(middex)
;            middex=middex[0]
;            mornalt=sortedalt[0:middex]
;            morndelta=sorteddelta[0:middex]
;do it in a way that works for more than one day
            morndex=where(taz le 180.,mornkey)
            if mornkey ne 0 then begin
            mornalt=talt(morndex)
            morndelta=tdelta(morndex)
            if rk ne 0 then mard=morndex[where(morndex eq revdex)]
            if fk ne 0 then mafd=morndex[where(morndex eq fordex)]
            endif
        
;        print,'aafitL203'
;        help,taz,talt,mouse,morndex,mornalt,morndelta


;            help,faketdeltaf
            if (fk and rk) then begin
                mm=minmax([faketdeltaf,faketdeltar,tdelta])    
                mmc=minmax([faketalt,talt])
                plot,faketalt,faketdeltaf,yr=[mm[0],mm[1]],xr=[mmc[0],mmc[1]],$
                  title=ptit,ytitle='delta, degrees', $
                  xtitle='altitude, degrees',/nodata
                oplot,faketalt,faketdeltaf,color=red
                oplot,talt,tdelta,color=red,ps=2
                oplot,faketalt,faketdeltar,color=blue
                oplot,talt,tdelta,color=blue,ps=2
                if keyword_set(mafd) then $
                  oplot,talt[mafd],tdelta[mafd],color=magenta,ps=2 
                if keyword_set(mard) then $
                  oplot,talt[mafd],tdelta[mard],color=magenta,ps=2 


            endif else begin
            if fk then begin
                mm=minmax([faketdeltaf,tdelta])    
                mmc=minmax([faketalt,talt])
                plot,faketalt,faketdeltaf,yr=[mm[0],mm[1]],xr=[mmc[0],mmc[1]],$
                  title=ptit,ytitle='delta, degrees',xtitle='altitude, degrees'
                oplot,faketalt,faketdeltaf,color=red
                oplot,talt,tdelta,color=red,ps=2
                if mornkey ne 0 then $
                  oplot,mornalt,morndelta,color=magenta,ps=2 ;morning points
            endif 
            if rk then begin
                mm=minmax([faketdeltar,tdelta])
                mmc=minmax([faketalt,talt])
                plot,faketalt,faketdeltar,yr=[mm[0],mm[1]],xr=[mmc[0],mmc[1]],$
                  title=ptit,ytitle='delta, degrees',xtitle='altitude, degrees'
                oplot,faketalt,faketdeltar,color=blue
                oplot,talt,tdelta,color=blue,ps=2
                if mornkey ne 0 then $
                  oplot,mornalt,morndelta,color=cyan,ps=2 ;morning points
            endif 
            endelse
            ;mm=minmax([faketdeltaf,faketdeltar,tdelta])
            ;make a plot and plot the fake data
           
            ;oplot,faketalt,faketdeltar,color=blue
            ;now plot the real data
            ;x=talt
            ;y=tdelta
            ;help,red
            ;if fk then oplot,x,y,color=red,ps=2
            ;if rk then oplot,x[revidx],y[revidx],color=blue,ps=2
            ;now ask what to do
            if keyword_set(mouse) eq 0 then begin
                print,'type q to quit plotting, k to kill one of these points, and any other key to continue'
                userkey=get_kbrd(1)
                if strmatch(userkey,'q',/fold_case) then begin
                    plotit=0
                    onceagain = 0
                endif
                if (strmatch(userkey,'k',/fold_case) or $
                    keyword_set(mouse)) then getapoint=1 $
                     else onceagain=0
            endif
            if keyword_set(mouse) or keyword_set(getapoint) then begin
                print,'click on the point you want to remove with the left mouse button, or right click to return without killing any points.'
                midx=findpoint(talt,tdelta,xpos,ypos,/verbose,mouse=mouse)
                                ;print,x[midx],y[midx]
                midx=reform(midx)
                midx=midx[0]
                
                if mouse eq 1 then onceagain = 1 else onceagain=0
                
            endif else begin
                onceagain=0
            endelse
        endif else begin
            onceagain=0
        endelse
    endwhile     
    
endif else begin
    a=[-1000.0,-1000.0]
    sigma=-1000.0
    points=0
endelse
    
end



