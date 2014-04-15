PRO hp_synth, freq = freq, ampl = ampl, verbose=verbose
set_verbose=0
if keyword_set(verbose) then set_verbose=1

IP_ADDR='128.32.197.194'
PORT=1234

if n_elements(freq) NE 0 then begin
freq_arg='freq '+STRCOMPRESS(string(trim(freq)),/remove_all)+' mhz'
if keyword_set(verbose) then print, 'Will set frequency to ',STRCOMPRESS(string(trim(freq)),/remove_all),' MHz.'
set_hp, IP_ADDR, PORT, hp_arg=freq_arg, verbose=set_verbose

endif

if n_elements(ampl) NE 0 then begin
amp_arg='ampl '+STRCOMPRESS(string(trim(ampl)),/remove_all)+' dbm'
if keyword_set(verbose) then print, 'Will set amplitude to ',STRCOMPRESS(string(trim(ampl)),/remove_all),' dBm.'
set_hp, IP_ADDR, PORT, hp_arg=amp_arg, verbose=set_verbose

endif

END 
