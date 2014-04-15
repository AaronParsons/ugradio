;+
; NAME: realtimecheck
;
; PURPOSE: records lots of time and coord conv. stuff in real time
;
; EXPLANATION: used to check that various helper applications are
; consistant.  When it is called this program calls time, sun, and
; moon finding programs and stores the results in a big log file.
;
; CALLING SEQUENCE:realtimecheck,logfile
;
; INPUTS:logfile - the string name of a .sav file for the data
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
; REVISION HISTORY:
;-

pro realtimecheck,logfile

filename=smartname('.',logfile,'.sav')

str='ls '+filename
spawn,str,s
;help,s
;print,s
s=[s]
s=reform(s)
s=s[0]
if strmatch(s,'') then newfile=1 else newfile=0

qdar=transpose(makedate())
qjd1=jdnow()
qjd2=systime(/julian)
qlst1=ilst()

spawn,'lst',s
s=[s]
s=reform(s)
s=s[0]
s=strsplit(s,':',/extract)
s=ten(s[0],s[1],s[2])
qlst2=s

aasun,qalt1,qaz1,/aa
aasun,qra1,qdec1
aa2=hd2aa((qlst1-qra1)*15.,qdec1)
qalt2=aa2[0]
qaz2=aa2[1]

isun,qalt3,qaz3,/aa
isun,qra3,qdec3
aa4=hd2aa((qlst1-qra3)*15.,qdec1)
qalt4=aa2[0]
qaz4=aa2[1]

getsun,qalt5,qaz5



if newfile then begin
head=['Key to variables:          ', $
      'dar - from makedate                  ', $
      'jd1 - from jdnow                    ', $
      'jd2 - from systime                  ', $
      'lst1 - from ilst                   ', $
      'lst2 - from unix LST               ', $
      'alt1,az1 - from aasun in /aa mode              ', $
      'alt2,az2 - ra and dec from aasun and lst1 sent to hd2aa        ', $
      'alt3,az3 - from isun          ', $
      'alt4,az4 - ra and dec from isun and ilst send to hd2aa          ', $
      'alt5,az5 - from unix SUN via getsun.           ']

dar=qdar
jd1=qjd1
jd2=qjd2
lst1=qlst1
lst2=qlst2
alt1=qalt1
alt2=qalt2
alt3=qalt3
alt4=qalt4
alt5=qalt5
az1=qaz1
az2=qaz2
az3=qaz3
az4=qaz4
az5=qaz5


endif else begin
    restore,filename
    
dar=[dar,qdar]
jd1=[jd1,qjd1]
jd2=[jd2,qjd2]
lst1=[lst1,qlst1]
lst2=[lst2,qlst2]
alt1=[alt1,qalt1]
alt2=[alt2,qalt2]
alt3=[alt3,qalt3]
alt4=[alt4,qalt4]
alt5=[alt5,qalt5]
az1=[az1,qaz1]
az2=[az2,qaz2]
az3=[az3,qaz3]
az4=[az4,qaz4]
az5=[az5,qaz5]
    
endelse

save,filename=filename,head,dar,jd1,jd2,lst1,lst2,alt1,alt2,alt3,alt4,alt5,az1,az2,az3,az4,az5

end

