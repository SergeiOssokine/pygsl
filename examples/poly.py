#!/usr/bin/env python
# Author : Pierre Schnizer
"""
Various examples for using the polynomial functions.

Just shows the usage of the different functions. 
"""

import Numeric
from pygsl import poly


_eps = 1e-8

def test_poly_eval():
    c = Numeric.ones((3,))
    x = 2
    assert(poly.poly_eval(c,x) == 7.0)

def polydd():
    xa = Numeric.arange(100) / 100.0 * 2. * Numeric.pi
    ya = Numeric.sin(xa)
    dd = poly.poly_dd(xa, ya)
    dd.eval(0)        
    tmp, c = dd.taylor(0.0)

def test_double():
    tmp, r1, r2 = poly.solve_quadratic(1,3,2)
    
def test_complex():    
    tmp, r1, r2 = poly.complex_solve_quadratic(1,3,2)


def test_cubic_double():    
    tmp, r1, r2, r3 = poly.solve_cubic(6,11,6)
    
def test_cubic_complex():        
    tmp, r1, r2, r3 = poly.complex_solve_cubic(6,11,6)

def poly_complex():
    pc = poly.poly_complex(3)
    tmp, rs = pc.solve((2,3,1))
    
if __name__ == '__main__':
    test_poly_eval()
    polydd()
    poly_complex()
    test_double()
    test_complex()
    test_cubic_double()
    test_cubic_complex()
