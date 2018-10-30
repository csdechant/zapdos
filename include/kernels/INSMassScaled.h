//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef INSMASSSCALED_H
#define INSMASSSCALED_H

#include "INSBase.h"

// Forward Declarations
class INSMassScaled;

template <>
InputParameters validParams<INSMassScaled>();

/**
 * This class computes the mass equation residual and Jacobian
 * contributions for the incompressible Navier-Stokes momentum
 * equation.
 */
class INSMassScaled : public INSBase
{
public:
  INSMassScaled(const InputParameters & parameters);

  virtual ~INSMassScaled() {}

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  virtual Real computeQpPGResidual();
  virtual Real computeQpPGJacobian();
  virtual Real computeQpPGOffDiagJacobian(unsigned comp);

  bool _pspg;
  Function & _x_ffn;
  Function & _y_ffn;
  Function & _z_ffn;
  Real _r_units;
};

#endif // INSMassScaled_H
