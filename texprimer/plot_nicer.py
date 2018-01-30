import numpy as np, pylab as plt
x = np.linspace(-1,1,1024)
plt.figure(figsize=(3,3))
plt.subplots_adjust(left=.2, bottom=.15, right=.95, top=.9)
plt.plot(x, 3*x**3 + 2*x**2 + 1)
plt.xlabel('This is X', fontsize=12)
plt.ylabel('This is Y', fontsize=12)
plt.title('A Nicer Plot')
plt.savefig('nicer.pdf')
