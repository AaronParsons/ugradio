;removes some old folders

for nr=0,30 do begin
str=strn(nr)
spawn,'rm -Rf ./'+str,s
print,s


str=strn(nr)+'a'
 
spawn,'rm -Rf ./'+str,s
print,s

str=strn(nr)+'b'
 
spawn,'rm -Rf ./'+str,s
print,s
str=strn(nr)+'c'
 
spawn,'rm -Rf ./'+str,s
print,s
str=strn(nr)+'d'
 
spawn,'rm -Rf ./'+str,s
print,s
str=strn(nr)+'e'
 
spawn,'rm -Rf ./'+str,s
print,s
str=strn(nr)+'test'
endfor


end
