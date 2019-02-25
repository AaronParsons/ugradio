import unittest
import ugradio.interf_delay as dly

class TestMethods(unittest.TestCase):
    def test_encode_delay(self):
        answers = {
            -32: '10000001',
            -30: '10000100',
              0: '11000000',
             32: '00000000',
        }
        for key in answers.keys():
            self.assertEqual(dly.encode_delay(key), answers[key])

if __name__ == '__main__':
    unittest.main()
