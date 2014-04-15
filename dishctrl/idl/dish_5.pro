PRO DISH, alt=alt, az=az, home=home, noise_on=noise_on, noise_off=noise_off, move_check=move_check, verbose=verbose

set_verbose=0
if keyword_set(verbose) then set_verbose=1

IP_ADDR='128.32.197.194' ;IP Address of the NETEON serial to ethernet adapter.
PORT=4660 ;PORT on which the NETEON serial adapter is awaiting a connection

if keyword_set(noise_on) then set_noise, IP_ADDR, PORT, noise=0, verbose=set_verbose
if keyword_set(noise_off) then set_noise, IP_ADDR, PORT, noise=1, verbose=set_verbose

if keyword_set(home) then begin

if keyword_set(verbose) then print,'Homing, this may take a while . . .'
drive_off, IP_ADDR, PORT, verbose=set_verbose
drive_on, IP_ADDR, PORT, verbose=set_verbose
wait,2
go_home, IP_ADDR, PORT, verbose=set_verbose
home_ready=''
max_hm_tries=120
hm_tries=0
while (((home_ready NE 'R') and (home_ready NE 'S')) and (hm_tries LE max_hm_tries)) do begin
control_stat, IP_ADDR, PORT, '1', control_status = home_ready, verbose=set_verbose
if home_ready NE 'R' then wait,1
hm_tries=hm_tries + 1
endwhile
home_ready=''
hm_tries=0
while (((home_ready NE 'R') and (home_ready NE 'S')) and (hm_tries LE max_hm_tries)) do begin
control_stat, IP_ADDR, PORT, '2', control_status = home_ready, verbose=set_verbose
if home_ready NE 'R' then wait,1
hm_tries=hm_tries + 1
endwhile
print,'dish zeroed properly'

drive_off, IP_ADDR, PORT, verbose=set_verbose
drive_on, IP_ADDR, PORT, verbose=set_verbose

set_suc=0
max_set_tries=3
set_tries=0
while ((set_suc EQ 0) and (set_tries LE max_set_tries)) do begin
set_dist, IP_ADDR, PORT, '1', DISTANCE = '5600000', SUCCESS=set_suc, VERBOSE=set_verbose
set_tries=set_tries+1
endwhile
set_suc=0
set_tries=0
while ((set_suc EQ 0) and (set_tries LE max_set_tries)) do begin
set_dist, IP_ADDR, PORT, '2', DISTANCE = '8380000', SUCCESS=set_suc, VERBOSE=set_verbose
set_tries=set_tries+1
endwhile

set_go, IP_ADDR, PORT, VERBOSE=set_verbose


mv_ready=''
max_mv_tries=120
mv_tries=0
while ((mv_ready NE 'R') and (mv_tries LE max_mv_tries)) do begin
control_stat, IP_ADDR, PORT, '1', control_status = mv_ready, verbose=set_verbose
if mv_ready NE 'R' then wait,1
mv_tries=mv_tries + 1
endwhile
mv_ready=''
mv_tries=0
while ((mv_ready NE 'R') and (mv_tries LE max_mv_tries)) do begin
control_stat, IP_ADDR, PORT, '2', control_status = mv_ready, verbose=set_verbose
if mv_ready NE 'R' then wait,1
mv_tries=mv_tries + 1
endwhile
print,'dish finished moving to zenith'
enc_1_pos=0
enc_2_pos=0

enc_pos, IP_ADDR, PORT, '1', ENC_POSITION = enc_1_pos, VERBOSE=set_verbose
enc_pos, IP_ADDR, PORT, '2', ENC_POSITION = enc_2_pos, VERBOSE=set_verbose

print,'encoder 1 position',enc_1_pos
print,'encoder 2 position',enc_2_pos

drive_off, IP_ADDR, PORT, verbose=set_verbose




endif

;/////////////////////////////////////////////////////
;
;   Beginning of ALT-AZ move OR move checking
;
;/////////////////////////////////////////////////////

if ((n_elements(alt) ne 0) and (n_elements(az) ne 0)) then begin

;/////////////////////////////////////////////////////
;
;   Begining of kinematic calculations
;
;/////////////////////////////////////////////////////

ppr=115600 ;pulses per one revolution of geardrive output shaft 
slead=.2 ;screw lead in inches
ppi=ppr/slead ;actuator encoder pulses per inch of travel

alt_rad = alt * !DTOR
az_rad = az * !DTOR


a_x=38 ;below values not taken from memo4 and in inches unless specified
b_x=15
C_x=1.26638 ;radians
m_x=2.0
a_y=17.5
b_y=14.9
C_y=1.38104 ;radians
m_y=2.0


c_x_min=26.625
c_x_zen=36.25
c_x_max=49.75
c_y_min=6.375
c_y_zen=20.625
c_y_max=29.25

x_min=sqrt((c_x_min^2-m_x^2))
x_zen=sqrt((c_x_zen^2-m_x^2))
x_max=sqrt((c_x_max^2-m_x^2))
y_min=sqrt((c_y_min^2-m_y^2))
y_zen=sqrt((c_y_zen^2-m_y^2))
y_max=sqrt((c_y_max^2-m_y^2))

