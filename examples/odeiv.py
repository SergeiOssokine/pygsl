# Author : Pierre Schnizer
"""
The python equivalent of the C example found in the GSL Reference document.

It prints the calculational ouput to stdout. The first column is t, the
second y[0] and the thrid y[1]. Plot it with your favourite programm to see
the output.

"""
import sys
import Numeric
import pygsl
from pygsl import odeiv


def func(t, y, mu):
    f = Numeric.zeros((2,), Numeric.Float) * 1.0
    f[0] = y[1]
    f[1] = -y[0] - mu * y[1] * (y[0] ** 2 -1);
    return f

def jac(t, y, mu):
    dfdy = Numeric.ones((2,2), Numeric.Float) 
    dfdy[0, 0] = 0.0
    dfdy[0, 1] = 1.0
    dfdy[1, 0] = -2.0 * mu * y[0] * y[1] - 1.0
    dfdy[1, 1] = -mu * (y[0]**2 - 1.0)
    dfdt = Numeric.zeros((2,))
    return dfdy, dfdt
    
def run():

    mu = 10.0
    dimension = 2
    # The different possible steppers for the function
    # Comment your favourite one out to test it.
    #stepper = odeiv.step_rk2
    #stepper = odeiv.step_rk4
    #stepper = odeiv.step_rkf45
    #stepper = odeiv.step_rkck
    #stepper = odeiv.step_rk8pd
    #stepper = odeiv.step_rk2imp
    #stepper = odeiv.step_rk4imp
    #stepper = odeiv.step_gear1
    #stepper = odeiv.step_gear2
    stepper = odeiv.step_bsimp
    
    step = stepper(dimension, func,jac, mu)
    # All above steppers exept the odeiv.step_bsimp (Buerlisch - Stoer Improved
    # method can calculate without an jacobian ...
    # step = stepper(dimension, func)

    control = odeiv.control_y_new(step, 1e-6, 1e-6)
    evolve  = odeiv.evolve(step, control, dimension)
    
    print  "# Using stepper %s with order %d" %(step.name(), step.order())
    print  "# Using Control ", control.name()
    print "# %5s %9s %9s  %9s " % ("iter", "t", "y[0]", "y[1]")
    h = 1
    t = 0.0
    t1 = 50.0
    y = (1.0, 0.0)
    for i in range(1000):
        if t >= t1:
            break
        t, h, y = evolve.apply(t, t1, h, y)
        print "  %5d % 10.6f % 10.6f  % 10.6f " %(i, t, y[0], y[1])

    else:
        raise ValueError, "Maximum number of steps exceeded!"
    
if __name__ == '__main__':
    run()