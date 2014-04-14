PRO  IBOOT, VERBOSE=VERBOSE

IP_ADDR='128.168.1.121' ;IP Address of the NETEON serial to ethernet adapter.
PORT=8000 ;PORT on which the NETEON serial adapter is awaiting a connection


ARG=STRING(27B)+'76.2cm'+STRING(27B)+'n'+STRING(13B)
print,arg
IF VERBOSE EQ 1 THEN PRINT, 'Drive Going, Please Wait.'
IBOOT_REPLY=''
print,'about to socket'

SOCKET,SOCK_UNIT,IP_ADDR,PORT,/GET_LUN
print,'about to printf'
PRINTF,SOCK_UNIT,ARG
print,'finished printf'
WAIT,1
;#WRITEU,SOCK_UNIT,ARG
READF,SOCK_UNIT,IBOOT_REPLY

PRINT,'Response is:'+IBOOT_REPLY




CLOSE,SOCK_UNIT
FREE_LUN,SOCK_UNIT

END
