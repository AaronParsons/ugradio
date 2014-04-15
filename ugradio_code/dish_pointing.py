import math

DEG2RAD = math.pi / 180.

ppr=115600 #pulses per one revolution of geardrive output shaft 
slead=.2 #screw lead in inches
ppi=ppr/slead #actuator encoder pulses per inch of travel
az_off = 0
az_off = az_off*DEG2RAD

a_x=37.75 #below values not taken from memo4 and in inches unless specified
b_x=15.125
C_x=1.2687 #radians
m_x=2.0
a_y=17.5625
b_y=14.96
C_y=1.3461 #radians
m_y=2.0


c_x_min=27
c_x_zen=36.25
c_x_max=49.25
c_y_min=6.5
c_y_zen=20.375
c_y_max=28.75

x_min = math.sqrt((c_x_min**2-m_x**2))
x_zen = math.sqrt((c_x_zen**2-m_x**2))
x_max = math.sqrt((c_x_max**2-m_x**2))
y_min = math.sqrt((c_y_min**2-m_y**2))
y_zen = math.sqrt((c_y_zen**2-m_y**2))
y_max = math.sqrt((c_y_max**2-m_y**2))
x_max_mv, y_max_mv = x_max - x_min, y_max - y_min


a_min = math.acos((a_x**2+b_x**2-c_x_min**2)/(2*a_x*b_x))
C_x_meas = math.acos((a_x**2+b_x**2-c_x_zen**2)/(2*a_x*b_x))
a_max = math.acos((a_x**2+b_x**2-c_x_max**2)/(2*a_x*b_x))

alpha_min = a_min-C_x_meas
alpha_max = a_max-C_x_meas

b_min = math.acos((a_y**2+b_y**2-c_y_min**2)/(2*a_y*b_y))
C_y_meas = math.acos((a_y**2+b_y**2-c_y_zen**2)/(2*a_y*b_y))
b_max = math.acos((a_y**2+b_y**2-c_y_max**2)/(2*a_y*b_y))

beta_min = b_min - C_y_meas
beta_max = b_max - C_y_meas

def az_alt_to_xy(az, alt, validate=False):
    '''Convert azimuth and altitude to the x/y encoder units for the drives
    on the Leuschner radio dish.  Input angles should be degrees. Validate
    returns True/False for whether the specified pointing is valid.'''
    #  Begining of kinematic calculations
    alt_rad = alt * DEG2RAD
    az_rad = az * DEG2RAD
    alpha = math.atan(-math.cos(az_rad-az_off) / math.tan(alt_rad))
    beta = math.asin(math.sin(az_rad-az_off) * math.cos(alt_rad))
    mv_skip = 0
    # check from min/max extensions of actuators
    if alpha < alpha_min or alpha > alpha_max: mv_skip = 1
    if beta < beta_min or beta > beta_max: mv_skip = 1
    x_ang = alpha + C_x_meas
    y_ang = beta + C_y_meas

    x_in = math.sqrt(a_x**2 + b_x**2 - 2*a_x*b_x*math.cos(alpha+C_x_meas) - m_x**2)
    #print "x_in",x_in
    y_in = math.sqrt(a_y**2 + b_y**2 - 2*a_y*b_y*math.cos(beta+C_y_meas) - m_y**2)
    #print "y_in",y_in

    x_mv, y_mv = x_in - x_min, y_in - y_min
    valid = check_move(x_mv, y_mv)
    if validate: return valid
    elif not valid: raise ValueError('Specified pointing (az=%f,alt=%f) is out of range' % (az,alt))
    x_step, y_step = int(x_mv*ppi), int(y_mv*ppi)
    return x_step, y_step


def check_move(x_mv, y_mv):
    '''Check that the specified move is physically valid.'''
    if (x_mv < 0) or (x_mv > x_max_mv): return False
    if (y_mv < 0) or (y_mv > y_max_mv): return False
    return True
