import numpy as np

def dft(xn,N=None):
    """
    Input 
    -----
    x: input array
    N: number of output frequency channels, default= size(x)
    
    Output
    ------
    Xk: The discrete fourier transform of the input array    

    """
    if not (N):
        N = np.size(xn)
    if (N%2 ==0):
        chan = np.linspace(-N/2,N/2,num=N,endpoint=False)
    else:
        chan = np.linspace(-N/2,N/2,num=N)
    
    Xk = []
    for k in chan:
        temp = 0
        for n in range(np.size(xn)):
            temp += xn[n]*np.exp(2*np.pi*1j*n*k/N)
        Xk.append(temp)
    
    return Xk
