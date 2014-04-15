;+
;This function reads in the corr.log file output by the ptcorr program
;and returns a structure containing all of the information with the
;same structure tags names as the log file.  (eg .moon, .revaz_w,etc)
;
;if a filename is specified, it will be used.  otherwise corr.log is
;assumed.
;
;To make a bunch of named variables rather than structures, name the
;output of readlog 'log' and use @logvars.idl
;
; ES, 5/2001
;-

function readlog,filename,verbose=verbose

if n_params() eq 0 then filename='corr.log'

restore,'/home/shiro/xband/ptcorr/corr_log_template.sav'

log=read_ascii(filename,template=template)

if keyword_Set(verbose) then help,/structure,log

return,log

end
