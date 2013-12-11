%generates rot matrix to convert...
% from left-handed to right-handed/
% or, equivalently, to reflect.
r2a = zeros(3,3);
r2a(1,1) = 1.0;
r2a(2,2) = -1.0;
r2a(3,3) = 1.0;
