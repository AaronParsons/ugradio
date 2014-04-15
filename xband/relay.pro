;+
; NAME:  
;	relay.pro
;
; PURPOSE:
;	This function determines which delay switches to
;	flip given a geometric delay in meters.
;
; CALLING SEQUENCE:
;	Result = RELAY(Delay [, West, East, Net, Error, Flip=])
;
; INPUTS:
;	Delay:	Geometrical delay in meters of the interferometer.  This
;		number may be positive of negative.  A positive number
;		indicates that the source is to the west of the meridian.
;		A negative number indicates that the source is to the
;		east of the meridian.
;
; OPTIONAL INPUTS:
;	West, East, Net, and Error:  Return the delay inserted in the 
;		west path, the delay inserted in the east path, the net 
;		delay of the delay lines, and the error of the net delay
;		from the actual delay, respectively.
;
; KEYWORDS:	
;	Flip:  Setting this keyword will intentionally reverse the output
;		of the delay lines.  The east output will go to the west
;		return cable and vice versa.
;
; PROCEDURE:	See comments in code.
;
; OUTPUTS:
;	This function returns a hexidecimal number as a string that 
;	represents the state of the delay switches for the delay given.
;
; EXAMPLE:
;	delay = -5.24623
;	hex_num = RELAY(delay)
;
; MODIFICATION HISTORY:
;	Written by Curtis Frank, March 26, 1998
;	West, East, Net, Error and Flip added by CF, 3/31/98
;-


function relay, free_delay, west_loop, east_loop, result_delay, delay_error, flip=flip

;  Initialize delay line lengths.  Note that these are the
;  FREE SPACE equivalents of the physical delay line lengths.
delay = [5.0, 2.5, 1.25, 0.625, 0.3125, 0.15625, 0.078125]
temp = size(delay)
num = temp[1] + 1


;  Example:  If any one bit is set to WEST_DELAY, the west dish
;  signal will be sent through the long delay line following the
;  swtich corresponding to that bit.  Vice versa for setting
;  a bit to EAST_DELAY.
WEST_DELAY = 1
EAST_DELAY = 0



;  Initialize array which contains what loops the program determines
;  the west signal will go through and the array containing the
;  the relay states.  Initialize to no delay for the west dish.
loop = make_array(num - 1, /integer, value = EAST_DELAY)
relay = make_array(num, /integer, value = EAST_DELAY)



;  A positive delay is one with the source at a positive hour
;  angle, and requires the west dish have a cable delay.  
;  A negative delay is one with the source at a negative hour
;  angle, and requeres the east dish have a cable delay.

;  Determine what delay loops the west dish signal will go through.
;  This is done by adding or subtracting delay such that the total
;  delay in the system up to and including the geometric delay and the 
;  delay line in any particular iteration of the 'for' loop is less
;  than the delay of the cable in that iteration of the 'for' loop.
;  For example, let the geometric delay be +4 m (we need to delay the
;  west dish's signal).  The free space delay of the first delay cable
;  is 5 m.  This cable would be inserted into the west dish's path,
;  resulting in a net delay of -1 m (we need to delay the east dish's
;  path by 1 m.)  The absolute value of the resulting delay is less
;  than the delay of the cable we inserted.  Got it? 
prev_delay = free_delay ;  Keep free_delay as was given to the program.
west_loop = 0.0
east_loop = 0.0
for count = 0, num - 2 do begin
	net_delay = prev_delay + delay[count]
	if abs(net_delay) GT delay[count] then begin
		net_delay = prev_delay - delay[count]
		loop[count] = WEST_DELAY
	endif
	if loop[count] EQ EAST_DELAY then east_loop = east_loop + delay[count] $
		else west_loop = west_loop + delay[count] 
	;print, net_delay, prev_delay, delay[count], loop[count], count
	prev_delay = net_delay
endfor



;  Calculate some of the returned variables
result_delay = west_loop - east_loop
delay_error = free_delay - result_delay



;  Now the fun part.  Determine which relays get flipped by considering where
;  the signal comes from and where it goes to.  The first relay doesn't need
;  special consideration since the west and east signals are always entering
;  the switch by the same port.  There are four cases to consider.  West signal
;  coming from:
;	1)  a delay cable and going to a delay cable,
;	2)  a delay cable and going to a non-delay cable,
;	3)  a non-delay cable and going to a delay cable,
;	4)  a non-delay cable and going to a non-delay cable.
;  These cases are treated in this order.
relay[0] = loop[0]
for count = 1, num - 2 do begin
	case 1 of
		(loop[count - 1] EQ 1) AND (loop[count] EQ 1):  relay[count] = 0
		(loop[count - 1] EQ 1) AND (loop[count] EQ 0):  relay[count] = 1
		(loop[count - 1] EQ 0) AND (loop[count] EQ 1):  relay[count] = 1
		(loop[count - 1] EQ 0) AND (loop[count] EQ 0):  relay[count] = 0
		else:  print, "Bummer."
	endcase
endfor




;  Finally, make sure that the west signal goes back to the west channel.
;  If the number of relays flipped is odd, the signals will go back in the
;  wrong channels.  (west will be in east and east in west)  Flip the
;  last relay around to correct this.
count = 0
trash = where (relay EQ 1, count)
if (count mod 2) EQ 1 then relay[num - 1] = 1

if keyword_set (flip) then begin
	if relay[num - 1] EQ 1 then relay[num - 1] = 0 else relay[num - 1] = 1
endif

;print, ""
;print, "Free Space Delay:  ", free_delay
;print, "Loops Selected:  ", loop
print, "Relays Selected:  ", relay
;print, "Delay Error:  ", strtrim(net_delay, 2), " input units."
;print, ""



;  Change binary number represented in 'relay' array into
;  a hexidecimal number.  Return hex number as a string
deci =	 1 * relay[0] +  2 * relay[1] +  4 * relay[2] +   8 * relay[3] + $
	16 * relay[4] +	32 * relay[5] +	64 * relay[6] +	128 * relay[7]



;  to_hex is a goddard routine.
return, string(to_hex(deci))

end
