;+
; NAME: debugaz
;
; PURPOSE: reads in all the files in a directory, calculated the
; expected az and alt from the save udate variable, and compares it to
; the s_alt and s_az variables
;
; EXPLANATION: written to hunt down the mysterious 5-degree jump at
; az=110 deg
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; OPTIONAL INPUTS:
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
; REVISION HISTORY: Erik Shirokoff,6/2001
;-

pro debugaz,dir,out,rtaz,newaz,jd1,plotit=plotit

;CONSTANTS AND STUFF

verby=1
;verby=keyword_set(verbose)
;if keyword_set(silent) ne 1 then i=1 else i=0


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
;    mdex=where(stregex(s,'moon',/boolean) eq 1,mdk)
    if sdk then s1=s[sdex] 
;    if mdk then s2=s[mdex]
        if sdk ne 0 then s=s[sdex]

    nfiles=n_elements(s)+nfiles
    if keyword_set(sarr) then $
      sarr=[sarr,strarr(n_elements(s))+dirname+s] else $
       sarr=strarr(n_elements(s))+dirname+s
endfor

s=sarr
;print,s

if verby then print,nfiles

rtsaa=fltarr(nfiles,2) ; the coords used in real time
rtsrd=fltarr(nfiles,2) ; ra and dec of the same
jd=dblarr(nfiles)
revarr=fltarr(nfiles)
newsaa = fltarr(nfiles,2) ; calculated coords
newsrd=fltarr(nfiles,2)


;OUTER LOOP
for nr=0,nfiles-1 do begin
print,nr,'  '+s[nr]
;ANALYZE A FILE

if verby then print,s[nr]

;print,s[nr]

restore,s[nr]
rtsaa[nr,*]=[head.s_alt,head.s_az]
rtsrd[nr,*]=[head.s_ra,head.s_dec]
datearr=makedate(unixstring=head.udate)
datestr=makedate(datearr,/undo)
jd[nr]=julday(datearr[1],datearr[2],datearr[0],datearr[3],datearr[4],datearr[5])
;aasun,alt,az,ut=datestr[0],date=datestr[1],/ephem,/a
;aasun,ra,dec,ut=datestr[0],date=datestr[1],/ephem
isun,alt,az,ut=datestr[0],date=datestr[1],/aa
isun,ra,dec,ut=datestr[0],date=datestr[1]

newsaa[nr,*]=[alt,az]
newsrd[nr,*]=[ra,dec]
revarr[nr]=head.reverse

endfor

out={rtsaa:rtsaa, $
     rtsrd:rtsrd, $
     jd:jd,$
     rev:revarr,$
     newsaa:newsaa, $
     newsrd:newsrd}


rtaz=rtsaa[where(revarr eq 0),1]
newaz=newsaa[where(Revarr eq 0),1]
jd1=jd[where(Revarr eq 0)]


;plotting stuff
if keyword_set(plotit) then begin
difaz=newsaa[*,1]-rtsaa[*,1]
difaz=difaz[where(revarr eq 0)]
rtsaa=rtsaa[where(revarr eq 0),*]
plot,rtsaa[*,1],difaz,/ys,/xs,ps=4

endif

end












