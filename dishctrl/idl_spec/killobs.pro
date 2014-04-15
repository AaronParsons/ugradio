;+
; NAME: killObs
; PURPOSE: The name pretty much says it, but kills an observation
; CALLING SEQUENCE: killObs
; MODIFICATION HISTORY: Written on 17 April 2008 by James McBride
;			(with credit to Maxime Rischard for the idea)
;-

pro killObs

running = 0
save, filename = 'statusobs.sav', running

end
