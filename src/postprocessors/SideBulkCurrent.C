//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SideBulkCurrent.h"

// MOOSE includes
#include "MooseVariable.h"

using MetaPhysicL::raw_value;

registerMooseObject("ZapdosApp", SideBulkCurrent);

InputParameters
SideBulkCurrent::validParams()
{
  InputParameters params = SideIntegralVariablePostprocessor::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("potential", "The potential");
  params.addClassDescription("");
  return params;
}

SideBulkCurrent::SideBulkCurrent(const InputParameters & parameters)
  : SideIntegralVariablePostprocessor(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    _sgn(getMaterialProperty<Real>("sgn" + _variable->name())),
    _mu(getADMaterialProperty<Real>("mu" + _variable->name())),
    _diff(getADMaterialProperty<Real>("diff" + _variable->name())),

    _grad_potential(coupledGradient("potential")),

    _a(0.5)
{
}

Real
SideBulkCurrent::computeQpIntegral()
{
  //return _r_units * 1.6e-19 * 6.02e23 * _sgn[_qp] * (_sgn[_qp] * raw_value(_mu[_qp]) * -_grad_potential[_qp] * _r_units * _normals[_qp] * std::exp(_u[_qp])
  //          - raw_value(_diff[_qp]) * std::exp(_u[_qp]) * _grad_u[_qp] * _r_units * _normals[_qp]);

    if (_normals[_qp] * _sgn[_qp] * -_grad_potential[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  return _r_units * 1.6e-19 * 6.02e23 * _sgn[_qp] * (_a * _sgn[_qp] * raw_value(_mu[_qp]) * -_grad_potential[_qp] * _r_units * std::exp(_u[_qp]) *
          _normals[_qp]);
}
