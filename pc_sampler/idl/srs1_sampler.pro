pro srs1_sampler, nsample, fsample, set_off, set_f
;+
;NAME: SRS1_SAMPLER 
;PURPOSE: 1. Use a for-loop to change the SRS1-function-generator
;           through 4 different amplitudes(voltages)
;           2. aquire data fom the sampler in Pulsar
;           3. display the data as a plot
;           4. give an option for the user to save the data
; 
;CALLING SEQUENCE:  srs1_sampler, nsample, fsample
;
;INPUTS: 
;NSAMPLE, the number of samples
;FSAMPLE, the sampling frequency
;set_off, the dc offset of the generated sinewave
;set_f, the SRS frequency
;
;OUTPUTS:
;none
;-

;THE FOLLOWING ARE TYPICAL PARAMETERS THAT YOU'D USE...
;nsample=128  ;number of samples
;fsample=1e6  ;sample frequency
;set_off=0  ;0 Volts offset
;set_f=1e5  ;SRS1 frequency

for volts_pp=1, 4 do begin
  srs1_vpp, volts_pp    ;set the srs1 peak-to-peak voltage
  wait, .5                          ;wait for srs1 to stabilize

  v=sampler(nsample, fsample)  ;aquire data

  plot, v , title='peak-to-peak Volts ='+ string(volts_pp)

  print, 'Press  s  to save, any other letter to not save'
  pressed_key=get_kbrd()

  if pressed_key eq 's' then begin
    save, v, offset_srs1, frequency_srs1, nsample, fsample, $
          filename='data'+string(volts_pp, format='(i03)')+'.sav'
endif

endfor

end
