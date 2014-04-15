FUNCTION msg_check, msg

common point2_common

if (VERBOSE_) then print,"here is the msg: ", msg

;Return TRUE if any of the following exist in the message
if (strpos(msg, 'done point') GE 0) then return, TRUE 
if (strpos(msg, 'done track') GE 0) then return, TRUE
if (strpos(msg, 'done home') GE 0) then return, TRUE

;Otherwise, return FALSE for an error
print, 'An error has occurred.'
return, FALSE
END
