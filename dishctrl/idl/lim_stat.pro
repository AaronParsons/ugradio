PRO LIM_STAT, IP_ADDR, PORT, MOVE_AXIS, LIM_STATUS = LIM_STATUS, VERBOSE=VERBOSE

ARG=STRING(13B)+STRING(13B)+MOVE_AXIS+'RA'+STRING(13B)
IF VERBOSE EQ 1 THEN PRINT, 'Limit switch status requested from Drive ',MOVE_AXIS
OEM_REPLY='123456789'

WAIT,1

SOCKET,SOCK_UNIT,IP_ADDR,PORT,/GET_LUN
WRITEU,SOCK_UNIT,ARG
READU,SOCK_UNIT,OEM_REPLY
CLOSE,SOCK_UNIT
FREE_LUN,SOCK_UNIT

OEM_REPLY=STRSPLIT(OEM_REPLY,'*',/EXTRACT)
OEM_REPLY=OEM_REPLY[1]
OEM_REPLY=STRSPLIT(OEM_REPLY,STRING(13B),/EXTRACT)
OEM_REPLY=OEM_REPLY[0]
IF VERBOSE EQ 1 THEN PRINT, 'Drive ',MOVE_AXIS,' reply is ',OEM_REPLY

IF VERBOSE EQ 1 THEN BEGIN
CASE OEM_REPLY OF
  '@': PRINT,FORMAT= '(%"Limits tripped from last move => NONE\nLimits currently tripped => NONE")'
  'A': PRINT,FORMAT= '(%"Limits tripped from last move => CW\nLimits currently tripped => NONE")'
  'B': PRINT,FORMAT= '(%"Limits tripped from last move => CCW\nLimits currently tripped => NONE")'
  'D': PRINT,FORMAT= '(%"Limits tripped from last move => NONE\nLimits currently tripped => CW")'
  'E': PRINT,FORMAT= '(%"Limits tripped from last move => CW\nLimits currently tripped => CW")'
  'F': PRINT,FORMAT= '(%"Limits tripped from last move => CCW\nLimits currently tripped => CW")'
  'H': PRINT,FORMAT= '(%"Limits tripped from last move => NONE\nLimits currently tripped => CCW")'
  'I': PRINT,FORMAT= '(%"Limits tripped from last move => CW\nLimits currently tripped => CCW")'
  'J': PRINT,FORMAT= '(%"Limits tripped from last move => CCW\nLimits currently tripped => CCW")'
  'L': PRINT,FORMAT= '(%"Limits tripped from last move => NONE\nLimits currently tripped => BOTH")'
  'M': PRINT,FORMAT= '(%"Limits tripped from last move => CW\nLimits currently tripped => BOTH")'
  'N': PRINT,FORMAT= '(%"Limits tripped from last move => CCW\nLimits currently tripped => BOTH")'
ELSE: PRINT, 'No valid response received from Drive ',MOVE_AXIS,', please check communications.'
ENDCASE
ENDIF

LIM_STATUS=OEM_REPLY

END
