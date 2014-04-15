;+
; NAME: makedate
;
; PURPOSE: returns a formatted date array 
;
; EXPLANATION: This program can either take a human formatted time and
; or date and return the corresponding formatted date and time, or if
; called with no values it will return the current date and time (UT
; unless otherwise specified)
;
;
; CALLING SEQUENCE: result=makedate(['hh:mm:ss','dd/mm/yyyy'])
;                        -or-
;                   result=makedate(datearray,/undo)
;
; INPUTS: 
;        - normal (not undo) mode -          
;         non required.
;         if one is specified, it will be the desired time 'hh:mm:ss'
;         of the current date.
;         if two are specified, the first will be the time and the
;         second will be the date 'dd/mm/yyyy'
;
;        -undo mode -
;         datearray - an array similar to the normal mode output of
;                     makedate
;       
; OPTIONAL INPUTS:
;       unixstring - a string output by the unix command "date -u"
;                    (Used to check the ptcorr programs, not well tested.)
;
;
; OPTIONAL INPUT KEYWORDS:
;         /local - uses local time not UT time 
;         /verbose - prints out some stuff
;         /undo - works backwards - takes an array and returns strings
;
; OUTPUTS: 
;          - normal mode -
;          a longword array of the form:
;          [year,month,day,hour,min,sec]
; 
;          -reverse mode -
;          a two element string array containing the time ([0]) and
;          date ([1])
;
; EXAMPLES: dar=makedate()
;      
;           result=makedate(dar,/undo)
;
;	resultagain = makedata( result[1], result[0])

; RESTRICTIONS: This procedure has not been rigorously tested, however
; it seems to work.
;
; PROCEDURES CALLED: goddard routines
;
; REVISION HISTORY: written by Erik Shirokoff, 5/2001. undo added 6/2001
;-

function makedate,time,date,local=local,verbose=verbose,undo=undo,unixstring=unixstring

verby=keyword_Set(verbose)

;normal mode
if keyword_set(undo) eq 0 then begin
;print,'ack'

;THE NOW CASE
if (keyword_Set(time) eq 0 and keyword_Set(date) eq 0) then begin
    ;UT CASE
    if keyword_set(local) eq 0 then begin       
        if keyword_set(unixstring) then datestr=unixstring else $
          spawn,'date -u',datestr ; get utc date
        if verby then print,'datestr:',datestr
        datestr=strjoin(datestr) ; make it a scalar string
        datestr=strsplit(datestr,' GMT',/regex,/extract) ; break string on GMT and remove it
        datestr=strjoin(datestr) ; make it a scaler string again
        darr=bin_date(datestr)  ; convert to numbers
;        notation: date=[year,month,day,hour,min,sec]
        if verby then print,'date:',date
        ;tarr=ten(date[3],date[4],date[5]) ; make a floating time
 
   ;local time case
                                ; I believe that there is always a
                                ; time zone returned. if not, this
                                ; will fail.
    endif else begin
        spawn,'date',datestr ; get local date
        if verby then print,'datestr:',datestr
        datestr=strjoin(datestr)
        datestr=strsplit(datestr,' ',/extract)
        datestr=[datestr[0:3],datestr[5]]
        datestr=strjoin(datestr,' ')
        darr=bin_date(datestr)  ; convert to numbers
;        notation: date=[year,month,day,hour,min,sec]
        if verby then print,'date:',date
       ; tarr=ten(date[3],date[4],date[5]) ; make a floating time
    endelse
endif
 
;THE TIME ONLY CASE
if ((keyword_Set(time) ne 0) and (keyword_Set(date) eq 0)) then begin
;    print,'hi'
;    print,keyword_Set(time)
    ;UT CASE
    if keyword_set(local) eq 0 then begin       
        spawn,'date -u',datestr ; get utc date
        if verby then print,'datestr:',datestr
        datestr=strjoin(datestr) ; make it a scalar string
        datestr=strsplit(datestr,' GMT',/regex,/extract) ; break string on GMT and remove it
        datestr=strjoin(datestr) ; make it a scaler string again
        darr=bin_date(datestr)  ; convert to numbers
;        notation: date=[year,month,day,hour,min,sec]
        if verby then print,'date:',date
       ; tarr=ten(date[3],date[4],date[5]) ; make a floating time
   ;local time case
    endif else begin
        spawn,'date',datestr ; get utc date
        if verby then print,'datestr:',datestr
        datestr=strjoin(datestr)
        darr=bin_date(datestr)  ; convert to numbers
;        notation: date=[year,month,day,hour,min,sec]
        if verby then print,'date:',date
        ;tarr=ten(date[3],date[4],date[5]) ; make a floating time
    endelse
    
    tarr=strsplit(time,':',/regex,/extract)
    darr[3]=tarr[0]
    darr[4]=tarr[1]
    darr[5]=tarr[2]

endif

;THE DATE AND TIME CASE
if (keyword_Set(date) and keyword_Set(time)) then begin

    darr=lonarr(6)
    ;TAKE TIME AND PUT IN INTO ARRAY
    tarr=strsplit(time,':',/regex,/extract)
    darr[3]=tarr[0]
    darr[4]=tarr[1]
    darr[5]=tarr[2]
    ;TAKE DATE AND PUT IT INTO ARRAY
    darr1=strsplit(date,'/',/regex,/extract)
    darr[2]=darr1[0]
    darr[1]=darr1[1]
    darr[0]=darr1[2]
endif

return,darr

;undo mode
endif else begin

dar=time
;print,'heehee:',dar
yyyy=strn(fix(dar[0]))
mm=strn(fix(dar[1]))
dd=strn(fix(dar[2]))
if strlen(mm) eq 1 then mm='0'+mm
if strlen(dd) eq 1 then dd='0'+dd
date1=dd+'/'+mm+'/'+yyyy
;print,'hoohaa:',date1

hh=strn(fix(dar[3]))
mi=strn(fix(dar[4]))
ss=strn(fix(dar[5]))
if strlen(hh) eq 1 then hh='0'+hh
if strlen(mi) eq 1 then mi='0'+mi
if strlen(ss) eq 1 then ss='0'+ss
if strpos(ss,'.') eq 1 then ss='0'+ss
time1=hh+':'+mi+':'+ss

results=[time1,date1]
return,results

endelse

end




