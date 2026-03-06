//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CoupledHeating.h"
#include "Assembly.h"
#include "ElectromagneticEnums.h"
#include "ElectromagneticConstants.h"
#include "Function.h"
#include <complex>

registerMooseObject("MooseApp", CoupledHeating);

InputParameters
CoupledHeating::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("");
  params.addRequiredCoupledVar("heating_term", "The heating term in W/m^3.");
  params.addParam<FunctionName>("coefficient", 1.0, "Coefficient function.");
  return params;
}

CoupledHeating::CoupledHeating(const InputParameters & parameters)
  : ADKernel(parameters),
    _heating(adCoupledValue("heating_term")),
    _coeff(getFunction("coefficient"))
{
}

ADReal
CoupledHeating::computeQpResidual()
{
  return -_test[_i][_qp] * _coeff.value(_t, _q_point[_qp]) * _heating[_qp] / (6.022e23 * 1.6022e-19);
}
