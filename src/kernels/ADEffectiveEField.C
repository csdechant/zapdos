//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADEffectiveEField.h"

registerADMooseObject("ZapdosApp", ADEffectiveEField);


InputParameters
ADEffectiveEField::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("nu", "The momentum-transfer frequency of the ion.");
  params.addRequiredParam<unsigned>("component", "The Efield component that this is applied to.");
  params.addRequiredCoupledVar(
      "potential", "The potential acting on the electrons.");
  return params;
}

ADEffectiveEField::ADEffectiveEField(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _nu(getParam<Real>("nu")),
    _component(getParam<unsigned>("component")),
    _grad_potential(adCoupledGradient("potential"))
{
}

// ADRealVectorValue
// ADEffectiveEField::precomputeQpResidual()
ADReal
ADEffectiveEField::computeQpResidual()
{
  return -_test[_i][_qp] * _nu * (-_grad_potential[_qp](_component) - _u[_qp]);
}
