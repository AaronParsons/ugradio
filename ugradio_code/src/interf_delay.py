
# ugradio ***********************************************

import socket, serial, time, thread
PORT = 1421
HOST = '10.32.92.121'    # The remote host west

import time
import sys


class DelayClient:

    def delay_ns(self, data, verbose=False):
        '''Communicate with host server and return response as string.'''
        socket_data_out = data  
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect ((HOST,PORT))
        s.sendall(socket_data_out)
        response = "got it"
        return response
    
    def switch_relay(self, relay_number, state, verbose=False):
        relay_switch_data = relay_number + state
        '''Communicate with host server and return response as string.'''
        socket_data_out = relay_switch_data  
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect ((HOST,PORT))
        s.sendall(socket_data_out)
        response = "got it"
        return response
        
    def all_relays_off(self,verbose=False):
        '''Communicate with host server and return response as string.'''
        socket_data_out = 'all_relays_off'  
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect ((HOST,PORT))
        s.sendall(socket_data_out)
        response = "got it"
        return response




class DelayDirect:
    def write_relays(self, relay_config):

        import RPi.GPIO as GPIO 
        
        print 'the relay config=: ', relay_config
        if (relay_config[7]) == '0':
            relay_number_state = 'k0off'
            self.switch_relays(relay_number_state)
        if (relay_config[7]) == '1':
            relay_number_state = 'k0on'
            self.switch_relays(relay_number_state)

        if (relay_config[6]) == '0':
            relay_number_state = 'k1off'
            self.switch_relays(relay_number_state)
        if (relay_config[6]) == '1':
            relay_number_state = 'k1on'
            self.switch_relays(relay_number_state)
            
        if (relay_config[5]) == '0':
            relay_number_state = 'k2off'
            self.switch_relays(relay_number_state)
        if (relay_config[5]) == '1':
            relay_number_state = 'k2on'
            self.switch_relays(relay_number_state)

        if (relay_config[4]) == '0':
            relay_number_state = 'k3off'
            self.switch_relays(relay_number_state)
        if (relay_config[4]) == '1':
            relay_number_state = 'k3on'
            self.switch_relays(relay_number_state) 
            
        if (relay_config[3]) == '0':
            relay_number_state = 'k4off'
            self.switch_relays(relay_number_state)
        if (relay_config[3]) == '1':
            relay_number_state = 'k4on'
            self.switch_relays(relay_number_state)

        if (relay_config[2]) == '0':
            relay_number_state = 'k5off'
            self.switch_relays(relay_number_state)
        if (relay_config[2]) == '1':
            relay_number_state = 'k5on'
            self.switch_relays(relay_number_state)
            
        if (relay_config[1]) == '0':
            relay_number_state = 'k6off'
            self.switch_relays(relay_number_state)
        if (relay_config[1]) == '1':
            relay_number_state = 'k6on'
            self.switch_relays(relay_number_state)

        if (relay_config[0]) == '0':
            relay_number_state = 'k7off'
            self.switch_relays(relay_number_state)
        if (relay_config[0]) == '1':
            relay_number_state = 'k7on'
            self.switch_relays(relay_number_state) 

    


    def switch_relays(self, relay_number_state):
        import RPi.GPIO as GPIO
        int_relay_number = int(relay_number_state[1])
        relay_state = (relay_number_state[2:])
        if relay_state == 'off':
            int_relay_state = 0
        if relay_state == 'on':
            int_relay_state = 1      


