   FUNCTION SetDifference, a, b  

      ; = a and (not b) = elements in A but not in B

   mina = Min(a, Max=maxa)
   minb = Min(b, Max=maxb)
   IF (minb GT maxa) OR (maxb LT mina) THEN RETURN, a ;No intersection...
   r = Where((Histogram(a, Min=mina, Max=maxa) NE 0) AND $
             (Histogram(b, Min=mina, Max=maxa) EQ 0), count)
   IF count eq 0 THEN RETURN, -1 ELSE RETURN, r + mina
   END
