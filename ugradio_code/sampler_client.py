
import socket
import sys
import matplotlib.pyplot as plt 
import numpy as np

divisor_string = '2'
dual_mode = 1
channel_string = '1 1'
number_of_samples_string = '16000'
number_of_spectra_string = '5'

confirm_selection = 0
while confirm_selection == 0:
    valid_input = 0
    print ' ---------------- Voltage Range Selection ----------------'
    print ' '
    print '1. 50mV'
    print '2. 100mV'
    print '3. 200mV'
    print '4. 500mV'
    print '5. 1V'
    print '6. 2V'
    print '7. 5V'
    print '8. 10V'
    print '9. 20V'
    print ' '



    while valid_input == 0:
        print '* Select 1 through 9, then enter'
        print '* Press a for about, then enter'
        print ' '
        selection = raw_input (' select: ')
        print ' '
        if selection == 'a':
            sys.exit()
        if selection in ('1','2','3','4','5','6','7','8','9'):      
            valid_input = 1
        else:
            print '<Not a valid selection, try again> '
            print ' '

    if  selection == '1':
        voltrange = '50mV'
        print '<Selected voltage range is: 50mV>'

    if  selection == '2':
        voltrange = '100mV'
        print '<Selected voltage range is: 100mV>'

    if  selection == '3':
        voltrange = '200mV'
        print '<Selected voltage range is: 200mV>'

    if  selection == '4':
        voltrange = '500mV'
        print '<Selected voltage range is: 500mV>'

    if  selection == '5':
        voltrange = '1V'
        print '<Selected voltage range is: 1V>'

    if  selection == '6':
        voltrange = '2V'
        print '<Selected voltage range is: 2V>'

    if  selection == '7':
        voltrange = '5V'
        print '<Selected voltage range is: 5V>'

    if  selection == '8':
        voltrange = '10V'
        print '<Selected voltage range is: 10V>'

    if  selection == '9':
        voltrange = '20V'
        print '<Selected voltage range is: 20V>'

    print ' '
    selection = ' '
    print '* If the selection is correct, press y then enter to continue'
    print '* Press enter to try again '
    print '* Press a for about, then enter'
    print ' '
    selection = raw_input ('Select : ')
    if selection == 'a':
	    sys.exit()	
    if selection == 'y':
        confirm_selection = 1

		
confirm_selection = 0	
while confirm_selection == 0:
    valid_input = 0
    while valid_input == 0:
        print ' '
        print ' '
        print '----------- Dual Mode on/off ------------------'
        selection = ' '
        print '* Press 1 turn on dual mode, 2 dual mode off'
        print '* Press a for about, then enter'
        print ' '
        selection = raw_input ('Select : ')
        if selection == 'a':
	        sys.exit()	
        if selection == '1' or selection == '2':
            valid_input = 1
            if selection == '1':
                channel_string = '1 1'
                dual_mode = 1
                print ' '
                print 'You have turned on dual mode'
                print ' '
            if selection == '2':
                dual_mode = 0
                channel_string = '1 0'
                print ' '
                print 'You have turned off dual mode'
                print ' '				
        else:
            print ' '
            print 'No valid selection, start over'
            print ' '
        
    selection = ' ' 
    print '* If the selection is correct, press y then enter to continue'
    print '* Press enter to try again '
    print '* Press a for about, then enter'
    print ' '
    selection = raw_input ('Select : ')
    if selection == 'a':
        sys.exit()	
        print ' '
    if selection == 'y':
        confirm_selection = 1
		
confirm_selection = 0
while confirm_selection == 0:
    valid_selection = 0
    while valid_selection == 0:	
		
        print ' '
        print ' '
        print '----------- Number of Spectra ------------------'
        selection = ' '
        print '* Press 1 through 100 for the number of spectras'
        print '* Press a for about, then enter'
        print ' '
        selection = raw_input ('Select : ')
        if selection == 'a':
	        sys.exit()
        int_selection = int(selection) 
        if int_selection >= 1 and selection >= 100:
            valid_selection = 1
            print 'You have selected ', selection, ' spectra'
            number_of_spectra_string = selection
            print ' '
        else:
            print 'No valid selection, start over'
            print ''
            print ''			
    selection = ' '
    print '* If the selection is correct, press y then enter to continue'
    print '* Press enter to try again '
    print '* Press a for about, then enter'
    print ' '
    selection = raw_input ('Select : ')
    if selection == 'a':
        sys.exit()	
        print ' '
    if selection == 'y':
        confirm_selection = 1

print ' '
print ' '
print ' -------- selections --------------'
print ' '
print 'Voltage=', voltrange
if dual_mode == 1:
    print 'Dual mode=On'
if dual_mode == 0:
    print 'Dual mode=Off'
print 'The number of spectra =', number_of_spectra_string
print ' '

print '* If the selections are correct, press enter'
print '* Press a for about, then enter'
selection = ' '
selection = raw_input ('Select : ')
if selection == 'a':
    sys.exit()


string_out = channel_string + ' ' + voltrange + ' ' + divisor_string + \
' ' + number_of_samples_string + ' ' + number_of_spectra_string

	
# print 'the string out is: ', string_out
		

HOST = '10.32.92.95'     # Pulsar
PORT = 1340             # The same port as used by the server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))

string_out = channel_string + ' ' + voltrange + ' ' + divisor_string + \
' ' + number_of_samples_string + ' ' + number_of_spectra_string
print ' ' 
print 'the complete output string is: ', string_out
print ' '
# string_out = '1 1 1V 2 16000 5'
s.sendall(string_out)
data = ''
while True:
    recvd = s.recv(1024)
    if not recvd: break
    data += recvd
s.close()
filename = data
print 'the file is: ', filename
print ' '


with open(filename, 'rb') as f:
#    data = np.fromfile(f, dtype=np.float32)
	data = np.fromfile(f, dtype=np.int16)
#    data = np.reshape(data, [0, 16000])  
print (data)

print ('the datatype of data is: ', type(data))
print ('')
print ('')
plt.title('Picosampler')
plt.ylabel('y Axis')
plt.xlabel('x Axis')
#plt.xlim(57000,57100)
plt.plot(data.T) 
plt.show()# plot bin test

