import unittest, numpy
import ugradio.leusch

class TestPointing(unittest.TestCase):
    def test_el20(self):
        tel = ugradio.leusch.TelescopeDirect(verbose=True)
        tel.move_el(20.)
        tel.wait_el()
        el_cnts = tel._write(b'.b g r0x112\r')
        el_cnts = int(el_cnts.split()[-1])
        self.assertLessEqual(numpy.abs(el_cnts - 3242), 2)
        self.assertAlmostEqual(float(tel.get_el()), 20., 1)
    def test_el35(self):
        tel = ugradio.leusch.TelescopeDirect(verbose=True)
        tel.move_el(35.)
        tel.wait_el()
        el_cnts = tel._write(b'.b g r0x112\r')
        el_cnts = int(el_cnts.split()[-1])
        self.assertLessEqual(numpy.abs(el_cnts - 2561), 2)
        self.assertAlmostEqual(float(tel.get_el()), 35., 1)
    def test_el75(self):
        tel = ugradio.leusch.TelescopeDirect(verbose=True)
        tel.move_el(75.)
        tel.wait_el()
        el_cnts = tel._write(b'.b g r0x112\r')
        el_cnts = int(el_cnts.split()[-1])
        self.assertLessEqual(numpy.abs(el_cnts - 740), 2)
        self.assertAlmostEqual(float(tel.get_el()), 75., 1)
    def test_az300(self):
        tel = ugradio.leusch.TelescopeDirect(verbose=True)
        tel.move_az(300.)
        tel.wait_az()
        az_cnts = tel._write(b'.a g r0x112\r')
        az_cnts = int(az_cnts.split()[-1])
        self.assertLessEqual(numpy.abs(az_cnts - (-5765)), 2)
        self.assertAlmostEqual(float(tel.get_az()), 300., 1)
    def test_az275(self):
        tel = ugradio.leusch.TelescopeDirect(verbose=True)
        tel.move_az(275.)
        tel.wait_az()
        az_cnts = tel._write(b'.a g r0x112\r')
        az_cnts = int(az_cnts.split()[-1])
        self.assertLessEqual(numpy.abs(az_cnts - (-6902)), 2)
        self.assertAlmostEqual(float(tel.get_az()), 275., 1)
    def test_az35(self):
        tel = ugradio.leusch.TelescopeDirect(verbose=True)
        tel.move_az(35.)
        tel.wait_az()
        az_cnts = tel._write(b'.a g r0x112\r')
        az_cnts = int(az_cnts.split()[-1])
        self.assertLessEqual(numpy.abs(az_cnts - (-17828)), 2)
        self.assertAlmostEqual(float(tel.get_az()), 35., 1)

if __name__ == '__main__':
    unittest.main()
