%input is lst in HOURS.
r2b = zeros(3,3);
r2b(1,1) = cos(pi*lst/12.);
r2b(2,2) = r2b(1,1);
r2b(3,3) = 1.0;
r2b(1,2) = sin(pi*lst/12.);
r2b(2,1) = -r2b(1,2);

