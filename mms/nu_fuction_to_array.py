from sympy import *


x = symbols('x', real=True)

def F(x):
    return sin(pi*x)

for i in range(10):
    a = F(i*0.1)
    print(a.evalf())