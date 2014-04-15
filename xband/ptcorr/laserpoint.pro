pro laserpoint,start=start,nmax

if keyword_set(nmax) eq 0 then nmax=50.


str1='echo point az_w=90 |sendpc node=quasar'
str2='echo point az_w=250 |sendpc node=quasar'
str3='echo point |sendpc node=quasar'
str4='echo oms re rp |sendpc node=quasar'
waitlen=1.5

spawn,str4,s0
print,s0

if keyword_Set(start) eq 0 then begin
    
;    salt=70.
;    saz=90
;    dalt=50
;    daz=10

flag=0
nr=0
r=''
while flag eq 0 do begin
print,nr
spawn,str1,s
;print,s
wait,waitlen
spawn,str3,s
print,s
spawn,str4,s
print,s
spawn,str2,s
wait,waitlen
;print,s
spawn,str3,s
print,s
spawn,str4,s
print,s
r=get_kbrd(0)
if strmatch(r,'q') then flag=1
nr=nr+1
if nr ge nmax then flag=1
endwhile
endif

print,'last return'
spawn,str1,s
print,s
spawn,str3,s
print,s
spawn,str4,s
print,'last position (re,rp):',s
print,'starting position (re,rp):',s
print,'done'


end



