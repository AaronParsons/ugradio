;+
; NAME: altfit
;
; PURPOSE: performs least squares fitting for the dial and flop
; constants used in interferometer pointing corrections.
;
; EXPLANATION: 
;
; CALLING SEQUENCE: altfit,delta,alt,moon,reverse,kill,dial,flop,sigma
;
; INPUTS: 
;
; OPTIONAL INPUT KEYWORDS:
;
; OUTPUTS: 
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED
;
; REVISION HISTORY:
;-

pro altfit,key,delta,alt,reverse,moon,kill,dial,flop,sigma,points,plotit=plotit,ewd=ewd


;USE KEYKILL TO FORMAT THINGS
keykill,key,delta,alt,reverse,moon,kill,tdelta,talt,treverse,itworked


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
    num=n_elements(talt)
    rev=talt*0.0+1.0
    revdex=where(treverse eq 1,count)
    if count ne 0 then begin
        rev[where(treverse eq 1)]= -1
        taltu=talt
        talt[where(treverse eq 1)]=180.-talt[where(treverse eq 1)]
    endif else begin
        taltu=talt
    endelse

    s=fltarr(4,num)
    s[0,*]=1
    s[1,*]=talt
    s[2,*]=(3./2.) *talt^2 - (1./2.)
    s[3,*]=(5./2. )*talt^3-(3./2.) *talt
;    s[0,*]=1
;    s[1,*]=0
;    s[2,*]=taltu*!dtor
;    s[0,*]=1                    ;HEY HEY HEY I CHANGED!!!!!
;    s[1,*]=rev*cos(talt*!dtor)
    
    t=tdelta
    
    m=4
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
    flop=a[1]
    sigdcsq=sigdcsq[0:1] ;;HEY I CHANGED!
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
        ptit=ptit+' - altitude'
        if keyword_Set(ewd) eq 0 then ptit=ptit+' - east dish'
        if keyword_Set(ewd) eq 1 then ptit=ptit+' - west dish'
      
        
        
;    plot,talt,tdelta,ps=2
                                ;   oplot,talt,S##A,ps=4,color=255
                                ;  print,'strike any key to continue'
                                ; trash=get_kbrd(1)
        
                                ;MAKE FAKE DATA
        faketalt=findgen(80)
        faketdeltaf=a[0]+a[1]*(cos(faketalt*!dtor))+a[2]*faketalt*!dtor
        faketdeltar=a[0]+a[1]*(cos(faketalt*!dtor))+a[2]*(180.-faketalt)*!dtor ; HEY HEY HEY I CHANGED
;        faketdeltar=a[0]-a[1]*(cos(faketalt*!dtor))
        mm=minmax([faketdeltaf,faketdeltar,tdelta])
        plot,faketalt,faketdeltaf,yr=[mm[0],mm[1]],$
          title=ptit,ytitle='delta, degrees',xtitle='altitude, degrees'
        oplot,faketalt,faketdeltaf,color=255
        oplot,faketalt,faketdeltar,color=16711680
        if fk then oplot,talt[foridx],tdelta[foridx],ps=2,color=255
        if rk then oplot,talt[revidx],tdelta[revidx],ps=2,color=16711680
        print,'type q to quit plotting, and any other key to continue'
        print,'fits:0,1,2,3:',a[0],a[1],a[2],a[3]
        userkey=get_kbrd(1)
        if strmatch(userkey,'q',/fold_case) then plotit=0
    endif
    

endif else begin
    dial=-1000.0
    flop=-1000.0
    sigma=-1000.0
    points=0
endelse

end





