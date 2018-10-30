//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "INSMomentumLaplaceFormScaled.h"

registerMooseObject("NavierStokesApp", INSMomentumLaplaceFormScaled);

template <>
InputParameters
validParams<INSMomentumLaplaceFormScaled>()
{
  InputParameters params = validParams<INSMomentumBase>();
  params.addClassDescription("This class computes momentum equation residual and Jacobian viscous "
                             "contributions for the 'Laplacian' form of the governing equations.");
  params.addRequiredParam<Real>("position_units", "Units of position");
  return params;
}

INSMomentumLaplaceFormScaled::INSMomentumLaplaceFormScaled(const InputParameters & parameters)
  : INSMomentumBase(parameters),
    _r_units(1. / getParam<Real>("position_units"))
{
}

Real
INSMomentumLaplaceFormScaled::computeQpResidualViscousPart()
{
  // Simplified version: mu * Laplacian(u_component)
  return _mu[_qp] * (_grad_u[_qp] * _r_units * _grad_test[_i][_qp] * _r_units);
}

Real
INSMomentumLaplaceFormScaled::computeQpJacobianViscousPart()
{
  // Viscous part, Laplacian version
  return _mu[_qp] * (_grad_phi[_j][_qp] * _r_units * _grad_test[_i][_qp] * _r_units);
}

Real
INSMomentumLaplaceFormScaled::computeQpOffDiagJacobianViscousPart(unsigned /*jvar*/)
{
  return 0.;
}