# switch the state of individual relays based on command - relay_number_state

        #  KO
        if int_relay_number == 0:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(27, GPIO.OUT) # pin 13  
            if int_relay_state == 0:
                GPIO.output(27, False)
                print '<GPIO 27 Switch to Low - K0 Off>'        
            if int_relay_state == 1:
                GPIO.output(27, True)        
                print '<GPIO 27 Switch to High - K0 On>'

        #  K1
        if int_relay_number == 1:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(22, GPIO.OUT) # pin 15    
            if int_relay_state == 0:
                GPIO.output(22, False)
                print '<GPIO 22 Switch to Low - K1 Off>'        
            if int_relay_state == 1:
                GPIO.output(22, True)        
                print '<GPIO 22 Switch to High - K1 On>'


            #  K2
        if int_relay_number == 2:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(05, GPIO.OUT) # pin 29 
            if  int_relay_state == 0:
                GPIO.output(05, False)
                print '<GPIO 05 Switch to Low - K2 Off>'        
            if int_relay_state == 1:
                GPIO.output(05, True)        
                print '<GPIO 05 Switch to High - K2 On>'


            #  K3
        if int_relay_number == 3:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(06, GPIO.OUT) # pin 31
            print '>'
            print '>'    
            if int_relay_state == 0:
                GPIO.output(06, False)
                print '<GPIO 06 Switch to Low - K3 Off>'        
            if int_relay_state == 1:
                GPIO.output(06, True)        
                print '<GPIO 06 Switch to High - K3 On>'


            #  K4
        if int_relay_number == 4:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(13, GPIO.OUT) # pin 33
            if int_relay_state == 0:
                GPIO.output(13, False)
                print '<GPIO 13 Switch to Low - K4 Off>'        
            if int_relay_state == 1:
                GPIO.output(13, True)        
                print '<GPIO 13 Switch to High - K4 On>'


            #  K5
        if int_relay_number == 5:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(26, GPIO.OUT) # pin 37
            if int_relay_state == 0:
                GPIO.output(26, False)
                print '<GPIO 26 Switch to Low - K5 Off>'        
            if int_relay_state == 1:
                GPIO.output(26, True)        
                print '<GPIO 26 Switch to High - K5 On>'

            #  K6
        if int_relay_number == 6:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(18, GPIO.OUT) # pin 12
            if int_relay_state == 0:
                GPIO.output(18, False)
                print '<GPIO 18 Switch to Low - K6 Off>'        
            if int_relay_state == 1:
                GPIO.output(18, True)        
                print '<GPIO 18 Switch to High - K6 On>'

            #  K7
        if int_relay_number == 7:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(23, GPIO.OUT) # pin 16
            if int_relay_state == 0:
                GPIO.output(23, False)
                print '<GPIO 23 Switch to Low - K7 Off>'        
            if int_relay_state == 1:
                GPIO.output(23, True)        
                print '<GPIO 23 Switch to High - K7 On>'
                print ' '
                print '>'
   

# switch the state of individual relays based on command - relay_number_state

    def all_relays_off(self):           
        
        import RPi.GPIO as GPIO
        #  KO
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(27, GPIO.OUT) # pin 13
        print '>' 
        GPIO.output(27, False)
        print '<GPIO 27 Switch to Low - K0 Off>'

            
        #  K1
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(22, GPIO.OUT) # pin 15
        print '>'   
        GPIO.output(22, False)
        print '<GPIO 22 Switch to Low - K1 Off>'        


        #  K2
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(05, GPIO.OUT) # pin 29
        print '>'
           
        GPIO.output(05, False)
        print '<GPIO 05 Switch to Low - K2 Off>'        



         #  K3
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(06, GPIO.OUT) # pin 31
        print '>'
        GPIO.output(06, False)
        print '<GPIO 06 Switch to Low - K3 Off>'        


        #  K4
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(13, GPIO.OUT) # pin 33
        print '>'
        GPIO.output(13, False)
        print '<GPIO 13 Switch to Low - K4 Off>'        



        #  K5
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(26, GPIO.OUT) # pin 37
        print '>'
        GPIO.output(26, False)
        print '<GPIO 26 Switch to Low - K5 Off>'


        #  K6
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(18, GPIO.OUT) # pin 12
        print '>'
        GPIO.output(18, False)
        print '<GPIO 18 Switch to Low - K6 Off>'


        #  K7
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)
        GPIO.setup(23, GPIO.OUT) # pin 16
        print '>'
        GPIO.output(23, False)
        print '<GPIO 23 Switch to Low - K7 Off>'        
  
             
                  



class DelayServer(DelayDirect):
    def run(self, host='', port=PORT, verbose=False, timeout=10):
        self.verbose = verbose
        if self.verbose:
            print('Initializing..')
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.bind((host,port))
            s.listen(10)
            while True:
                conn, addr = s.accept()
                conn.settimeout(timeout)
                thread.start_new_thread(self._handle_request, (conn,))
        finally:
            s.close()

            
    def _handle_request(self, conn):
        # Private thread for handling an individual connection.  Will execute
        # at most one write and one read before terminating connection.
        socket_data_received = conn.recv(1024)

        socket_data_received = socket_data_received.decode('ascii')
        socket_data_received = socket_data_received.split('\n')   
        data = ''.join (socket_data_received)

        
        sentinel_char = (data[0]) #determine if the data is an individual relay switch command
        if sentinel_char == 'k':
#            print 'the sentinel_char=', sentinel_char
            self.switch_relays(data)
            
            # obj_DelayDirect = self.interf_delay.DelayDirect()
            # obj_DelayDirect .self.switch_relays(data)
            exit()

        if data == 'all_relays_off':
            self.all_relays_off()
            exit()
            

        time_ns = int(data)
        self.convert_delay_time(time_ns)

    def convert_delay_time (self, time_delay):

        # Determin the sign of the delay
        if  time_delay < 0:
            sign = False
        else:
            sign = True

        if time_delay >32 or time_delay < -32:
            print 'the value is out of range, please enter a number between -32 to +32: '
            exit()


            """
Conversion Explanation:

the number of bits are 128 (2 to the power of 7)
Range is +-32 nano seconds = 64 nano seconds total
bits/ns = 64/128 = 0.5ns/bit
number of bits = delay_total/0.5
The delay value is referenced to +32ns delay

After the number of bits have been calculated, convert the decimal number of bits into a
a binary number.  Take the seven bit binary number and using a shift
register function, shift all seven bits to the left.  Then, Xor the original 7 bit binary number to the
new 8 bit binary number (8 bits produced by the left shift register function)
The 8 bit Xor result will be applied to the individual relay circuits.

"""

        if sign == True:
            delay_total = 32 - time_delay