a_min=acos((a_x^2+b_x^2-c_x_min^2)/(2*a_x*b_x))
C_x_meas=acos((a_x^2+b_x^2-c_x_zen^2)/(2*a_x*b_x))
a_max=acos((a_x^2+b_x^2-c_x_max^2)/(2*a_x*b_x))

alpha_min=a_min-C_x_meas
alpha_max=a_max-C_x_meas

b_min=acos((a_y^2+b_y^2-c_y_min^2)/(2*a_y*b_y))
C_y_meas=acos((a_y^2+b_y^2-c_y_zen^2)/(2*a_y*b_y))
b_max=acos((a_y^2+b_y^2-c_y_max^2)/(2*a_y*b_y))

beta_min=b_min-C_y_meas
beta_max=b_max-C_y_meas

alpha=atan((-cos(az_rad))/(tan(alt_rad)))
beta=asin((sin(az_rad)*cos(alt_rad)))


; \/  CHECKING FOR MAX/MIN EXTENTIONS OF ACTUATORS \/

mv_skip=0

if ((alpha lt alpha_min) or (alpha gt alpha_max)) then mv_skip=1
if ((beta lt beta_min) or (beta gt beta_max)) then mv_skip=1

; /\  CHECKING FOR MAX/MIN EXTENTIONS OF ACTUATORS /\




x_ang=alpha+C_x_meas
y_ang=beta+C_y_meas

x_in=sqrt(a_x^2+b_x^2-2*a_x*b_x*cos(alpha+C_x_meas)-m_x^2)
print,"x_in",x_in
y_in=sqrt(a_y^2+b_y^2-2*a_y*b_y*cos(beta+C_y_meas)-m_y^2)
print,"y_in",y_in

x_max_mv=x_max-x_min
y_max_mv=y_max-y_min

x_mv=x_in-x_min
y_mv=y_in-y_min

if ((x_mv lt 0) or (x_mv gt x_max_mv)) then mv_skip=1
if ((y_mv lt 0) or (y_mv gt y_max_mv)) then mv_skip=1


;////////////////////////////////////////////////////
;
;  IF MOVE CONDITIONS ARE SATISFIED, MOVE BEGINS HERE
;
;////////////////////////////////////////////////////

if ((mv_skip eq 0) and (n_elements(move_check) eq 0)) then begin

x_step=x_mv*ppi
x_step=long64(x_step)
y_step=y_mv*ppi
y_step=long64(y_step)

mv_dist_x = STRCOMPRESS(string(x_step),/remove_all)
mv_dist_y = STRCOMPRESS(string(y_step),/remove_all)


drive_off, IP_ADDR, PORT, verbose=set_verbose
drive_on, IP_ADDR, PORT, verbose=set_verbose
wait,1

set_suc=0
max_set_tries=3
set_tries=0
while ((set_suc EQ 0) and (set_tries LE max_set_tries)) do begin
set_dist, IP_ADDR, PORT, '1', DISTANCE = mv_dist_x, SUCCESS=set_suc, VERBOSE=set_verbose
set_tries=set_tries+1
endwhile
set_suc=0
set_tries=0
while ((set_suc EQ 0) and (set_tries LE max_set_tries)) do begin
set_dist, IP_ADDR, PORT, '2', DISTANCE = mv_dist_y, SUCCESS=set_suc, VERBOSE=set_verbose
set_tries=set_tries+1
endwhile

set_go, IP_ADDR, PORT, VERBOSE=set_verbose

mv_ready=''
max_mv_tries=120
mv_tries=0
while (((mv_ready NE 'R') and (mv_ready NE 'S')) and (mv_tries LE max_mv_tries)) do begin
control_stat, IP_ADDR, PORT, '1', control_status = mv_ready, verbose=set_verbose
if mv_ready NE 'R' then wait,1
mv_tries=mv_tries + 1
endwhile
mv_ready=''
mv_tries=0
while (((mv_ready NE 'R') and (mv_ready NE 'S')) and (mv_tries LE max_mv_tries)) do begin
control_stat, IP_ADDR, PORT, '2', control_status = mv_ready, verbose=set_verbose
if mv_ready NE 'R' then wait,1
mv_tries=mv_tries + 1
endwhile
enc_1_pos=0
enc_2_pos=0

enc_pos, IP_ADDR, PORT, '1', ENC_POSITION = enc_1_pos, VERBOSE=set_verbose
enc_pos, IP_ADDR, PORT, '2', ENC_POSITION = enc_2_pos, VERBOSE=set_verbose

print,'encoder 1 position',enc_1_pos
print,'encoder 2 position',enc_2_pos

drive_off, IP_ADDR, PORT, verbose=set_verbose


endif else if n_elements(move_check) eq 0 then print,"alt-az out of range, skipping move"

;/////////////////////////////////////////////////////////////////////////
;
;  ACTUAL MOVE ENDS HERE, BELOW ARE ITEMS RELATED TO CHECKING THE MOVE
;
;/////////////////////////////////////////////////////////////////////////

if ((n_elements(move_check) ne 0) and (mv_skip eq 0)) then print, 'can move there' 
if ((n_elements(move_check) ne 0) and (mv_skip eq 1)) then print, 'cant move there'
if ((n_elements(move_check) ne 0) and (mv_skip eq 0)) then move_check=1 else if ((n_elements(move_check) ne 0) and (mv_skip eq 1)) then move_check=-1


endif



END

