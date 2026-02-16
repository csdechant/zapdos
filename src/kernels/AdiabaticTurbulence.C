//* This file is part of Crane, an open-source
//* application for plasma chemistry and thermochemistry
//* https://github.com/lcpp-org/crane
//*
//* Crane is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "AdiabaticTurbulence.h"

registerADMooseObject("ZapdosApp", AdiabaticTurbulence);

InputParameters
AdiabaticTurbulence::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredCoupledVar("density", "The density in logarithmic form.");
  params.addRequiredCoupledVar("potential", "The potential.");
  params.addRequiredParam<std::string>("adiabaticity",
                                       "The adiabaticity coefficient of the density species.");
  params.addClassDescription("The adiabatic term for the Hasegawa-Wakatani model");
  return params;
}

AdiabaticTurbulence::AdiabaticTurbulence(const InputParameters & parameters)
  : ADKernel(parameters),
    _density(adCoupledValue("density")),
    _potential(adCoupledValue("potential")),
    _adiabaticity(getADMaterialProperty<Real>(getParam<std::string>("adiabaticity")))
{
}

ADReal
AdiabaticTurbulence::computeQpResidual()
{
  return -_test[_i][_qp] * _adiabaticity[_qp] * (_potential[_qp] - exp(_density[_qp]));
}
