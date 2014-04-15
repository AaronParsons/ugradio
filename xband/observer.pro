;+
; NAME:  
;	observer.pro
;
; PURPOSE:
;	This procedure performs observation scripts, an example of which
;	is given in observe.scrpt.  
;
; DISCUSSION:
;	The observation scripts contain 6 columns:
;		Column 1:  Source RA (hh:mm:ss)
;		Column 2:  Source dec (dd:mm:ss)
;		Column 3:  Starting LST for this source (hh:mm:ss)
;		Column 4:  Stopping LST for this source (hh:mm:ss)
;		Column 5:  Source name
;		Column 6:  Time between points (seconds)
;
;	Stopping this procedure after observations are complete is accomplished
;	by duplicating the last line of the file and making the following changes:
;		1)  Change the LST start time to the LST stop time of the
;		    last observation.
;		2)  Change the LST stop time to the new LST start time plus
;		    one minute.
;		3)  Change the source name to 'stop'.
;	This will exit the observer procedure and stow the dishes.  For example,
;	to end an observation after Virgo, the end of the observe script would be:
;		12:30:44   12:24:06   09:00:00   16:18:00   Virgo   20
;		12:30:44   12:24:06   16:18:00   16:19:00   stop    20
;
;	The sixth column, time between points, may be useful for pointing near
;	the zenith.
;
; CALLING SEQUENCE:
;	OBSERVER, 'fname'
;
; INPUTS:
;	fname:	filename of observation script
;
; OUTPUTS:
;	Outputs are only to the standard out (screen) and contain current
;	program execution status including source currently observed.
;
; RESTRICTIONS:
;	The observation script can be of any length, in any order, as long 
;	as there are no overlapping LST starting and stopping times.  If 
;	there are overlapping times, this procedure will execute, but the
;	overlapped source may not be observed as scheduled or at all.
;
;	The user MUST put a break in the observation script at midnight, LST.
;	If it is desired to observe Cygnus for example, through midnight, structure
;	the observe script as follows:
;		19:59:24   40:43:53   20:00:00   24:00:00   Cygnus   20
;		19:59:24   40:43:53   00:00:00   03:00:00   Cygnus   20
;
;	The number of columns in the observe script must remain the same.
;		
; EXAMPLE:
;	OBSERVER, 'observ.scrpt'
;
; MODIFICATION HISTORY:
;	Written by Curtis Frank, November 23, 1997
;	Documented, CF, 12/15/97
;	Included reverse option as a workaround: CH, 5 april 2001.
;
;-


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Observation procedure that takes its parameters
;  from an observation file in the following
;  format:
;  Column 1:  ra (hh:mm:ss)
;  Column 2:  dec (dd:mm:ss)
;  Column 3:  lst start time (hh:mm:ss) for this source
;  Column 4:  lst stop (hh:mm:ss) time for this source
;  Column 5:  source name 
;  Column 6:  time between points (seconds)
;  
;  To call from IDL prompt:  
;	IDL> observer, 'observe_now.scrpt'
;
;  By:  Curtis Frank
;  November 23, 1997
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


pro observer, fname

;  Definitions
aa=make_array(2)
sleeptime = 20.0  ;time to wait between pointings.

;  Read in observation script. format='A,A,A,A,A,F' tells
;  readcol to read in strings and a float.
readcol, fname, str_ra, str_dec, str_lst_start, str_lst_stop, source, sleeptime, format = 'A,A,A,A,A,F'

;  Make arrays
n_sources = size(str_ra)
ra = make_array(n_sources[1])
dec = make_array(n_sources[1])
lst_start = make_array(n_sources[1])
lst_stop = make_array(n_sources[1])

;  Convert ra, dec, lst_start, lst_stop to floating point decimal equivalents.
;  This bab2deg doesn't take array of strings!!!
for i = 0, n_sources[1] - 1 do begin
	ra[i] = float(bab2deg(str_ra[i]))
	dec[i] = float(bab2deg(str_dec[i]))
	lst_start[i] = float(bab2deg(str_lst_start[i]))
	lst_stop[i] = float(bab2deg(str_lst_stop[i]))
endfor



;  Main Loop
observed_count = 0
go_flag = 1
while (go_flag) do begin
	i = 0

	;  Set up the LST and time zero points.
	spawn, '/home/ay120b/bin/lst', lstr21
	lstr21size = size(lstr21)
	lstr2 = lstr21[lstr21size[1]-1]
	print, 'Updating lst = ', lstr2
	lstzero = 3600.0 * bab2deg(lstr2)
	stdtimezero = systime(1)
	lstnow = (lstzero + 1.0027379*(systime(1)-stdtimezero) )/3600.
	lstnow = lstnow mod 24.0

	for i = 0, n_sources[1] - 1 do begin
		print, source[i], '	ra dec:  ', strtrim(ra[i], 1), ' ', strtrim(dec[i], 1), '	start stop:  ', strtrim(lst_start[i], 1), ' ', strtrim(lst_stop[i], 1), '	now:  ', strtrim(lstnow, 1)

;		Check if 'stop' is the current source
		if (lstnow GT lst_start[i]) and (lstnow LT lst_stop[i]) and (source[i] EQ 'stop') then begin
			go_flag = 0
		endif

;		If the lst is between the start and stop lst's from the file, then point to the source.
		while (lstnow gt lst_start[i]) and (lstnow lt lst_stop[i]) and (go_flag) do begin
			lstnow = (lstzero + 1.0027379*(systime(1)-stdtimezero) )/3600.
			lstnow = lstnow mod 24.0
			ha = 15.0 * (lstnow - ra[i])
			aa = hd2aa (ha, dec[i])
			print, source[i], lstnow, aa[0], aa[1]
			IF ( (aa[1] gt 315.) or  (aa[1] lt 52.)) then begin
			result = point2(alt=aa[0], az=aa[1], /reverse)
			ENDIF else result = point2(alt=aa[0], az=aa[1])
			wait, sleeptime[i]
		endwhile
	endfor
	wait, 60.0
	print, ''
endwhile

;  Stow the dishes because I'm done!
str = '/home/ay120b/bin/point2 stow'
spawn, str


end
