function read_262144_text, fname_string
;+
;  SYNTAX:  v_complex = read_horn_text('filename.txt')
;
;  INPUT:  'filename.txt' - a two column text file of voltages
;                           with 262144 rows
;
;  OUTPUT:  a complex voltage array with real=first column
;                                        imaginary=second column
;
;-

nsamp=262144L

openr, unit, fname_string, /get_lun

data=fltarr(2,nsamp)
readf, unit, data
free_lun, unit, /force
return, complex(data[0,*],data[1,*])

end
