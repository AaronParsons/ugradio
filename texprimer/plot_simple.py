import numpy as np, pylab as plt
x = np.linspace(-1,1,1024)
plt.figure(figsize=(10,10))
plt.plot(x, 3*x**3 + 2*x**2 + 1)
plt.xlabel('This is X')
plt.ylabel('This is Y')
plt.title('An ugly plot')
plt.savefig('simple.pdf')
