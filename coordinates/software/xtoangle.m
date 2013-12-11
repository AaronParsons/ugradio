%convert the primed rectangular system to angles
%input: the rectangular coordinates xp of a rotation matrix transformation
%output: latlikepr (the 'latitude-like' angle, primed)
%output: longlikepr (the 'long-like' angle, primed)
%units of output are degrees
latlikepr = asin(xp(3));
longlikepr = atan2(xp(2),xp(1));
latlikepr = 180. * latlikepr/pi
longlikepr = 180. * longlikepr/pi
