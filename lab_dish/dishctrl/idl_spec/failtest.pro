FUNCTION failtest , times, success


FOR count =0, times DO print,pointingtest(0,1,90,180,40,10,1,gauss_res=temp,spec_sums=temp2)
success=temp2
print,success
END