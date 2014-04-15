FUNCTION POINT_READ,alt_value,az_value,num_specs,results,specs

results=fltarr(2)

results[0,0] = point2(alt=alt_value,az=az_value,/verbose)
;takespec,'spectral_data',numFiles = 1,numSpec = (num_specs+1)
;spec = Float(readspec('/home/radiolab/idl_spec_code/spectral_data0.log'))
;plot,spec
;help,spec
;spec_tot = TOTAL(spec,1)
;spec_ave = spec_tot/(SIZE(spec_tot, /DIMENSIONS))
;results[1,0] = spec_ave

RETURN,results

END
