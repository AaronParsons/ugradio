;+
; savephotons.pro
;
; SYNTAX:
; result=savephotons(nsamples=100, dt=2, filename='data.txt')
;
; result=0    (if no data was saved)
; result=1    (if data was saved)
;
; DESCRIPTION:  savephotons will request data from the Linux-computer called rphot. 
; The saved file will have a single column of integers.  The number
; of integers will equal nsamples.  Each integer represents the
; total photons counted during a period of dt.
; 
; DEFAULT: nsamples=100
;          dt = undefined [milliseconds]
;          filename=photons.nsamples.dt.txt
;
; RESTRICTIONS:   0 <  nsamp  < 5e5
;                 .2 <=  rate  <= 10,000 ms
;                 0 <= counts < 65535
;
; ISSUES:  if result=0 and there is a message "error making
; connection", then rphot probably doesn't have it's server running.
; ssh ugastro@10.32.92.5   and type "startnet"
;-
function savephotons, nsamples=nsamples, dt=dt, rate=rate, filename=filename

;See if dt or rate is given, can use keyword set because we don't want zeroes
if not keyword_set(dt) and not keyword_set(rate) then begin
    print, 'No data saved: dt or rate must be given'
    return, 0
endif

if keyword_set(nsamples) then begin
    if (nsamples gt 5e5) then begin
        print, "No data saved:  nsamples is greater than 5e5"
        return, 0
    endif
    n=strcompress(nsamples,/remove)
endif else n=strcompress(100,/remove)

if n_elements(dt) gt 0 then begin
    if (dt gt 10000. or dt lt .2) then begin
        print, 'No data saved:  use .2 ms < dt < 10,000 ms'
        return, 0
    endif
    ;sendpc requires a rate, not a dt, so convert here
    ;note: actual rate used in sendpc will be a truncated version of hz
    hz = strcompress(1./(dt*.001),/remove)
    if n_elements(filename) gt 0 then begin fname=filename
    endif else fname='photon.'+n+'.'+strcompress(dt,/remove)+'.txt'
endif

if n_elements(rate) gt 0 then begin
    if (rate gt 5000. or rate le 0) then begin
        print, 'No data saved: use 0 Hz < rate < 5,000 Hz'
        return, 0
    endif
    hz = strcompress(rate,/remove)
    if n_elements(filename) gt 0 then begin fname=filename
    endif else fname='photon.'+n+'.'+hz+'.txt'
endif

cmd_string = 'echo counter nsamples='+n+' rate='+hz+ $
  ' fname='+fname+' | /home/global/instrument/sendpc/sendpc'

print, 'Please wait, Acquiring Data'
spawn, cmd_string, something_returned, /stderr
if something_returned eq "error making connection" then begin
    print, 'Data not saved, '+something_returned
    return, 0
endif else begin
    print, 'Data saved in file:   ', fname
    return, 1
endelse
END
