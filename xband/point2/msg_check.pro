function msg_check, msg

common point2_common

print,"here is the msg: ", msg

if (strpos(msg, 'done point') GE 0) then $
	return, TRUE 

if (strpos(msg, 'done track') GE 0) then $
	return, TRUE

if (strpos(msg, 'done home') GE 0) then $
	return, TRUE

print, 'An error has occurred.'
return, FALSE


end
