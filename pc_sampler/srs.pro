pro srs, device, command

close, 7 ;close the socket in case it is open

the_string='gpib ds345_2 '
if device eq 1 then the_string = 'gpib ds345_1 '

the_string = the_string + command
;print, the_string
;open the socket...
socket, 7, '10.32.92.19', 1340, read_timeout=1

;declare the character array tst=strarr(10)
tst=strarr(10)

;send the message to the pc...
printf,   7, the_string
;define a dummy variable as a string...
tst0='a'
;read 3 lines...
for nr=0,2 do begin
readf, 7, tst0
tst[ nr]= tst0
endfor

;close the socket!
close,7

  
end
