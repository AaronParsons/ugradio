function pdf, dna, dnb, cov_x0x1

;+
;PURPOSE: evaluate the 2-d pdf of the correlated variables x0 and x1 in
;problem4.
;
;INPUTS: the covariance matrix and the departures of counts from the means,
;dna and dnb
;- 

inv_cov_x0x1 = invert( cov_x0x1)
det = determ( cov_x0x1)

dvect = [ dna, dnb]

pdf = 1./(2.* !pi* det^0.5 ) 

pdf = pdf* exp( - 0.5*dvect ## inv_cov_x0x1 ## transpose( dvect))

return, pdf
end
