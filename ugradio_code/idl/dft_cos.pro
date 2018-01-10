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

insym= [in, in[ nch-1], reverse( in[ 1:nch-1]) ]
tm0sym= [tm0, tm0[ nch-1], reverse( tm0[ 1:nch-1]) ]

insymft= fft( insym)
inft= float( insymft[ 0: nch-1])

;NOW MODIFY INFT...
inftmod= inft

inftmodsym= [inft, inft[ nch-1], reverse( inft[ 1:nch-1]) ]

;inftmodsym[*]=0.
inftmodsym[ 16]=-0.0313

inftmodsymft= fft( inftmodsym, /inverse)

print, minmax( float( inftmodsymft))
print, minmax( imaginary( inftmodsymft))

wset,0
plot,(float(inftmodsymft)- in),psym=-4

wset,1
plot,(float(inftmodsymft)),psym=-4;, xra=[0,17], /xsty
