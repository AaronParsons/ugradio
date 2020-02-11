import numpy as np
import ugradio.dft as dft
import matplotlib.pyplot as plt
import argparse
import unittest

class TestDFTModule(unittest.TestCase):
    
    def setUp(self):
        self.vsamp = 8e3; self.vsig = 2e3
        self.N = 1024
        self.t = np.linspace(-self.N/(2*self.vsamp),self.N/(2*self.vsamp),num=self.N,endpoint=False)
        self.xn = np.sin(2*np.pi*self.vsig*self.t) + np.cos(2*np.pi*self.vsig*self.t)
        self.f_fft = np.fft.fftshift(np.fft.fftfreq(self.N,1.0/self.vsamp))
        self.Xk_fft = np.fft.fftshift(np.fft.fft(self.xn))

    def test_dft_signal_input(self):
        f,Xk = dft.dft(self.xn,vsamp=self.vsamp)
        self.assertTrue(np.all(np.isclose(f, self.f_fft)), msg='Case 1: Frequency array mismatch between numpy fft and dft')
        self.assertTrue(np.all(np.isclose(Xk, self.Xk_fft)), msg='Case 1: Output mismatch')

    def test_dft_xn_t_input(self): 
        f,Xk = dft.dft(self.xn,t=self.t,vsamp=self.vsamp)
        self.assertTrue(np.all(np.isclose(f, self.f_fft)), msg='Case 2: Frequencies mismatch!')
        self.assertTrue(np.all(np.isclose(Xk, self.Xk_fft)),msg='Case 2: Output mismatch')

    def test_dft_xn_t_f_input(self): 
        f = np.linspace(-self.vsamp/2.,self.vsamp/2.,num=self.N,endpoint=False)
        f,Xk = dft.dft(self.xn,t=self.t,f=f)
        self.assertTrue(np.all(np.isclose(f, self.f_fft)), msg='Case 3: Frequencies mismatch!')
        self.assertTrue(np.all(np.isclose(Xk,self.Xk_fft)),msg='Case 3: Output mismatch')

    def test_dft_longer_f_input(self): 
        f = np.linspace(-self.vsamp/2.,self.vsamp/2.,num=2*self.N,endpoint=False)
        f,Xk = dft.dft(self.xn,t=self.t,f=f)
        
        f_fft = np.fft.fftshift(np.fft.fftfreq(2*self.N,1.0/self.vsamp))
        Xk_fft = np.fft.fftshift(np.fft.fft(self.xn,n=2*self.N))

        self.assertTrue(np.all(np.isclose(f, f_fft)), msg='Case 4: Frequencies mismatch!')
        #self.assertTrue(np.all(np.isclose(Xk,Xk_fft)),msg='Case 4: Output mismatch')

    def test_dft_shorter_f_input(self): 
        f = np.linspace(-self.vsamp/2.,self.vsamp/2.,num=self.N/2.,endpoint=False)
        f,Xk = dft.dft(self.xn,t=self.t,f=f)
        Xk = Xk/Xk.max()

        f_fft = np.fft.fftshift(np.fft.fftfreq(self.N//2,1.0/self.vsamp))
        Xk_fft = np.fft.fftshift(np.fft.fft(self.xn,n=self.N/2))
        Xk_fft = Xk_fft/Xk_fft.max()

        self.assertTrue(np.all(np.isclose(f, f_fft)), msg='Case 5: Frequencies mismatch!')
        self.assertTrue(np.all(np.isclose(Xk,Xk_fft)),msg='Case 5: Output mismatch')
        
class TestiDFTModule(unittest.TestCase):

    def setUp(self):
        self.vsamp = 8e3; self.vsig = 2e3
        self.N = 1024
        self.f = np.linspace(-self.vsamp/2.0, self.vsamp/2.0, num=self.N, endpoint=False)
        
        self.t = np.linspace(-self.N/(2.0*self.vsamp),self.N/(2.0*self.vsamp),num=self.N,endpoint=False)
        self.xn = np.sin(2*np.pi*self.vsig*self.t)
        f, self.Xk = dft.dft(self.xn, t=self.t, f=self.f)

        self.t_fft = np.fft.ifftshift(np.fft.fftfreq(self.N,1.0*self.vsamp/self.N))
        self.xt_fft = np.fft.ifftshift(np.fft.ifft(np.fft.fftshift(self.Xk)))

    def test_idft_Xk_input(self):
        t,xt = dft.idft(self.Xk,vsamp=self.vsamp)
        self.assertTrue(np.all(np.isclose(t, self.t_fft)),msg="Case 6: Time through numpy fft and dft do not match!!")
        self.assertTrue(np.all(np.isclose(xt,self.xt_fft)),msg="Case 6: Output of numpy and dft mismatch")
        self.assertTrue(np.all(np.isclose(xt,self.xn)),msg="Case 6: dft output does not match input")         

    def test_idft_Xk_f_input(self):
        t,xt = dft.idft(self.Xk,f=self.f,vsamp=self.vsamp)
        self.assertTrue(np.all(np.isclose(t,self.t_fft)),msg="Case 7: Time through numpy fft and dft do not match!!")
        self.assertTrue(np.all(np.isclose(xt,self.xt_fft)),msg="Case 7: Output of numpy and dft mismatch")
        self.assertTrue(np.all(np.isclose(xt,self.xn)),msg="Case 7: dft output does not match input")

    def test_idft_Xk_f_t_input(self):
        t,xt = dft.idft(self.Xk,f=self.f,t=self.t)
        self.assertTrue(np.all(np.isclose(t,self.t_fft)),msg="Case 8: Time through numpy fft and dft do not match!!")
        self.assertTrue(np.all(np.isclose(xt,self.xt_fft)),msg="Case 8: Output of numpy and dft mismatch")
        self.assertTrue(np.all(np.isclose(xt,self.xn)),msg="Case 8: dft output does not match input")

if __name__ == '__main__':
    unittest.main()

