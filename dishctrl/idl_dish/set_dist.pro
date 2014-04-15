PRO SET_DIST, IP_ADDR, PORT, MOVE_AXIS, DISTANCE = DISTANCE, SUCCESS=SUCCESS, VERBOSE=VERBOSE

ARG=STRING(13B)+STRING(13B)+MOVE_AXIS+'D'+DISTANCE+STRING(13B)+STRING(13B)+MOVE_AXIS+'D'+STRING(13B)
IF VERBOSE EQ 1 THEN PRINT, 'Setting Drive ',MOVE_AXIS,' distance to ',DISTANCE,'.'
OEM_REPLY='1234567890123'+DISTANCE

WAIT,1

SOCKET,SOCK_UNIT,IP_ADDR,PORT,/GET_LUN
WRITEU,SOCK_UNIT,ARG
READU,SOCK_UNIT,OEM_REPLY
CLOSE,SOCK_UNIT
FREE_LUN,SOCK_UNIT

OEM_REPLY=STRSPLIT(OEM_REPLY,'*D',/EXTRACT)
OEM_REPLY=OEM_REPLY[1]
OEM_REPLY=STRSPLIT(OEM_REPLY,STRING(13B),/EXTRACT)
OEM_REPLY=OEM_REPLY[0]
IF OEM_REPLY EQ DISTANCE THEN SUCCESS = 1
IF VERBOSE EQ 1 THEN PRINT,'Success is equal to',STRCOMPRESS(STRING(SUCCESS))


END