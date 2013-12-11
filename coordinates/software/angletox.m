%to convert galactic coordinates, use the following:
%generate longlike and latlike, the Galactic coordinates.
%angletox
%makerg
%xp=rg*x
%xtoangle
%in general, follow the writeup in ay120bcoord.tex
%input: latlike (the 'latitude-like' angle)
%input: longlike (the 'long-like' angle)
%units of input are degrees
%output: the rectangular coordinates x of these angles.
DEC = latlike * pi/180.;
HA = longlike * pi/180.;
x=zeros(3,1);
x(1) = cos(DEC) * cos(HA);
x(2) = cos(DEC) * sin(HA);
x(3) = sin(DEC);

