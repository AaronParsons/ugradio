;+
; NAME: azfit
;
; PURPOSE: performs least squares fitting for the dial and flop
; constants used in interferometer pointing corrections.
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
; PROCEDURES CALLED: KEYKILL
;
; REVISION HISTORY: written by Erik Shirokoff, 5/2001
;-

pro azfit,key,delta,alt,reverse,moon,kill,dial,skew,sigma,points,plotit=plotit,ewd=ewd

common plotcolors

;USE KEYKILL TO FORMAT THINGS
keykill,key,delta,alt,reverse,moon,kill,tdelta,talt,treverse,itworked,killdex


;if key eq 0 then begin
;    plot,reverse,xtitle='reverse,treverse in red'
;    wait,3
;endif

;if (key eq 0 and itworked eq 1) then begin
;    oplot,treverse,color=255
;    wait,3
;endif
;print,'what the hell'

;help,'treverse',treverse
;print,'haha'

if itworked eq 1 then begin

    points=n_elements(tdelta)

;forward
;dalt=altdialf + flopf*cos(alt)
;daz=azdialf + skewf/cos(alt)



;TTALT FITTING:

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
            ;fullidx=where(tdelta eq ypos)
            ;fullidx=reform(fullidx)
            ;fullidx=fullidx[0]
            ;print,'tdelta',tdelta
           ; print,'ypos',ypos
            kill[killdex[midx]]=1 ; CHANGE THE KILL FILE
            ntot=n_elements(talt)
            if midx eq 0 then begin
;                print,'zero'
                talt=talt[1:*]
                tdelta=tdelta[1:*]
                treverse=treverse[1:*]
                rev=rev[1:*]
            endif else begin
                if midx eq ntot-1 then begin
                    talt=talt[0:ntot-2]
                    tdelta=tdelta[0:ntot-2]
                    treverse=treverse[0:ntot-2]
                    rev=rev[0:ntot-2]
                endif else begin
                   ; print,midx
                    talt=[talt[0:midx-1],talt[midx+1:*]]
                    tdelta=[tdelta[0:midx-1],tdelta[midx+1:*]]
                    treverse=[treverse[0:midx-1],treverse[midx+1:*]]
                    rev=[rev[0:midx-1],rev[midx+1:*]]
                endelse
            endelse
        endif

    ;rev=talt*0.0+1.0
    ;revdex=where(treverse eq 1,count)
    ;if count ne 0 then begin
    ;    rev[revdex]= -1
    ;    talt[where(treverse eq 1)]=180.-talt[where(treverse eq 1)]
    ;endif



    num=n_elements(talt)
        
    
    s=fltarr(2,num)
    s[0,*]=1
    s[1,*]=rev*1./(cos(talt*!dtor))
    
;    s[0,*]=1                    ;HEY HEY HEY I CHANGED!!!!!
;    s[1,*]=rev*cos(talt*!dtor)
        
        t=tdelta
        
        m=2
        n=num
        
        SS=transpose(S)##S
        ST=transpose(S)##transpose(T)
        SSI=invert(SS)
        A=SSI##ST
        
        BT=S##A
        
        sigsq=total((T-BT)^2)/(N-M)
        sigsq=float(sigsq)
        sigdcsq=sigsq*SSI[(M+1)*indgen(M)]
        
        dial=a[0]
        skew=a[1]
 


       
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
            ptit=ptit+' - azimuth'
            if keyword_Set(ewd) eq 0 then ptit=ptit+' - east dish'
            if keyword_Set(ewd) eq 1 then ptit=ptit+' - west dish'
            
            
            
;    plot,talt,tdelta,ps=2
                                ;   oplot,talt,S##A,ps=4,color=255
                                ;  print,'strike any key to continue'
                                ; trash=get_kbrd(1)
            
                                ;MAKE FAKE DATA
            faketalt=findgen(80)
            faketdeltaf=a[0]+a[1]*1/(cos(faketalt*!dtor))
            faketdeltar=a[0]-a[1]*1/(cos(faketalt*!dtor))
;        faketdeltar=a[0]-a[1]*(cos(faketalt*!dtor))
            mm=minmax([faketdeltaf,faketdeltar,tdelta])
            ;make a plot and plot the fake data
            plot,faketalt,faketdeltaf,yr=[mm[0],mm[1]],$
              title=ptit,ytitle='delta, degrees',xtitle='altitude, degrees'
            oplot,faketalt,faketdeltaf,color=red
            oplot,faketalt,faketdeltar,color=blue
            ;now plot the real data
            x=talt
            y=tdelta
            ;help,red
            help,rk,revdex
            if fk then oplot,x,y,color=red,ps=2
            if rk then oplot,x[revidx],y[revidx],color=blue,ps=2
            ;now ask what to do
            print,'type q to quit plotting, k to kill one of these points, and any other key to continue'
            userkey=get_kbrd(1)
            if strmatch(userkey,'q',/fold_case) then begin
                plotit=0
                onceagain=0
            endif
                if strmatch(userkey,'k',/fold_case) then begin
                print,'click on the point you want to remove with the left mouse button, or right click to return without killing any points.'
                midx=findpoint(x,y,xpos,ypos,/verbose,mouse=mouse)
                ;print,x[midx],y[midx]
                midx=reform(midx)
                midx=midx[0]
                print,'midx,x,y,mouse',midx,x[midx],y[midx],mouse
                ;print,y
                ;xpos=reform(xpos)
                ;ypos=reform(ypos)
                ;xpos=xpos[0]
                ;ypos=ypos[0]
                if mouse eq 1 then onceagain = 1 else onceagain=0
                
            endif else begin
                onceagain=0
            endelse
        endif else begin
            onceagain=0
        endelse
    endwhile     
    
endif else begin
    dial=-1000.0
    skew=-1000.0
    sigma=-1000.0
    points=0
endelse
    
end



