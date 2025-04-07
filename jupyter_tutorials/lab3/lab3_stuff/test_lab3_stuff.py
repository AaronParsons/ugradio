import numpy as np
import unittest

from lab3_stuff import visibility, rotate_matrix_eq2now, rotate_matrix_eq2top

class TestMyStuff:
    def test_visibility(self):
        np.testing.assert_allclose(visibility(np.array([1, 0, 0]), np.array([0, 1, 0]), 2), 1+0j)

    def test_rotate_matrix_eq2now(self):
        np.testing.assert_allclose(rotate_matrix_eq2now(0), np.identity(3))
        np.testing.assert_allclose(rotate_matrix_eq2now(np.zeros(3)), np.array([np.identity(3)]*3).transpose((1,2,0)))
        np.testing.assert_allclose(rotate_matrix_eq2now(np.pi/2), np.array([[0, 1, 0],[-1, 0, 0], [0, 0, 1]]), atol=1e-7)

    def test_rotate_matrix_eq2top(self):
        ans = np.array([[0,1,0],[0,0,1],[1,0,0]])
        np.testing.assert_allclose(rotate_matrix_eq2top(0), ans)
        np.testing.assert_allclose(rotate_matrix_eq2top(np.zeros(3)), np.array([ans] * 3).transpose((1, 2, 0)))
        M = rotate_matrix_eq2top(np.pi/4)
        eq_crd = np.array([0, 0, 1])
        sqrt22 = np.sqrt(2)/2
        np.testing.assert_allclose(M @ eq_crd, np.array([0, sqrt22, sqrt22]))
