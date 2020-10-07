//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ShootMethodLogNew.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", ShootMethodLogNew);
/*
This acceleration scheme is used in paper
DOI: https://doi.org/10.1116/1.587101, with a more
detailed description in papr DOI:
https://doi.org/10.1016/0009-2509(92)85133-V.

This method assumes a periodic solution and uses
that assumption to accelerate to the simulation.
This is done by converting the periodic solution
into a boundary problem in time (i.e. the solution
at the beginning of the period must be equal to the
solution at the end of the period). So, the current
solution is increased by the different of the solution
at the start and end of the cycle times a variable
representative of the sensitivity of the problem. This
sensitivity is calculated in a sub app.
*/

template <>
InputParameters
validParams<ShootMethodLogNew>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("density_at_start_cycle",
                               "The accelerated density at the start of the cycle in log form");
  params.addRequiredCoupledVar("density_at_end_cycle",
                               "The accelerated density at the end of the cycle in log form");
  params.addParam<Real>("growth_limit",
                        0.0,
                        "A limit of the growth factor"
                        "(growth_limit = 0.0 means no limit)");
  params.addRequiredCoupledVar("sensitivity_variable",
                               "The variable that represents the sensitivity of acceleration"
                               "as defined for the shooting method");
  params.addClassDescription("An acceleration scheme based on the shooting method");
  return params;
}

ShootMethodLogNew::ShootMethodLogNew(const InputParameters & parameters)
  : Kernel(parameters),
    _density_at_start_cycle(coupledValue("density_at_start_cycle")),
    _density_at_end_cycle(coupledValue("density_at_end_cycle")),
    _sensitivity(coupledValue("sensitivity_variable")),
    _limit(getParam<Real>("growth_limit")),
    _acceleration(0.0)
{
}

ShootMethodLogNew::~ShootMethodLogNew() {}

Real
ShootMethodLogNew::computeQpResidual()
{
  Real _shifting_factor = 1. / _limit;

  return _test[_i][_qp] *
         (std::exp(_u[_qp]) - std::exp(_density_at_start_cycle[_qp]) +
          (std::exp(_density_at_start_cycle[_qp]) -
           std::exp(_density_at_end_cycle[_qp])) / ((1. - _sensitivity[_qp]) + _shifting_factor));
}

Real
ShootMethodLogNew::computeQpJacobian()
{
  return _test[_i][_qp] * std::exp(_u[_qp]) * _phi[_j][_qp];
}
