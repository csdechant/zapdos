//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADPenaltyShootingMethodBC.h"

registerMooseObject("MooseApp", ADPenaltyShootingMethodBC);

InputParameters
ADPenaltyShootingMethodBC::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addParam<Real>("penalty", 1.0, "Penalty scalar");
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

ADPenaltyShootingMethodBC::ADPenaltyShootingMethodBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters), 
    _p(getParam<Real>("penalty")), 
    _density_at_start_cycle(adCoupledValue("density_at_start_cycle")),
    _density_at_end_cycle(adCoupledValue("density_at_end_cycle")),
    _sensitivity(adCoupledValue("sensitivity_variable")),
    _limit(getParam<Real>("growth_limit"))
{
}

ADReal
ADPenaltyShootingMethodBC::computeQpResidual()
{
  ADReal Scaling = 1.0 / ((1. - _sensitivity[_qp]) + (1. / _limit));

  return _test[_i][_qp] * _p *
         (std::exp(_u[_qp]) - std::exp(_density_at_start_cycle[_qp]) +
           (std::exp(_density_at_start_cycle[_qp]) -
            std::exp(_density_at_end_cycle[_qp])) * Scaling);
}
