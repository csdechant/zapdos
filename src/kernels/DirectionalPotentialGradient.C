//* This file is part of Crane, an open-source
//* application for plasma chemistry and thermochemistry
//* https://github.com/lcpp-org/crane
//*
//* Crane is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DirectionalPotentialGradient.h"

registerADMooseObject("ZapdosApp", DirectionalPotentialGradient);

InputParameters
DirectionalPotentialGradient::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addParam<Real>("position_units", 1.0, "Units of position.");
  params.addRequiredCoupledVar("potential",
                               "The potential.");
  params.addRequiredParam<std::string>("k", "The equilibrium density profile parameter.");
  params.addRequiredParam<int>("component",
                               "The component of the potential gradient (0 = x, 1 = y, 2 = z)");
  params.addClassDescription(
      "The directional potential gradient for the Hasegawa-Wakatani model");
  return params;
}

DirectionalPotentialGradient::DirectionalPotentialGradient(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _grad_potential(adCoupledGradient("potential")),
    _k(getADMaterialProperty<Real>(getParam<std::string>("k"))),
    _component(getParam<int>("component"))
{
}

ADReal
DirectionalPotentialGradient::computeQpResidual()
{
  return _test[_i][_qp] * _k[_qp] * _grad_potential[_qp](_component) * _r_units;
}
