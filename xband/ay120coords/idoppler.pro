;+
; NAME: idoppler
;       
; PURPOSE: 
;       computes the apparent velocity of a source object at rest
;       with respect to the LSR as viewed from a station on earth             ;       
; EXPLANATION:
;        This program is designed to replace the unix program
;        DOPPLER.  
;

;       the standard LSR is defined as follows: the sun moves at 20.0 km/s
;       toward ra=18.0h, dec=30.0 deg in 1900 epoch coords
;
; CALLING SEQUENCE:
;        result=idoppler(ra,dec)
;          -or-
;        result=idoppler(l,b,/lb)
;
; INPUTS:   
;       ra - the source ra in decimal hours
;       dec - the source dec in decimal hours
;                 
;          -or-
;       l - galactic longitude
;       b - galactic latitude
;                      
; OPTIONAL INPUTS: 
;       ut='hh:mm:ss' - the time for calculation
;       time='hh:mm:ss' - SAME AS UT 
;       date='dd/mm/yyyy' - ut date 
;       vsource=# - the anticipated source velocity in km/s, where
;                   positive indicated motion away from us
;       epoch=# - epoch for given coordinates. default is 2000.  
;       lsr=[ra,dec,v,epoch] - ra is decimal hours, dec is
;                              decimal degrees, v is the
;                              velocity in km/s, epoch is a
;                              floating scalar (eg 2000.)
;       station=[lat,long,el] - NLat and E Long of the
;                               station in decimal degrees
;                                and elevation in km
;            
;
; OPTIONAL INPUT KEYWORDS:
;       /light - returns the velocity as a fraction of c
;       /helio - consider the sun to be at rest
;       /geo - computes velocity for center of earth position
;       /oldlsr - Use same (non standard) convention as DOPPLER,
;                 whereby Sun is assumed to move at 15.4 Km/sec toward
;                 RA=17.8 h, dec=25 deg. (B1900). (Vyssotsky's frame)
;                 Ref.: K.R. Lang, Astrophysical Formulae,
;                 Springer-Verlag, Berlin, 1980.
;       /nodop - returns velocity=0 always.
;
; OUTPUTS: 
;       program returns the velocity in km/s, or as a faction of c if
;       the keyword /light is specified
;
; EXAMPLES:
;
; RESTRICTIONS:
;
; PROCEDURES CALLED
;
; REVISION HISTORY: written by Erik Shirokoff,6/2001
;-

function idoppler,first,second,epoch=epoch,date=date,ut=ut,lb=lb,verbose=verbose,debug=debug,lsr=lsr,freq=freq,vsource=vsource,light=light,helio=helio,geo=geo,oldlsr=oldlsr,nodop=nodop

verby=keyword_Set(verbose)
buggy=keyword_set(debug)
if buggy then verby=1

if keyword_set(epoch) eq 0 then epoch=2000.
if keyword_set(vsource) eq 0 then vsource=0.0

;DIRECTION OF SOURCE

;get the ra and dec, 2000 epoch
if keyword_set(lb) then begin
    glactc,ra,dec,epoch,first,second,2
endif else begin
    ra=first
    dec=second
endelse

;get the components of ra and dec, 1900 epoch
rasource=ra*15.*!dtor
decsource=dec*!dtor
precess,rasource,decsource,epoch,1900.,/radian
xxsource = fltarr(3)
xxsource[0] = cos(decsource) * cos(rasource)
xxsource[1] = cos(decsource) * sin(rasource)
xxsource[2] = sin(decsource)
if buggy then print,'xxsource:',xxsource
;vvsource = vsource*xxsource



;If asked, use Vyssotsky's frame - the sun moves at 15.4 Km/sec toward
;                                  RA=17.8 h, dec=25 deg. (B1900).

if keyword_set(oldlsr) then $
  lsr=[17.8,25.,15.4,1900.]

;the standard LSR is defined as follows: the sun moves at 20.0 km/s
;toward ra=18.0h, dec=30.0 deg in 1900 epoch coords
;using PRECESS, this works out to ra=18.063955 dec=30.004661 in 2000 coords.

if keyword_set(lsr) eq 0 then lsr=[18.0,30.0,20.0,1900.]
if buggy then print,'lsr:',lsr
ralsr=lsr[0]*15.*!dtor
declsr=lsr[1]*!dtor
vlsr=lsr[2]
epochlsr=lsr[3]

if epochlsr ne 1900. then precess,ralsr,declsr,epochlsr,1900.,/radian


;find the components of the velocity of the sun wrt the lsr frame 
xxlsr = fltarr(3)
xxlsr[0] = cos(declsr) * cos(ralsr)
xxlsr[1] = cos(declsr) * sin(ralsr)
xxlsr[2] = sin(declsr)
vvlsr = vlsr*xxlsr


dar=makedate(ut,date)
jdcnv,dar[0],dar[1],dar[2],ten(dar[3],dar[4],dar[5]),jd
;if buggy then print,'dar',dar
;help,jd
if verby then print,'julan date:',jd,format='(a12,g13.12)'

;get the earth velocity wrt the sun center
baryvel,jd,1900.,vvorbit,velb

if buggy then begin
    print,'vvorbit:',vvorbit
    vorbittot=sqrt(total(vvorbit*vvorbit))
    print,'vorbittot:',vorbittot
    xxorbit=vvorbit/vorbittot
    print,'xxorbit:',xxorbit
endif

;GET THE VELOCITY OF THE STATION WITH RESPECT TO TEHG EARTH'S CENTER

;spin direction
lst=ilst(time=ut,date=date)
raspin=(lst-ra-6.)*15.*!dtor
decspin=0.0*!dtor

;projected distance from center of earth
station,lat,long
gclat = lat - 0.1924 * sin(2*lat*!dtor) ; true angle lat
rearth =( 0.99883 + 0.00167 * cos(2*lat*!dtor))* 6378.1 ;dist from center, km
rho=rearth*cos(gclat*!dtor)
if buggy then print,'lat,long,rearth,rho:',lat,long,rearth,rho

;spin velocity, km/s
vspin=2*!pi*rho/86164.090

;now get it in componets of 1900 epoch ra and dec 
precess,raspin,decspin,ten(dar[0],dar[1],dar[2]),1900,/radian
xxspin = fltarr(3)
xxspin[0] = cos(decspin) * cos(raspin)
xxspin[1] = cos(decspin) * sin(raspin)
xxspin[2] = sin(decspin)
vvspin = vspin*xxspin

;NOW PUT IT ALL TOGETHER:
;v is the apparent velocity of the source with respect to us! Negative
;means it's coming toward us.

;projected velocity of the sun wrt lsr TO the source
pvlsr=total(vvlsr*xxsource)
;projected velocity of earth center wrt sun TO the source
pvorbit = total(vvorbit*xxsource)
;projected velocity of station wrt earth center TO source
pvspin=total(vvspin*xxsource)
if buggy then print,'pvlsr,pvorbit,pvspin:',pvlsr,pvorbit,pvspin

;total velocity of the source TO the station
vtotal=-pvorbit+vsource
if keyword_set(helio) eq 0 then vtotal=vtotal-pvlsr
if keyword_Set(geo) eq 0 then vtotal=vtotal-pvspin

;   vtotal=-pvlsr-pvorbit-pvspin+vsource

if verby then print,'vtotal:',vtotal

if keyword_set(nodop) then vtotal=0.0+vsource

if keyword_set(light) then vtotal=vtotal/(2.99792458e5)

return,vtotal
end






