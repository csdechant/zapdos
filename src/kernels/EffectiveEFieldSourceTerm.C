//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EffectiveEFieldSourceTerm.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", EffectiveEFieldSourceTerm);

template <>
InputParameters
validParams<EffectiveEFieldSourceTerm>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("collision_freq", "The ion-neutral collision frequency.");
  params.addRequiredParam<int>("component",
                               "The component of the electric field. Accepts an integer");
  params.addClassDescription(
      "Generic electric field driven advection term. (Densities must be in log form.)");
  return params;
}

EffectiveEFieldSourceTerm::EffectiveEFieldSourceTerm(const InputParameters & parameters)
  : Kernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _nu(getParam<Real>("collision_freq")),
    _grad_potential(coupledGradient("potential")),
    _potential_id(coupled("potential")),
    _component(getParam<int>("component"))
{
}

Real
EffectiveEFieldSourceTerm::computeQpResidual()
{
  return -_test[_i][_qp] * _nu * (_grad_potential[_qp](_component) * _r_units - _u[_qp]);
}

Real
EffectiveEFieldSourceTerm::computeQpJacobian()
{
  return -_test[_i][_qp] * _nu * (-_phi[_j][_qp]);
}

Real
EffectiveEFieldSourceTerm::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (_potential_id)
  {
    return -_test[_i][_qp] * _nu * (_grad_phi[_j][_qp](_component) * _r_units);
  }
  else
    return 0.;
}
