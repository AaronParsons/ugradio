PRO gpib_strg, strg

; This is a function to send a command to the prologix

str1 = 'echo "'
str2 = '" > /tmp/gpib_command1 ; /home/global/ay121/idl/pc/gpib /tmp/gpib_command1 10.32.92.86'
str3 = 'rm /tmp/gpib_command1;'

strg_arg = str1 + strg + str2

;stop

strg_arg = STRCOMPRESS(strg_arg)
;print, strg_arg
spawn, strg_arg
spawn, str3

END
