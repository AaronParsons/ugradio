;+
; NAME:  
; 	point3.pro
;
; PURPOSE:
;	This procedure points the interferometer antenna.
;
; CALLING SEQUENCE:
;	Result = POINT2([alt = value] [,az = value] [,/stow] [,/maint]
;	                [,/home] [,/pos] [,/reverse] [,/forward] [,/nosend]
;			[,/nocorrect] [,/verbose] [,/help] [,/stop]
;			[,/noeast] [,/nowest])
;
; INPUTS:
;	No required inputs.  Without any inputs, a help screen in printed.
;
; KEYWORDS:
;	alt:	    The altitude to point to in decimal degrees.
;	az:	    The azimuth to point to in decimal degrees.
;	stow:	    Moves both antenna to the stow position 
;		    (alt = 90, az = 180)
;	maint:	    Moves both antenna to the maintenance position
;		    (alt = 10, az = 180)
;	home:	    All axes of both antenna seek the home indicator, then point
;		    to the stow position.
;	pos:	    Returns the positions of the antenna in sky coordinates if
;		    used alone.  If used with the /nocorrect keyword, this
;		    procedure returns the encoder angle from the home position, 
;		    corrected for reverse pointings.  The altitude range will: 
;		    0 < alt < 90 and the azimuth range is:  0 < az < 360.
;	reverse:    Forces the antenna to point in reverse mode.
;	forward:    Forces the antenna to point in forward mode.
;	nosend:	    Prevents transmission of commands to the pc's.  Bad messages
;		    are sometimes returned.  Ignore them.
;	nocorrect:  The positions given with alt= and az= are not corrected
;		    for mechanical antenna misalignments.
;	verbose:    Prints out useful (?) program information.
;	help:	    Prints out a help screen.
;	stop:	    Stops all tracking of the antenna.
;       noeast:     Only moves the West dish
;       nowest:     Only moves the East Dish
; OUTPUTS:
;	This procedure will return various codes depending on program
;	operation.  Ignore them.  The output is significant only when the
;	pos keyword is used, in which case the east alt, east az, west alt and
;	west az is returned in this order into an array.
;
; DISCUSSION:
;	Certain combinations of keywords make no sense.  For example,
;
;	result = point2(alt=xx.xx, az=yyy.yy, /reverse, /forward)
;
;	This procedure will happily do the best job it can with what it is given.
;	In this case, the antenna will point in forward mode.
;
; EXAMPLE:
;	result = POINT2(alt=34, az=225)
;
; MODIFICATION HISTORY:
;
;
;		
;       Written by Curtis Frank, January, 1998.  Based on the C
;       program ; point2.c.
;	
;	Added nocorrect keyword, CF, May 25, 1998.
;	Fixed pos keyword to work with nocorrect, CF, May 26, 1998.
;	Added forward keyword, CF, May 28, 1998.
;
;       Modified to use spawn for /home keyword, Erik Shirokoff, April 3,2001
;       move_it was also modified to use idlpc.so by ES on april 3,
;       2001
;       New format for CORRECT and point.config2.  These procedures
;       are now incompatible with their predecessors.  ES 5/2001
;
;       Added NOEAST and NOWEST keywords.
;       Tue Apr 9 15:03:13 2002, Erik Rosolowsky <eros@ttauri>
;
;-


function point3, $
                 stow=stow, $   ;  Sends antenna to stow position (alt=90 az=180)
                 maint=maint, $ ;  Sends antenna to maint position (alt=10 az=180)
                 home=home, $   ;  Antenna finds home indicators and stows
                 pos=pos, $     ;  Returns position of antenna--see documentation
                 reverse=reverse, $ ;  Forces reverse pointing
                 forward=forward, $ ;  Forces forward pointing
                 nosend=nosend, $ ;  Prevents transmission of commands
                 nocorrect=nocorrect, $	;  Prevents corrections of coordinates
                 verbose=verbose, $ ;  Prints useful (?) stuff
                 alt=alt, $
                 az=az, $
                 help=help, $
                 stop=stop, $
                 noeast = noeast, $
                 nowest = nowest, tense = tense

common point2_common, $
  TRUE, $
  FALSE, $
  POINT, $
  TRACK, $
  REVERSE_, $
  FORWARD_, $
  HOME_, $
  SKY_TO_ENC, $
  ENC_TO_SKY, $
  VERBOSE_, $
  NOSEND_, $
  NOCORRECT_

;  Definitions for all procedures and functions
TRUE = 1
FALSE = 0
POINT = 'point tense'
TRACK = 'track'
HOME_ = 'home'
SKY_TO_ENC = 0
ENC_TO_SKY = 1

;  Initializations
alt_e = -1.0
az_e = -1.0
alt_w = -1.0
az_w = -1.0

;  Set nosend common variable
NOSEND_ = keyword_set(nosend) ? TRUE : FALSE

;  Set verbose common variable
VERBOSE_ = keyword_set(verbose) ? TRUE : FALSE

;  Set reverse common variable
REVERSE_ = keyword_set(reverse) ? TRUE : FALSE

;  Set forward common variable
FORWARD_ = keyword_set(forward) ? TRUE : FALSE

;  Set nocorrect common variable
NOCORRECT_ = keyword_set(nocorrect) ? TRUE : FALSE

;  Set alt_e
if n_elements(alt) ne 0 then $
  alt_e = alt
;if keyword_set(alt) then $
;  alt_e = alt

