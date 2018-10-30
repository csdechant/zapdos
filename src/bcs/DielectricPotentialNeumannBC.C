//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DielectricPotentialNeumannBC.h"

template <>
InputParameters
validParams<DielectricPotentialNeumannBC>()
{
  InputParameters params = validParams<IntegratedBC>();

  // Here we are adding a parameter that will be extracted from the input file by the Parser
  params.addParam<Real>("eps", 1.0, "The permittivity of the dielectric");
  params.addRequiredCoupledVar("surface_charge", "Surface Charge at the Boundary");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  params.addRequiredParam<Real>("position_units", "Units of position");
  return params;
}

DielectricPotentialNeumannBC::DielectricPotentialNeumannBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _eps(getParam<Real>("eps")),
    _surface_charge(coupledValue("surface_charge")),

    _r_units(1. / getParam<Real>("position_units")),
    _potential_units(getParam<std::string>("potential_units"))
    {
      if (_potential_units.compare("V") == 0)
        _voltage_scaling = 1.;
      else if (_potential_units.compare("kV") == 0)
        _voltage_scaling = 1000;
    }

Real
DielectricPotentialNeumannBC::computeQpResidual()
{
  return -_test[_i][_qp] * _surface_charge[_qp] / (_eps * _voltage_scaling * _r_units);
}
