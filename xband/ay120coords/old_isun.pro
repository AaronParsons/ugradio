;+
; NAME: isun 
;
; PURPOSE:
;        Returns the position of the sun in ra,dec (hours,deg)
;        or alt,az (deg)  at the current time, or a user
;        specified date and time
;
; EXPLANATION
;       This procedure calls several other routines to find the
;       position of the moon, correct for parallax, and return either
;       the alt and az or the ra and dec.  For notes on accuracy, see
;       moonpos.pro, and ilst.pro
;
; CALLING SEQUENCE:
;         isun,ra,dec   -OR-
;         isun,output   -OR-
;         isun,alt,az,/aa
;
; INPUTS: non required
;
; OPTIONAL INPUT KEYWORDS:
;
;         date='dd/mm/yyyy' - the UT date to query
;         ut='hh:mm:ss'  - the UT time to query
;         /aa - returns azimuth and alt in degs instead of ra, dec         
;         /hms - switches from decimal to babylonian for all output
;         /geocentric - does not correct for earth surface parallax
;         getlst - a named string which will hold the lst value used
;         /verbose - prints some values
;         /debug - prints more values
;
; OUTPUTS: ra,dec (nornal mode)  - the ra and dec in decimal hours and
;                                  degrees unless /hms keyword is
;                                  specified
;          output  - used whenever one output is specified
;                    an output string identical to the unix command
;                    SUN, of the form:
;                    22:37:49.4 -08:39:03 1991.2 40.9
;                    Where the first two fields are the RA and
;                    Declination of the center of the sun, the next is
;                    the coordinate epoch and the last is the number
;                    of degrees that the sun is above the horizon.
;                    NOTE: Since this function proved useless, it was
;                    never completed.  Only the ra and dec fields are
;                    correct. the other fields are replaced with
;                    zeros.
;
;          alt,az - returns the alt and az in degrees when /aa keyword
;                   is given
;
; EXAMPLES: 
;       isun,ra,dec &print,ra,dec
;       isun,output,date='23/12/2003',ut='14:00:00'
;
; RESTRICTIONS:
;       no parallax correction
;
; PROCEDURES CALLED: 
;       makedate, moonpos, julday, ct2alst,
;       hd2aa, sixty
;       
; REVISION HISTORY:
;       Erik Shirokoff (shiro@ugastro) summer 2001.
;-

pro isun,first,second,aa=aa,ut=ut,date=date,rise=rise,set=set,hms=hms,verbose=verbose,debug=debug,getlst=getlst,getjd=getjd

verby=keyword_Set(verbose)
buggy=keyword_set(debug)
if buggy then verby=1
if n_params() le 1 then unixstyle=1 else unixstyle=0

;MAKE A DATE ARRAY
    darr=makedate(ut,date)

if buggy then print,'darr:',darr      
  
;GET THE REDUCED JULIAN DATE

juldate,darr,jd
getjd=jd

;*****************************************
;Change by Jonah Hare 2007jan02
;Convert reduced_julian to julian, because that works in sunpos
jd = double(jd) + 2.4d6
;*****************************************


if verby then print,'Julian date:',string(jd,format='(D)')

;GET THE SUN POSITION
;sunposred,jd,ra,dec
sunpos, jd, ra, dec
ra=ra/15.

;GET ALT AND AZ
if keyword_set(aa) then begin
    ;print,'haha',date,ut
    lst=ilst(date=date,time=ut,verbose=verbose,local=local)
    getlst=lst
    ha=lst-ra
    ;print,lst,ra,ha
    aar=hd2aa(ha*15.,dec)
    alt=aar[0]
    az=aar[1]
endif

;HMS STUFF
if (keyword_Set(hms) or unixstyle) then begin
    ra=sixty(ra)
    dec=sixty(dec)
    if keyword_Set(alt) then alt=sixty(alt)
    if keyword_Set(az) then az=sixty(az)
endif


if verby then print,'ra,dec:',ra,dec
if verby and keyword_Set(aa) then print,'alt,az:',alt,az

if not(unixstyle) then  begin
    if keyword_Set(aa) then begin
        first=alt
        second=az
    endif else begin
        first=ra
        second=dec
    endelse
endif

;UNIX FORMATTING
if unixstyle then begin
    rastr1=strn(fix(ra[0])) 
    rastr2=strn(fix(ra[1])) 

    laststring=strn(ra[2])
    dotpos=strpos(laststring,'.')
    laststring=strmid(laststring,0,dotpos+2)


    if strlen(rastr1) eq 1 then rastr1 ='0'+rastr1
    if strlen( rastr2) eq 1 then rastr2 ='0'+rastr2
    if strlen( laststring) eq 3 then laststring='0'+laststring

rastr= rastr1+':'+rastr2+':'+laststring

;print,rastr 

    decstr1=strn(fix(dec[0])) 
    decstr2=strn(fix(dec[1])) 
    laststring=strn(dec[2])
    dotpos=strpos(laststring,'.')
    laststring=strmid(laststring,0,dotpos)



    if strlen( decstr1) eq 1 then decstr1 ='0'+decstr1
    if strlen( decstr2) eq 1 then decstr2 ='0'+decstr2
    if strlen( laststring) eq 1 then laststring='0'+laststring

decstr= decstr1+':'+decstr2+':'+laststring
if dec[0] ge 0 then decstr='+'+ decstr

;print,decstr

output=rastr+' '+decstr


;I'M NOT FINISHED, FOR NOW LET'S ADD
;PADDING TO MAKE THE OUTPUT DIM CORRECT
output=output+' 0000.00 00.0 0.0'


first=output

endif

end

 










