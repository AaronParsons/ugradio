PRO gpib_strg, strg

; This is a function to send a command to the prologix

str1 = 'echo "'
str2 = '" > /home/tmp/gpib_tmp/gpib_command ; /home/global/ay121/idl/pc/gpib /home/tmp/gpib_tmp/gpib_command 10.32.92.86'
str3 = 'rm /home/tmp/gpib_tmp/gpib_command;'

strg_arg = str1 + strg + str2
strg_arg = STRCOMPRESS(strg_arg)
;print, strg_arg
spawn, strg_arg
spawn, str3

END
