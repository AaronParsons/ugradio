'''This script is started by start_dishserver and runs on a RPI
whose serial port is connected to the drive encoders for the
UGRadio Interferometer.'''

import socket
import sys
import datetime
import time
import calendar
import serial
import math

azEncOffset = 0
azEncScale = 11.5807213

elEncOffset = 4096 
elEncScale = 11.566584697

def initSocket(socketHost='',socketPort=1420):
    hostSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        hostSocket.bind((socketHost, socketPort))
    except socket.error as msg:
        print('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
        sys.exit()
    hostSocket.listen(10)
    return hostSocket

def initSerialPort(serialPort='/dev/ttyUSB0',baudRate=9600,timeoutLim=1):
    serialPort = serial.Serial(serialPort,baudRate,timeout=timeoutLim)
    return serialPort

#Function for handling connections. This will be used to create threads
def simpleDishCmd(serialPort,serialCmd):
    charLimit = 1024      
    #Receiving from client
    serialPort.write(serialCmd)
    time.sleep(0.1) # Let the configuration command make the change it needs
    charCount=0
    dishResponse = ''
    while True:
        responseChar = serialPort.read(1)
        responseChar = responseChar.decode('ascii')
        if responseChar == '\r' or responseChar == '' or charCount==charLimit:
            break
        dishResponse += responseChar
        charCount+=1
    #send back information
    return dishResponse

def initDish(serialPort):
    simpleDishCmd(serialPort,b'.a s r0xc8 257\r')
    simpleDishCmd(serialPort,b'.a s r0xcb 15000\r')
    simpleDishCmd(serialPort,b'.a s r0xcc 25\r')
    simpleDishCmd(serialPort,b'.a s r0xcd 25\r')
    simpleDishCmd(serialPort,b'.a s r0x24 21\r')
    simpleDishCmd(serialPort,b'.b s r0xc8 257\r')
    simpleDishCmd(serialPort,b'.b s r0xcb 15000\r')
    simpleDishCmd(serialPort,b'.b s r0xcc 25\r')
    simpleDishCmd(serialPort,b'.b s r0xcd 25\r')
    simpleDishCmd(serialPort,b'.b s r0x24 21\r')

def resetDish(serialPort):
    simpleDishCmd(serialPort,b'r\r')
    time.sleep(10)
    initDish(serialPort)

def waitAz(serialPort):
    azStatus = str(-1)
    maxWait = 120
    curWait = 0
    while curWait < maxWait:
        azStatus = simpleDishCmd(serialPort,b'.a g r0xc9\r').split()
        azStatus = azStatus[1]
        if azStatus == '0': break
        curWait += 1
        time.sleep(1)
    return azStatus

def waitEl(serialPort):
    elStatus = str(-1)
    maxWait = 120
    curWait = 0
    while curWait < maxWait:
        elStatus = simpleDishCmd(serialPort,b'.b g r0xc9\r').split()
        elStatus = elStatus[1]
        if elStatus == '0': break
        curWait += 1
        time.sleep(1)
    return elStatus


def getAz(serialPort):
    curAz = simpleDishCmd(serialPort,b'.a g r0x112\r').split()
    curAz = float(int(curAz[1]))%(2.0**14)
    curAz = str(((curAz-azEncOffset)*(360.0)/(2.0**14))%360)
    return curAz

def getEl(serialPort):
    curEl = simpleDishCmd(serialPort,b'.b g r0x112\r').split()
    curEl = float(int(curEl[1]))%(2.0**14)
    curEl = str((curEl-elEncOffset)*(360.0)/(2.0**14))
    return curEl

def moveAz(serialPort,dishAz):
    azResponse = waitAz(serialPort)
    if azResponse != '0':
        return 'e 1'
    dishAz = (dishAz + 360.0 % 360)
    curAz = int(float(getAz(serialPort))*(2.0**14)/360)
    azMoveCmd =  '.a s r0xca ' + str(int((((dishAz*(2.0**14)/(360.0)))-curAz)*azEncScale)) + '\r'
    simpleDishCmd(serialPort,azMoveCmd.encode('ascii'))
    dishResponse = simpleDishCmd(serialPort,b'.a t 1\r')
    return dishResponse

def moveEl(serialPort,dishEl):
    elResponse = waitEl(serialPort)
    if elResponse != '0':
        return 'e 1'
    if (dishEl < 0) or (dishEl > 175):
        return 'e 1'
    curEl = int(float(getEl(serialPort))*(2.0**14)/360)
    elMoveCmd =  '.b s r0xca ' + str(int((((dishEl*(2.0**14)/(360.0)))-curEl)*elEncScale)) + '\r'
    simpleDishCmd(serialPort,elMoveCmd.encode('ascii'))
    dishResponse = simpleDishCmd(serialPort,b'.b t 1\r')
    return dishResponse

def talkToDish(conn):
    # Sending message to connected client
    # conn.send('Welcome to the server. Type something and hit enter\n') #send only takes string
      
    #Receiving from client
    moveCmd = conn.recv(1024)#.decode('ascii')
    moveCmd = moveCmd.split()
    moveCmd.extend(['0','0'])
    print (moveCmd)
    if not moveCmd:
        return
    cmdType = moveCmd[0]
    cmdAz = int(moveCmd[1])
    cmdEl = int(moveCmd[2])
    time.sleep(0.5) # Let the configuration command make the change it needs
    conn.sendall((cmdType + str(cmdAz) + str(cmdEl)).encode('ascii'))
    #come out of loop
    conn.close()

def main():
    # Begin main part of the script
    print('Initializing socket...')
    socketPort = initSocket()
    print('done.')
    print('Initializing serial port...')
    serialPort = initSerialPort()
    print('done.')
    print('Initializing dish...')
    resetDish(serialPort)
    print('done.')
    print('Configuration of server complete at ' + str(datetime.datetime.now()))
    sys.stdout.flush()
    while True:
        #wait to accept a connection - blocking call
        conn, addr = socketPort.accept()
        #set timeout for the socket connection
        conn.settimeout(135)
        dishCmd = conn.recv(1024)
        dishCmd = dishCmd.decode('ascii')
        print('Connected with ' + addr[0] + ':' + str(addr[1]) + ' at ' + str(datetime.datetime.now()) + dishCmd)
        dishCmd = dishCmd.split('\n')
        dishResponse = b''
        if dishCmd[0] == 'simple':
            dishResponse = simpleDishCmd(serialPort,dishCmd[1].encode('ascii'))
        elif dishCmd[0] == 'moveAz':
            dishResponse = moveAz(serialPort,float(dishCmd[1]))
        elif dishCmd[0] == 'moveEl':
            dishResponse = moveEl(serialPort,float(dishCmd[1]))
        elif dishCmd[0] == 'waitAz':
            dishResponse = waitAz(serialPort)
        elif dishCmd[0] == 'waitEl':
            dishResponse = waitEl(serialPort)
        elif dishCmd[0] == 'getAz':
            dishResponse = getAz(serialPort)
        elif dishCmd[0] == 'getEl':
            dishResponse = getEl(serialPort)
        elif dishCmd[0] == 'reset':
            dishResponse = resetDish(serialPort)
        else:
            dishResponse = ''
        conn.sendall(dishResponse.encode('ascii'))
        conn.settimeout(None)
        conn.close()
        sys.stdout.flush()
    return True

if __name__ == "__main__":
    while True:
        try:
            main()
        except:
            print('Dish server crashed -- restarting server')
            sys.stdout.flush()
            time.sleep(1)

            

#s.close()

