//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectronTimeDerivative.h"

registerMooseObject("ZapdosApp", ElectronTimeDerivative);

template <>
InputParameters
validParams<ElectronTimeDerivative>()
{
  InputParameters params = validParams<TimeKernel>();
  params.addParam<bool>("lumping", false, "True for mass matrix lumping, false otherwise");
  params.addParam<bool>("log_form", true, "Are the densities using a log form?.");
  params.addClassDescription("Generic accumulation term for variables in log form.");
  return params;
}

ElectronTimeDerivative::ElectronTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),
    _lumping(getParam<bool>("lumping")),
    _log_form(getParam<bool>("log_form"))

{
}

Real
ElectronTimeDerivative::computeQpResidual()
{
  if (_log_form)
  {
    return _test[_i][_qp] * std::exp(_u[_qp]) * _u_dot[_qp];
  }
  else
  {
    return _test[_i][_qp] * _u_dot[_qp];
  }
}

Real
ElectronTimeDerivative::computeQpJacobian()
{
  if (_log_form)
  {
    return _test[_i][_qp] * (std::exp(_u[_qp]) * _phi[_j][_qp] * _u_dot[_qp] +
                             std::exp(_u[_qp]) * _du_dot_du[_qp] * _phi[_j][_qp]);
  }
  else
  {
    return _test[_i][_qp] * _du_dot_du[_qp] * _phi[_j][_qp];
  }
}
