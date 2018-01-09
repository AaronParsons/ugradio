function picosampler_test, voltThreshold, sampInterval, nSpectra, DUAL=dual
print, "i'm here"
;+
;NAME:
;PICOSAMPLER -- Send a command to the sampler on Pulsar
;
;PURPOSE:
;    This function sends a command to the Picoscope sampler (attached to
;    Pulsar). The sampler will then take NSPECTRA series of samples,
;    with each series containing a total of 32000 samples, with a
;    sampling period of SAMPINTERVAL, with a maximum voltage threshold
;    specified by VOLTTRESHOLD. By default, data are taken only on
;    channel A, but data from channels A and B witll be recorded if the
;    DUAL setting is invoked.
;
;    If DUAL=0, the number of datapoints is 32000 * NSPECTRA
;
;    If DUAL=1, the number of datapoints is 32000 * NSPECTRA * 2, and
;                the first 32000*nspecra points are channel 1
;                the second 32000*nspecra points are channel 2
;
;To read the datafile in IDL:
;       tseries= READ_BINARY( filename, data_type=2)
;
;CALLING SEQUENCE:
;    filename = picosampler(voltThreshold, sampInterval, nSpectra, /dual)
;
;INPUTS:
;    voltTreshold:  The voltage threshold to use when sampling the
;                   data. The sampler should provide 12 bit samples, so
;                   a dynamic range of ~4000 is available. This
;                   argument must be in the form of a string, and must
;                   be one of the following options: 50mV, 100mV,
;                   200mV, 500mV, 1V, 2V, 5V, 10V, 20V.
;    sampInterval:  Sampling period when collecting data. The sampler
;                   can only record data at sampling frequencies of
;                   62.5/sampInterval MHz, where sampInterval is an
;                   integer number. 
;    nSpectra:      The number of series of samples to record. NB: each
;                   spectra takes a minimum of about 50 ms to record --
;                   keep this in mind when recording a large number of spectra.
;
;KEYWORD PARAMETERS:
;   /dual:          Sample in dual channel mode. If this keyword is not
;                   set, data will only be recorded from channel A.
;
;OUTPUTS:
;   filename:       The name of the file where the data have been
;                   recorded. This file will need to be copied from
;                   Pulsar in order to process.
;
;EXAMPLE:
;   To gather 1000 spectra with a sampling of 6.25 MHz in dual channel
;   mode with a voltage range of +/- 1 V
;   IDL> filename = picosampler('1V',10,1000,/dual)
;
;MODIFICATION HISTORY:
;   Written by Karto Keating 20-Jan-2015
;   CH 5 feb 2015: Minor corrections in documentation and using 
;        'free_lun, fhandle'
;-

if KEYWORD_SET(DUAL) then begin
   chanString = '1 1 '
   nSamples = 16000
endif else begin
   chanString = '1 0 '
   nSamples = 16000
endelse

voltageOptions = ['50mV','100mV','200mV','500mV','1V','2V','5V','10V','20V']
if (total(strmatch(voltageOptions,voltThreshold)) eq 0) then begin
   message,'ERROR: Voltage selection not valid!'
endif

nSampString = ' ' + strtrim(string(fix(nSamples)),1)
nSpecString = ' ' + strtrim(string(fix(nSpectra)),1)
sampIntString = ' ' + strtrim(string(fix(sampInterval)),1)
HOST = '10.32.92.95' ; Pulsar IP
PORT = 1340


SOCKET, fHandle, HOST, PORT, /GET_LUN
sampCmd = chanString + voltThreshold + sampIntString + nSampString + nSpecString
; '1 1 1V 10 10 1'
;stop
print, 'the command string is: ', sampCmd
printf,fHandle,sampCmd
specFileName = ''
readf,fHandle,specFileName
free_lun, fhandle
;close,fHandle
return, specFileName

end