#            print "<the time delay is positive and the total time delay is>", (delay_total)
    

        if sign == False:
            delay_total = abs(time_delay) +32
#            print "<the time delay is negative and the total time delay is>", (delay_total)

        number_of_bits = delay_total/0.5
#        print "<the number of bits>", (number_of_bits)
        number_of_bits

        number_of_bits = int(number_of_bits)
        if number_of_bits == 128:
            number_of_bits = 127
        binary_value = bin(number_of_bits)


# Remove the b character embedded with the binary work produced in the bin() function
        binary_value_modified =  binary_value.replace('b', '0')
        binary_value = binary_value_modified


# process binary number to a usable relay drive configuration

#set registers
        R0= '0' ; R1 = '0' ; R2 = '0' ; R3= '0' ; R4 = '0' ; R5 = '0' ; R6 = '0' ; R7 = '0'

        binary_num_index = (len (binary_value))
#        print 'binary_num_index', (binary_num_index)

        index = 1
        if binary_num_index >= index:
            R0 = binary_value[-1]
            index = index +1
        if binary_num_index >= index:
            R1 = binary_value[-2] 
            index = index +1
        if binary_num_index >=   index:
            R2 = binary_value[-3]  
            index = index +1
        if binary_num_index >= index:
            R3 = binary_value[-4]
            index = index +1
        if binary_num_index >=  index:
            R4 = binary_value[-5]
            index = index +1
        if binary_num_index >= index:
            R5 = binary_value[-6] 
            index = index +1
        if binary_num_index >= index:
            R6 = binary_value[-7] 
            index = index +1
#        print ' R7=',(R7),' R6=',(R6),' R5=',(R5),' R4=',(R4),' R3=',(R3),' R2=',(R2),' R1=',(R1),' R0=',(R0)

# Proform a left shift register function
        R7_post_shift = R6 ; R6_post_shift = R5 ; R5_post_shift = R4 ; R4_post_shift = R3
        R3_post_shift = R2 ; R2_post_shift = R1 ;R1_post_shift = R0 
        R0_post_shift = '0'

# type R0 through R7 and R0_post_shift through R7_post_shift from str to bool
#This is needed in order for the Xor function to work properly

        R0=bool(int(R0)) ; R1=bool(int(R1)) ; R2=bool(int(R2)) ; R3=bool(int(R3)) ; R4=bool(int(R4))
        R5=bool(int(R5)) ; R6=bool(int(R6)) ; R7=bool(int(R7)) 

        R0_post_shift = bool(int(R0_post_shift)) ; R1_post_shift = bool(int(R1_post_shift))
        R2_post_shift = bool(int(R2_post_shift))  ; R3_post_shift = bool(int(R3_post_shift)) 
        R4_post_shift = bool(int(R4_post_shift))  ; R5_post_shift = bool(int(R5_post_shift))  
        R6_post_shift = bool(int(R6_post_shift)) ; R7_post_shift = bool(int(R7_post_shift)) 

        

# Perform Xor function
        k0 = R0 ^ R0_post_shift ; k1 = R1 ^ R1_post_shift ; k2 = R2 ^ R2_post_shift 
        k3 = R3 ^ R3_post_shift ; k4 = R4 ^ R4_post_shift ; k5 = R5 ^ R5_post_shift  
        k6 = R6 ^ R6_post_shift ; k7 = R7 ^ R7_post_shift


#convert k0 through k7 from bool to int
        k0 = int(k0); k1 = int(k1); k2 = int(k2); k3 = int(k3); k4 = int(k4); 
        k5 = int(k5); k6 = int(k6); k7 = int(k7)
        

#convert k0 through k7 from int to string
        k0 = str(k0); k1 = str(k1); k2 = str(k2); k3 = str(k3); k4 = str(k4); 
        k5 = str(k5); k6 = str(k6); k7 = str(k7)

# concatenate k1 through k7 into a binary represented string word
        relay_config = k7 + k6 + k5 + k4 + k3 + k2 + k1 + k0
#        print 'relay_config in calling program =',relay_config 
#        print 'the socket data received is:',relay_config
        resp = self.write_relays(relay_config)
        return relay_config
        


