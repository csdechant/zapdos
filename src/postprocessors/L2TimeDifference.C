//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "L2TimeDifference.h"

registerMooseObject("ZapdosApp", L2TimeDifference);

defineLegacyParams(L2TimeDifference);

InputParameters
L2TimeDifference::validParams()
{
  InputParameters params = NodalVariablePostprocessor::validParams();
  params.set<bool>("unique_node_execute") = true;
  return params;
}

L2TimeDifference::L2TimeDifference(const InputParameters & parameters)
  : NodalVariablePostprocessor(parameters),
  _sum_of_squares(0.0),
  _value_old(valueOld())
{
}

void
L2TimeDifference::initialize()
{
  _sum_of_squares = 0.0;
}

void
L2TimeDifference::execute()
{
  Real val = _u[_qp] - _value_old[_qp];
  _sum_of_squares += val * val;
}

Real
L2TimeDifference::getValue()
{
  gatherSum(_sum_of_squares);
  return std::sqrt(_sum_of_squares);
}

void
L2TimeDifference::threadJoin(const UserObject & y)
{
  const L2TimeDifference & pps = static_cast<const L2TimeDifference &>(y);
  _sum_of_squares += pps._sum_of_squares;
}