;  Set az_e
if n_elements(az) ne 0 then $
  az_e = az
;if keyword_set(az) then $
;  az_e = az



;  Check for stow keyword and do it.
if keyword_set(stow) then begin
    msg = move_it(POINT, 90.0, 180.0, 90.0, 180.0, noeast = noeast,$
                  nowest = nowest)
    if (not(msg_check(msg)) OR VERBOSE_) then $
      print, msg
    return, 0
endif

;  Check for maint keyword and do it.
if keyword_set(maint) then begin
    msg = move_it(POINT, 11.0, 180.0, 11.0, 180.0, noeast = noeast,$
                  nowest = nowest)
    if (not(msg_check(msg)) OR VERBOSE_) then $
      print, msg
    return, 0
endif

;  Check for stop keyword and do it.
if keyword_set(stop) then begin
    msg = move_it(TRACK, 0.0, 0.0, 0.0, 0.0, noeast = noeast,$
                  nowest = nowest)
    if (not(msg_check(msg)) OR VERBOSE_) then $
      print, msg
    return, 0
endif


;  CHECK FOR HOME KEYWORD AND DO IT.
if keyword_set(home) then begin
    homer
    return, 0
endif

;turn on reverse if we are out of forward range
if n_elements(az) ne 0 then begin
;if keyword_set(az) then begin
    If ( (az gt 315.) or  (az lt 52.)) then REVERSE_=TRUE
endif

;  Check for alt/az and point to it.
if n_elements(az) ne 0 AND n_elements(alt) ne 0 then begin
;if keyword_set(az) AND keyword_set(alt) then begin ;  make sure both alt and az given
;	Check for altitude deadzone
    if (check_lims(alt_e, 180.0)) then begin
        msg = move_it(TRACK, 0.0, 0.0, 0.0, 0.0, noeast = noeast,$
                  nowest = nowest) ;  stop tracking if in deadzone.
        if (not(msg_check(msg)) OR VERBOSE_) then $
          print, msg
        return, 0
    endif
    
;	Assign alt and az to an alt and az for each dish.
    alt_w = alt_e
    az_w = az_e
    
;	Correct to encoder coordinates
    correct, SKY_TO_ENC, alt_e, az_e, alt_w, az_w
    
;	Check corrected coordinates for within limits
    if (check_lims(alt_e, az_e)) then begin
        msg = move_it(TRACK, 0.0, 0.0, 0.0, 0.0, noeast = noeast,$
                  nowest = nowest) ;  stop tracking
        if (not(msg_check(msg)) OR VERBOSE_) then $
          print, msg
        return, 0
    endif
    
    if (check_lims(alt_w, az_w)) then begin
        msg = move_it(TRACK, 0.0, 0.0, 0.0, 0.0, noeast = noeast,$
                  nowest = nowest)
        if (not(msg_check(msg)) OR VERBOSE_) then $
          print, msg 
        return, 0
    endif
;	Point those dishes!!!
   
    msg = move_it(POINT, alt_e, az_e, alt_w, az_w, noeast = noeast,$
                  nowest = nowest)
    if (not(msg_check(msg)) OR VERBOSE_) then $
      print, msg
    return, 0
endif


;  Check for pos keyword and find positions
if keyword_set(pos) then begin
    msg = move_it(POINT, -1.0, -1.0, -1.0, -1.0, noeast = noeast,$
                  nowest = nowest) ;  Get the position string from the pc
    result = msg_check(msg)     ;  Check the message.  Must begin with 'done'
    if (not(result) OR VERBOSE_) then $ ;  If result is false or verbose is true then...
      print, msg                ;  print the message
    
    if (result) then begin      ;  If result is true (good)
        parse_alt_az, msg, alt_e, az_e, alt_w, az_w ;  Parse retuned message into alts & azes
;stop
        correct, ENC_TO_SKY, alt_e, az_e, alt_w, az_w ;  Correct from encoder to sky coords
        return, [alt_e, az_e, alt_w, az_w] ;  return the coordinates
    endif
    return, -1
endif

;Print help if nothing else runs
print, ''
print, 'The Berkeley Undergraduate Radio Astronomy Observatory interferometer'
print, 'antenna pointing program.'
print, ''
print, 'Usage:	point2, [alt=,] [az=,] [/pos,] [/stop,] [/stow,] [/home,] [/reverse.] [/verbose,] [/nosend]'
print, '	alt=:	Altitude in decimal degrees.  Must be set with az keyword.'
print, '	az=:	Azimuth in decimal degrees.  Must be set with alt keyword.'
print, '	pos:	Returns the corrected position of the dishes.'
print, '	stop:	Stops all tracking.'
print, '	stow:	Stows the dishes.'
print, '	maint:  Points to the feed maintenance position.'
print, '	home:	Finds the home position of the dishes, then stows the dishes.'
print, '		May require to executions if dishes do not point to the stowed position.'
print, '	forward:	Forces telescopes to point in forward mode only.'
print, '	reverse:	Forces telescopes to point in reverse mode only.'
print, '	verbose:	Prints useful(?) information  Any coordinates printed by'
print, '			this argument are not corrected for pointing errors.'
print, '			Use the "pos" command.'
print, '	nosend:	Prevents the transmission of messages to the pc.'
print, '	nocorrect:  Prevents corrections of given alt/az sky coordinates into'
print, '		encoder coordinates.  Useful for determining pointing corrections.'
print, '	help:	Prints this message to the standard output (screen).'
print, ''


end


