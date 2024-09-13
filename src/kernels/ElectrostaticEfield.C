//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectrostaticEfield.h"

registerMooseObject("ZapdosApp", ElectrostaticEfield);

InputParameters
ElectrostaticEfield::validParams()
{
  InputParameters params = ADVectorKernel::validParams();
  params.addCoupledVar("potential", "Electrostatic potential variable.");
  params.addClassDescription("Used for converting the electrostatic potential to an E-field.");
  return params;
}

ElectrostaticEfield::ElectrostaticEfield(const InputParameters & parameters)
  : ADVectorKernel(parameters), _grad_potential(adCoupledGradient("potential"))
{
}

ADReal
ElectrostaticEfield::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] + _grad_potential[_qp]);
}
