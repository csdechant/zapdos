//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EffectiveEField.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", EffectiveEField);

template <>
InputParameters
validParams<EffectiveEField>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("potential", "The potential acting on the electrons.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("nu", "The momentum-transfer frequency of the ion.");
  params.addRequiredParam<unsigned>("component", "The Efield component that this is applied to.");
  params.addClassDescription("Generic electric field driven advection term"
                             "(Densities must be in log form)");
  return params;
}

EffectiveEField::EffectiveEField(const InputParameters & parameters)
  : Kernel(parameters),

  _r_units(1. / getParam<Real>("position_units")),
  _nu(getParam<Real>("nu")),

  _component(getParam<unsigned>("component")),

  _potential_id(coupled("potential")),
  _grad_potential(coupledGradient("potential"))
{
}

Real
EffectiveEField::computeQpResidual()
{
  return -_test[_i][_qp] * _nu * (-_grad_potential[_qp](_component) - _u[_qp]);
}

Real
EffectiveEField::computeQpJacobian()
{
  return -_test[_i][_qp] * _nu * (-_phi[_j][_qp]);
}

Real
EffectiveEField::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _potential_id)
    return -_test[_i][_qp] * _nu * (-_grad_phi[_j][_qp](_component));
  else
    return 0.;
}
