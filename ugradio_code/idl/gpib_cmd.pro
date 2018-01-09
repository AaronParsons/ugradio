function gpib_cmd,host,port,gpib_address, commandStr, QUERY=query
  
;   CH 11 feb 2015: use 'free_lun, fhandle'

;stop
;addressString = '++addr ' + strtrim(string(fix(gpib_address))) 
addressString = '++gpib_address ' + strtrim(string(fix(gpib_address))) 

;HOST = '10.32.92.86'
;PORT = 1234

SOCKET, fHandle, HOST, PORT, /GET_LUN

printf, fHandle, addressString
printf, fHandle, '++mode 1'
printf, fHandle, '++eos 2'
printf, fHandle, commandStr

gpibQuery = ''

if keyword_set(query) then begin
    readf, fHandle, gpibQuery
endif else begin
    gpibQuery = 0
endelse
printf, fHandle, string(27B) + string(10B) + string(27B)
; Need a wait command here because things are stupid
wait,1
free_lun, fhandle
;close, fHandle

return, gpibQuery

end
