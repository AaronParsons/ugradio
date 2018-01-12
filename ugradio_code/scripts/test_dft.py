import numpy as np
import dft
import matplotlib.pyplot as plt

## Testing the dft procedure

vsamp = 8
vsig = 2
N = 1024
tol = 7 

t = np.linspace(-N/(2*vsamp),N/(2*vsamp),num=N,endpoint=False)
#xn = np.sin(t)
#xn = np.sin(2*np.pi*vsig*t) + np.cos(2*np.pi*vsig*t)
xn = np.random.random(N)
#xn = t>1

f_fft = np.fft.fftshift(np.fft.fftfreq(N,1.0/vsamp))
Xk_fft = np.fft.fftshift(np.fft.fft(xn))

print "Testing case 1: Just xn input."
f,Xk = dft.dft(xn,vsamp=vsamp)
if not np.all(f == f_fft):
    print "Case 1: Frequencies mismatch!"
if not np.all(np.round(Xk,decimals=tol)==np.round(Xk_fft,decimals=tol)):
    print "Case 1: Output mismatch at tolerance %d"%tol


print "Testing case 2: Input xn,t"
f,Xk = dft.dft(xn,t=t)
if not np.all(f == f_fft):
    print "Case 2: Frequencies mismatch!"
if not np.all(np.round(Xk,decimals=tol)==np.round(Xk_fft,decimals=tol)):
    print "Case 2: Output mismatch at tolerance %d"%tol


print "Testing case 3: Input xn,t,f"
f = np.linspace(-vsamp/2.,vsamp/2.,num=N,endpoint=False)
f,Xk = dft.dft(xn,t=t,f=f)
if not np.all(f == f_fft):
    print "Case 3: Frequencies mismatch!"
if not np.all(np.round(Xk,decimals=tol)==np.round(Xk_fft,decimals=tol)):
    print "Case 3: Output mismatch at tolerance %d"%tol


print "Testing case 4: len(f) > len(t)"
f = np.linspace(-vsamp/2.,vsamp/2.,num=2*N,endpoint=False)
f,Xk = dft.dft(xn,t=t,f=f)
f_fft = np.fft.fftshift(np.fft.fftfreq(2*N,1.0/vsamp))
Xk_fft = np.fft.fftshift(np.fft.fft(xn,n=2*N))
if not np.all(f == f_fft):
    print "Case 4: Frequencies mismatch!"
if not np.all(np.round(Xk,decimals=tol)==np.round(Xk_fft,decimals=tol)):
    print "Case 4: Output mismatch at tolerance %d"%tol
    print "Expected because the dft does not zero-pad"


print "Testing case 5: len(f) < len(t)"
f = np.linspace(-vsamp/2.,vsamp/2.,num=N/2.,endpoint=False)
f,Xk = dft.dft(xn,t=t,f=f)
Xk = Xk/Xk.max()
f_fft = np.fft.fftshift(np.fft.fftfreq(N/2,1.0/vsamp))
Xk_fft = np.fft.fftshift(np.fft.fft(xn,n=N/2))
Xk_fft = Xk_fft/Xk_fft.max()
if not np.all(f == f_fft):
    print "Case 5: Frequencies mismatch!"
if not np.all(np.round(Xk,decimals=tol)==np.round(Xk_fft,decimals=tol)):
    print "Case 5: Output mismatch at tolerance %d"%tol
    print "Expected due to difference in interpretation of numpy algo"


print "Testing case 6: idft Xf,t,f"
f = np.linspace(-vsamp/2.0,vsamp/2.0,num=N,endpoint=False)
t = np.linspace(-N/(2.0*vsamp),N/(2.0*vsamp),num=N,endpoint=False)
xn = np.sin(2*np.pi*vsig*t)
f,Xk = dft.dft(xn,t=t,f=f)

t,xt = dft.idft(Xk,f=f,t=t)

t_fft = np.fft.ifftshift(np.fft.fftfreq(1024,1.0*vsamp/N))
xt_fft = np.fft.ifftshift(np.fft.ifft(np.fft.fftshift(Xk)))
if not np.all(t == t_fft):
    print "Case 6: Time through numpy fft and dft do not match!!"
if not np.all(np.round(xt,decimals=tol)==np.round(xt_fft,decimals=tol)):
    print "Case 6: Output of numpy and dft mismatch at tolerance %d"%tol
if not np.all(np.round(xt,decimals=tol)==np.round(xn,decimals=tol)):
    print "Case 6: dft output does not match input at tolerance %d!"%tol


print "Testing case 7: idft Xf,f"
t,xt = dft.idft(Xk,f=f)
if not np.all(t == t_fft):
    print "Case 7: Time through numpy fft and dft do not match!!"
if not np.all(np.round(xt,decimals=tol)==np.round(xt_fft,decimals=tol)):
    print "Case 7: Output of numpy and dft mismatch at tolerance %d"%tol
if not np.all(np.round(xt,decimals=tol)==np.round(xn,decimals=tol)):
    print "Case 7: dft output does not match input at tolerance %d!"%tol


print "Testing case 8: idft Xf"
t,xt = dft.idft(Xk,vsamp=vsamp)
if not np.all(t == t_fft):
    print "Case 8: Time through numpy fft and dft do not match!!"
if not np.all(np.round(xt,decimals=tol)==np.round(xt_fft,decimals=tol)):
    print "Case 8: Output of numpy and dft mismatch at tolerance %d"%tol
if not np.all(np.round(xt,decimals=tol)==np.round(xn,decimals=tol)):
    print "Case 8: dft output does not match input at tolerance %d!"%tol
