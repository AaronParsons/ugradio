;+
;purpose: do chi sq fit for the intercept, given trial values of a1 and a2.

for nrx= 0,199 do begin
for nry= 0,199 do begin

ydat = ydata - (dela1[nrx,nry]+ a[1])* time - (dela2[ nrx,nry] + a[2])* time^2

x_n = dblarr( 1, 4)
x_n[ 0,*] = 1.

xw_n = w ## x_n
yw_n = w ## ydat 

xxw_n = transpose( xw_n) ## xw_n
xyw_n = transpose( xw_n) ## yw_n
xxwi_n = invert( xxw_n)

a_n = xxwi_n ## xyw_n
ybarw_n = xw_n ## a_n
delyw_n = yw_n - ybarw_n

ybar_n = invert( w) ## xw_n ## a_n
dely_n = ydat - ybar_n
sigmasq = total( dely_n^2)/(m-n)

chisq_n[ nrx, nry] = total( delyw_n^2)

vardc_n = xxwi_n[ 0]    
sigdc_n = sqrt( vardc_n)

endfor
endfor

end
