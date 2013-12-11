%make rotation matrix for ha, dec to az, alt.
%input is latitude of site, phi.
PHI = phi*pi/180.;
r3(3,3) = sin(PHI);
r3(2,2) = -1.;
r3(1,1) = -r3(3,3);
r3(2,1) = 0.;
r3(3,1) = cos(PHI);
r3(3,2) = 0.;
r3(1,3) = r3(3,1);

 
