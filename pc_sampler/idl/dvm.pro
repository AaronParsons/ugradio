function dvm
;+
;  Function Name: dvm
;  Purpose:       return the volts from front input of the hp3478A
;  Authors:       Heiles and Jonah Hare 
;  Date:          2006dec21 (Winter Solstice at 16:22 PST) 
;  Syntax:        volts=dvm()
;-

;important: make this a function. maybe make it have a single input,
;which is the name or address of the computer being accessed; if it is
;unspecified, make the default be what we use most. make the port nr be
;a keyword, with default 1340. maybe make the nr of times read be a
;keyword, with default value of 2.

;specifying read_timeout=1 means that even if it hangs on eof, it won't
;spend more than one second.

;open the socket...
socket, 7, '10.32.92.19', 1340, read_timeout=10, connect_timeout=10

;declare the character array tst=strarr(10)
tst=strarr(10)

;send the message to the pc...
printf,   7, 'gpib hp3478 read'
;define a dummy variable as a string...
tst0='a'
;read 3 lines...
for nr=0,2 do begin
readf, 7, tst0
tst[ nr]= tst0
endfor

;*************************************************
;****  hp3478a must be read twice, but I don't know why
;*************************************************
;send the message to the pc...
;printf,   7, 'gpib hp3478 read'
;define a dummy variable as a string...
;tst0='a'
;read 3 lines...
;for nr=0,2 do begin
;readf, 7, tst0
;tst[ nr]= tst0
;endfor

;close the socket!
close,7

;for i=0, 9 do begin
;  print, tst[i]
;endfor

volts_string=tst[2]
volts_string=strmid(volts_string, 23)
volts = float(volts_string)
return, volts
  
end
