

import matplotlib.pyplot as plt 
import numpy as np

"""
with filetest as filetest.open("1514924002-1V-2sInt-4nSpec-2chan.int16.bin"):
  file_obj = filetest.readlines()
  dataArray = numpy.load(file_obj)
"""  

filename = "1514924002-1V-2sInt-4nSpec-2chan.int16.bin"
with open(filename, 'rb') as f:
#    data = np.fromfile(f, dtype=np.float32)
	data = np.fromfile(f, dtype=np.int16)
#    data = np.reshape(data, [0, 16000])  
print (data)

print ('the datatype of data is: ', type(data))
print ('')
print ('')
plt.title('title test')
plt.ylabel('y axis')
plt.xlabel('x axis')
#plt.xlim(57000,57100)
#data = np.reshape(data, [57000, 58000]) 
plt.plot(data.T) 
# plt.axis('scaled')
plt.show()# plot bin test



#path= "1514924002-1V-2sInt-4nSpec-2chan.int16.bin"
#dataArray= np.load(path)

"""
test= dataArray.shape
print(test)
print (dataArray)
print (dataArray.shape)
plt.plot(dataArray.T) 
plt.show()# plot bin test


with file as file.open(filename):
  file_obj = file.readlines()
  bar = numpy.load(file_obj

  
with f as file.open(filename):
  foo = f.readlines()
  bar = numpy.load(foo)

  
  
filename = '/home/lijiao/Documents/transform/Data/AHI8_OBI_1000M_NOM_20160812_0040.hdf_B1.dat'

with open(filename, 'rb') as f:
data = np.fromfile(f, dtype=np.float32)
array = np.reshape(data, [11000, 11000])  
  
  
  
  
"""  
