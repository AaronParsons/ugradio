function monthnr2monthname, month, inverse=inverse

;+
;NAME: monthnr2monthname
;
;CALLING SEQUENCE
;   monthname = monthnr2monthname( monthnr)
; or
;   monthnr = monthnr2monthname( monthname, /inverse)
;
;  if INVERSE not set, converts monthnr (1 to 12) to 3-letter
;        monthname. 
;  if INVERSE is set, it converts 3-letter month name to monthnr
;-

monthname_vec0= ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', $
                'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
monthname_vec1= ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', $
                'aug', 'sep', 'oct', 'nov', 'dec']
monthname_vec2= ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', $
                'AUG', 'SEP', 'OCT', 'NOV', 'DEC']

if keyword_set( inverse) then begin
indx= where( monthname_vec0 eq month, nr)
if nr ne 1 then indx= where( monthname_vec1 eq month, nr)
if nr ne 1 then indx= where( monthname_vec2 eq month, nr)
if nr eq 1 then monthnr=indx+1 else stop, 'invalid monthname!'
return, monthnr
endif

if month ge 1 and month le 12 then return, monthname_vec0[ month-1] $
   else print, 'Month nrs must lie between 1 and 12, inclusive; returning'

;return, 'XXX'

end
