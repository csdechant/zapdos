//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectronTemperatureDirichletBC.h"

registerMooseObject("ZapdosApp", ElectronTemperatureDirichletBC);

template <>
InputParameters
validParams<ElectronTemperatureDirichletBC>()
{
  InputParameters params = validParams<NodalBC>();
  params.addRequiredParam<Real>("value", "Value of the BC");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addParam<Real>("penalty_value", 1.0, "The penalty value for the Dirichlet BC.");
  params.addParam<bool>("log_form", true, "Are the densities using a log form?.");
  params.addClassDescription("Electron temperature boundary condition");
  return params;
}

ElectronTemperatureDirichletBC::ElectronTemperatureDirichletBC(const InputParameters & parameters)
  : NodalBC(parameters),
    _em(coupledValue("em")),
    _em_id(coupled("em")),
    _value(getParam<Real>("value")),
    _penalty_value(getParam<Real>("penalty_value")),
    _log_form(getParam<bool>("log_form"))
{
}

Real
ElectronTemperatureDirichletBC::computeQpResidual()
{
  if (_log_form)
  {
    return _penalty_value * (2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) - _value);
  }
  else
  {
    return _penalty_value * (2.0 / 3 * (_u[_qp] / _em[_qp]) - _value);
  }
}

Real
ElectronTemperatureDirichletBC::computeQpJacobian()
{
  if (_log_form)
  {
    return _penalty_value * (2.0 / 3 * std::exp(_u[_qp] - _em[_qp]));
  }
  else
  {
    return _penalty_value * (2.0 / 3 * (1.0 / _em[_qp]));
  }
}

Real
ElectronTemperatureDirichletBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (_log_form)
  {
    if (jvar == _em_id)
      return _penalty_value * (-2.0 / 3 * std::exp(_u[_qp] - _em[_qp]));
    else
      return 0.;
  }
  else
  {
    if (jvar == _em_id)
      return _penalty_value * (-2.0 / 3 * _u[_qp] / (_em[_qp] * _em[_qp]));
    else
      return 0.;
  }
}
