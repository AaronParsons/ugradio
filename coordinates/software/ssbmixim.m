function [y] = ssbmixim( x)
% SSBMIXIM does ssb mixing with a SINE lo signal,
%using complex notation;
%this allows suppression of the sum frequency.
%uses the global variables DELW WLO EPLUS EMINUS
%WLO is the l.o. frequency
%DELW is the offset from the l.o. frequency,
%both upper and lower sidebands.
%EPLUS is the voltage of the upper sideband.
%EMINUS is the voltage of the lower sideband.
%x is time.
%see also: SSBMIXRE

global DELW WLO EPLUS EMINUS

%yplus is the positive sideband cosine wve...
yplus = EPLUS*exp(i*2*pi*(WLO + DELW)*x);

%yminus is the negative sideband cosine wave...
yminus = EMINUS*exp(i*2*pi*(WLO - DELW)*x);

%ylo is the local oscillator wave...
ylo = exp(i*2*pi*WLO*x);

%now use the theorem to multiply them together...
%that is, multiply yplus + yminus by the IMAG
%part of the l.o. wave.

%first, do the difference frequency term...
y = -0.5*imag( (yplus + yminus)*conj(ylo));

%add the following term if you want the sum
%frequency as well...
y = y + 0.5*imag( (yplus + yminus)*ylo);
