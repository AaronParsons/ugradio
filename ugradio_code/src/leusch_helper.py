import leuschner
import sys

function = sys.argv[1]
ip = sys.argv[2]
sp = leuschner.Spectrometer(ip)

if function == "cc":
    sp.check_connected()

if function == "rs":
    filename = sys.argv[3]
    nspec = int(sys.argv[4])
    coords = eval(sys.argv[5])
    system = sys.argv[6]
    sp.read_spec(filename, nspec, coords, system)

if function == "it":
    print sp.int_time

sys.exit(0)
