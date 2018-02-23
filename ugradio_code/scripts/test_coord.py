# Observing script to observe the sun for a day
from astropy.time import Time,TimeDelta
import astropy.units as u
import time
import ugradio.coord as coord
import numpy as np
import matplotlib.pyplot as plt
import ugradio.nch as nch

now = Time(time.time(),format='unix')
dt = TimeDelta(60*60,format='sec')
timearr = now + np.arange(24)*dt 
hrs = [(t.hour*60+t.minute) for t in (timearr-8*u.hour).datetime]

moon = np.zeros(2)
sun = np.zeros(2)
for t in timearr:
    moon = np.vstack((moon,coord.get_altaz(coord.moonpos(t.jd),jd=t.jd)))
    sun = np.vstack((sun,coord.get_altaz(coord.sunpos(t.jd),jd=t.jd)))
moon = moon[1:]
sun = sun[1:]

# Check
plt.plot(hrs, moon[:,0],'.',label='Altitude of Moon')
plt.plot(hrs, sun[:,0],'.',label='Altitude of Sun')
plt.axhline(0,lw=2)
plt.legend();plt.show()


