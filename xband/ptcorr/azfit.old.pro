;+
; NAME: altfit
;
; PURPOSE: performs least squares fitting for the dial and flop
; constants used in interferometer pointing corrections.d
;
; EXPLANATION: generally used as a subroutine of POINTFIT
;
; CALLING SEQUENCE: altfit,delta,alt,moon,reverse,kill,dial,flop,sigma
;
; INPUTS: key - the moon/sun/forward/reverse numeric identifier
;         delta - array of the object center minus the dial reading
;         alt - array of altitude in degrees
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
;          skew - an array of fit sigmas: [dial sigma,flop sigma]
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED: KEYKILL
;
; REVISION HISTORY: written by Erik Shirokoff, 5/2001
;-



pro azfit,key,delta,alt,reverse,moon,kill,dial,skew,sigma,points,plotit=plotit,ewd=ewd

;USE KEYKILL TO FORMAT THINGS

keykill,key,delta,alt,reverse,moon,kill,tdelta,talt,treverse,itworked

;print,'hooha'

if itworked eq 1 then begin

    points=n_elements(tdelta)

;forward
;dtalt=taltdialf + flopf*cos(talt)
;daz=azdialf + skewf/cos(talt)

;TALT FITTING:
    num=n_elements(talt)
    rev=talt*0.0+1.0
    revdex=where(treverse eq 1,count)
    if count ne 0 then begin
        rev[where(treverse eq 1)]= -1
        talt[where(treverse eq 1)]=180.-talt[where(treverse eq 1)]
    endif    
    
    s=fltarr(2,num)
    s[0,*]=1
    s[1,*]=rev*1./(cos(talt*!dtor))
    
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
;help,sigsq
;help,sigdcsq
    sigma=sqrt(sigdcsq)
;help,sigma
    
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
        

;NOW DO THE PLOTTING
       
                                ;MAKE FAKE DATA
        faketalt=findgen(80)
        faketdeltaf=a[0]+a[1]*1/(cos(faketalt*!dtor))
        faketdeltar=a[0]-a[1]*1/(cos(faketalt*!dtor))
        mm=minmax([faketdeltaf,faketdeltar])
        plot,faketalt,faketdeltaf,yr=[mm[0],mm[1]],$
          title=ptit,ytitle='delta, degrees',xtitle='altitude, degrees'
        oplot,faketalt,faketdeltaf,color=255
        oplot,faketalt,faketdeltar,color=16711680
        if fk then oplot,talt[foridx],tdelta[foridx],ps=2,color=255
        if rk then oplot,talt[revidx],tdelta[revidx],ps=2,color=16711680
        print,'strike any key to continue'
        print,'type q to quit plotting, and any other key to continue'
        userkey=get_kbrd(1)
        if strmatch(userkey,'q',/fold_case) then plotit=0
    endif
    
;if keyword_Set(plotit) then begin
;    revidx=where(treverse eq 1,rk) 
;    foridx=where(treverse eq 0,fk)
;    if rk ne 0 then rk=1
;    if fk ne 0 then fk=1
;    plot,talt,tdelta,ps=2
 ;   oplot,talt,S##A,ps=4,color=255
  ;  print,'strike any key to continue'
   ; trash=get_kbrd(1)
;    faketalt=findgen(90)
;    faketdeltaf=a[0]+a[1]*1/(cos(faketalt*!dtor))
;    faketdeltar=a[0]-a[1]*1/(cos(faketalt*!dtor))
;    mm=minmax([faketdeltaf,faketdeltar])
;    plot,faketalt,faketdeltaf,yr=[mm[0],mm[1]]
;    oplot,faketalt,faketdeltaf,color=255
;    oplot,faketalt,faketdeltar,color=16711680
;    if fk then oplot,talt[foridx],tdelta[foridx],ps=2,color=255
;    if rk then oplot,talt[revidx],tdelta[revidx],ps=2,color=16711680
;    print,'strike any key to continue'
;    trash=get_kbrd(1)
;endif

endif else begin
    dial=-1000.0
    skew=-1000.0
    sigma=-1000.0
    points=0
endelse

end


