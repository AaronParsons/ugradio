PRO CT2ALST, lst, lng, tz, tme, day, mon, year
;+
; NAME:
;     CT2ALST
; PURPOSE:
;     To convert from Local Civil Time to Local APPARENT Sidereal
;     Time. (See ct2lst to convert to local mean sidereal time.)
;
; CALLING SEQUENCE:
;     CT2ALST, Lst, Lng, Tz, Time, [Day, Mon, Year] 
;                       or
;     CT2ALST, Lst, Lng, dummy, JD
;
; INPUTS:
;     Lng  - The longitude in degrees (EAST of Greenwich) of the place for 
;            which the local sidereal time is desired, scalar.   The Greenwich 
;            sidereal time (GST) can be found by setting Lng = 0.
; **** -----> NOTE LNG IS ****EAST***** OF GREENWICH <----- *****
;     Tz  - The time zone of the site in hours.  Use this to easily account 
;            for Daylight Savings time (e.g. 4=EDT, 5 = EST/CDT), scalar
;            This parameter is not needed (and ignored) if Julian date is 
;            supplied.
;     Time or JD  - If more than four parameters are specified, then this is 
;               the time of day of the specified date in decimal hours.  If 
;               exactly four parameters are specified, then this is the 
;               Julian date of time in question, scalar or vector
;
; OPTIONAL INPUTS:
;      Day -  The day of the month (1-31),integer scalar or vector
;      Mon -  The month, in numerical format (1-12), integer scalar or 
;      Year - The year (e.g. 1987)
;
; OUTPUTS:
;       Lst   The Local Sidereal Time for the date/time specified in hours.
;
; RESTRICTIONS:
;       If specified, the date should be in numerical form.  The year should
;       appear as yyyy.
;
; PROCEDURE:
;       The Julian date of the day and time is question is used to determine
;       the number of days to have passed since 0 Jan 2000.  This is used
;       in conjunction with the GST of that date to extrapolate to the current
;       GST; this is then used to get the LST.    See Astronomical Algorithms
;       by Jean Meeus, p. 84 (Eq. 11-4) for the constants used.
;
; EXAMPLE:
;       Find the Greenwich apparent sidereal time (GAST) on 1988 April
;       10, 00 UT
;
;       For GAST, we set lng=0, and for UT we set Tz = 0
;
;       IDL> CT2ALST, lst, 0, 0, 0, 10, 4, 1988
;
;               ==> lst =  13.229376 (= 13h 13m 45.753s)
;
;       The astronomical almanac lists 13h 13m 45.7430s
;
;
; PROCEDURES USED:
;       jdcnv - Convert from year, month, day, hour to julian date
;       nutate - approximate longitude nutation 
;
; MODIFICATION HISTORY:
;     Adapted from the FORTRAN program GETSD by Michael R. Greason, STX, 
;               27 October 1988.
;     Use IAU 1984 constants Wayne Landsman, HSTX, April 1995, results 
;               differ by about 0.1 seconds  
;     Converted to IDL V5.0   W. Landsman   September 1997
;     Longitudes measured *east* of Greenwich   W. Landsman    December 1998
;     Slight modification to CT2LST by Erik Shirokoff, Oct 2001.
;-
 On_error,2

 if N_params() LT 3 THEN BEGIN
        print,'Syntax - CT2LST, Lst, Lng, Tz, Time, Day, Mon, Year 
        print,'                 or'
        print,'         CT2LST, Lst, Lng, Tz, JD
        return
 endif
;                            If all parameters were given, then compute
;                            the Julian date; otherwise assume it is stored
;                            in Time.
;

 IF N_params() gt 4 THEN BEGIN
   time = tme + tz
   jdcnv, year, mon, day, time, jd 
 ENDIF ELSE jd = double(tme)
;
;                            Useful constants, see Meeus, p.84
;
 c = [280.46061837d0, 360.98564736629d0, 0.000387933d0, 38710000.0 ]
 jd2000 = 2451545.0D0
 t0 = jd - jd2000
 t = t0/36525
;
;                            Compute GST in seconds.
;
 theta = c[0] + (c[1] * t0) + t^2*(c[2] - t/ c[3] )
;
;                            Compute LST in hours.
;
 lst = ( theta + double(lng))/15.0d
;
;                            add an approximate nutation term
;
nutate,jd,nlong,nlat ;nlong is longitude nutation in arc sec
nt=nlong/54000. ;convert to time hours
lst=lst+nt
;
;                            back to the CT2LST code
;
 neg = where(lst lt 0.0D0, n)
 if n gt 0 then lst[neg] = 24.D0 + (lst[neg] mod 24)
 lst = lst mod 24.D0

 RETURN
 END





