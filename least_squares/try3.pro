
for nrx=0,199 do begin 
for nry=0, 199 do begin 
dela = [dela1[ nrx, nry], dela2[ nrx, nry]] 
delchisq_n[ nrx, nry] = $
        dela ## xxw_new ## transpose(dela) 
endfor 
endfor

end

