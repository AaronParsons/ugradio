;pro dft_cos, in, length, out


in= findgen( 16)
in= abs( findgen(16)-8)

;SET UP AN ARBITRARY FREQ AXIS
nch= n_elements( in)
frq0z= findgen( nch)- nch/2l

;SET UP THE CORRESPONDING DELAY AXIS
frange= (max( frq0z)-min( frq0z))* float( nch)/float( nch-1)
delf= frange/nch
trange= 1./delf
tm0= trange* (findgen( nch)- (nch/2))/ nch
tm0= shift( tm0, nch/2l)

infft= fft( in)

;NOW MODIFY INFT...seet both re and imag!
indx= where( abs( tm0) gt .25, count)
print, 'count=', count

infftmod= infft
infftmod[ indx]= complex( 0.,0.)

infftmodft= fft( infftmod, /inverse)

print, minmax( float( infftmodft))
print, minmax( imaginary( infftmodft))

wset,0
plot,(float(infftmodft)- in),psym=-4

wset,1
plot,(float(infftmodft))
oplot, in, color=!red
