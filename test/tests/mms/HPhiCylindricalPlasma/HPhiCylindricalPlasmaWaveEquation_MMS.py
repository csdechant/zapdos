# Note: This is the MMS script for the equation:
#
#   \nabla \times ( 1/\epsilon_{r} \nabla \times \vec{H} ) = \epsilon_{r} \omega \mu_{0} \epsilon_{0} \vec{H}
# 
# To hold Gauss's Law of \nabla \cdot \vec{H} = 0, 
# the identity of \nabla \times ( \nabla \times \vec{A} ) = \nabla ( \nabla \cdot \vec{A} ) - \nabla^{2} \vec{A}
# was used, such that:
# 
#   \nabla^{2} \vec{H} - [ \epsilon_{r} \grad ( 1/\epsilon_{r} ) \times ( \nabla \times \vec{H} ) + \epsilon_{r} \omega \mu_{0} \epsilon_{0} \vec{H} = 0




import mms
from sympy import *

#x, y, z = symbols('x y z', real=True)

H = '(x*x*z*z) * e_j'


f, e = mms.evaluate('grad(grad(H))', H, variable='H', vec=H, transformation='cylindrical')

mms.print_hit(f, 'force')

#f_i = expand(f[0])
#
#f_i = str(f_i)
#f_i = f_i.replace('R.','')
#f_i = eval(f_i)
#
#f_i_re = re(f_i)
#f_i_im = im(f_i)
#
#f_i_re = str(f_i_re)
#f_i_im = str(f_i_im)
#
#f_i_re = f_i_re.replace('**','^')
#f_i_im = f_i_im.replace('**','^')
#
#f_i_re = f_i_re.replace('z','y')
#f_i_im = f_i_im.replace('z','y')
#
#f_j = expand(f[2])
#
#f_j = str(f_j)
#f_j = f_j.replace('R.','')
#f_j = eval(f_j)
#
#f_j_re = re(f_j)
#f_j_im = im(f_j)
#
#f_j_re = str(f_j_re)
#f_j_im = str(f_j_im)
#
#f_j_re = f_j_re.replace('**','^')
#f_j_im = f_j_im.replace('**','^')
#
#f_j_re = f_j_re.replace('z','y')
#f_j_im = f_j_im.replace('z','y')
#
#mms.print_hit(f_i_re, 'force_x_real')
#mms.print_hit(f_j_re, 'force_y_real')
#
#mms.print_hit(f_i_im, 'force_x_imag')
#mms.print_hit(f_j_im, 'force_y_imag')
