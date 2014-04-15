function datopen, filename, square=square
;+
;  IMPORTANT - April 18, 2007 - fftcall was discovered to have an
;              error that caused the sqrt(power) to be saved
;              instead of the power.  
;              The optional keyword 'square' was added to improve
;              this problem.
;
;  Calling Sequence:
;  power = datopen('filename.tar.gz',/square)
;
;  Changed default behavior to square the FFT, to remove this behavior
;  set square = 0.  The square keyword is kept for backward compatability
;-

  if n_elements(square) eq 0 then square = 1

  file_delete, '.datopentemp', /recur, /allow_nonexistent
  spawn, "mkdir .datopentemp"
  command = "tar xzf " + filename + " --directory=./.datopentemp"
  spawn, command, result
  spawn, "cat ./.datopentemp/info.txt", results
  inf = strsplit(results[1], /extract)

  ;print, inf

  windsize = long(inf[3])

  data = fltarr(windsize)
  temp = fltarr(windsize) 
  GET_LUN, Unit

;  print, 'results ', results

  for i=2, n_elements(results)-1 do begin
    info = strsplit(results[i], /extract)
    openr, Unit, "./.datopentemp/" + info[0]
    formt = "(" + strtrim(string(windsize), 2) + '(F/))'
    readf, Unit, temp, format=formt
    if square eq 1 then temp=temp^2
    data = data + temp
    close, Unit
  endfor
  free_lun, Unit
  data = data / (n_elements(results)-2)
  data[0] = (data[1] + data[windsize-1]) / 2.
  data = shift(data, windsize/2.)

;cleanup
;  for i=2, n_elements(results)-1 do begin
;    info = strsplit(results[i], /extract)
;    file_delete, "./.datopentemp/" + info[0]
;endfor
;  stop
;   file_delete, '.datopentemp', /recur
;   spawn, "mkdir .datopentemp"
;   command = "tar xzf " + filename + " --directory=./.datopentemp"
;   spawn, command, result
;   spawn, "cat ./.datopentemp/info.txt", results
;   inf = strsplit(results[1], /extract)

;   windsize = long(inf[3])

;   data = fltarr(windsize)
;   temp = fltarr(windsize) 
;   GET_LUN, Unit

;   for i=2, n_elements(results)-1 do begin
;     info = strsplit(results[i], /extract)
;     openr, Unit, "./.datopentemp/" + info[0]
;     formt = "(" + strtrim(string(windsize), 2) + '(F/))'
;     readf, Unit, temp, format=formt
;     data = data + temp
;     close, Unit
;   endfor
;   free_lun, Unit

;   data = data / (n_elements(results)-2)
;   data[0] = (data[1] + data[windsize-1]) / 2.
;   data = shift(data, windsize/2.)

;cleanup
;  for i=2, n_elements(results)-1 do begin
;    info = strsplit(results[i], /extract)
;    file_delete, "./.datopentemp/" + info[0]
;endfor

  file_delete, '.datopentemp', /recur
;  stop
;  help, data
  return, data
end
