PRO gpib_strgw, strg, ret_val = ret_val, verbose=verbose

; This is a function to send a command to the prologix
; /verbose added by CH 16 feb 2015

str1 = 'echo "'
str2 = '" > /tmp/gpib_command1 ; /home/global/ay121/idl/pc/gpibw /tmp/gpib_command1 10.32.92.86'
str3 = 'rm /tmp/gpib_command1;'

strg_arg = str1 + strg + str2
strg_arg = STRCOMPRESS(strg_arg)
;print, strg_arg
if keyword_set( verbose) then print, 'strg_arg = ', strg_arg
;print, 'gpib_strgw strg_arg = ', strg_arg
spawn, strg_arg, ret_val
spawn, str3
ret_val = FLOAT(ret_val)
;print,ret_val


END
