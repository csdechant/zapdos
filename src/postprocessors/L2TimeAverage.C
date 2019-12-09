//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "L2TimeAverage.h"

registerMooseObject("ZapdosApp", L2TimeAverage);

defineLegacyParams(L2TimeAverage);

InputParameters
L2TimeAverage::validParams()
{
  InputParameters params = NodalVariablePostprocessor::validParams();
  params.set<bool>("unique_node_execute") = true;
  return params;
}

L2TimeAverage::L2TimeAverage(const InputParameters & parameters)
  : NodalVariablePostprocessor(parameters),
  _sum_of_squares(0.0),
  _value_old(valueOld())
{
}

void
L2TimeAverage::initialize()
{
  _sum_of_squares = 0.0;
}

void
L2TimeAverage::execute()
{
  Real val = _u[_qp] + _value_old[_qp];
  _sum_of_squares += val * val;
}

Real
L2TimeAverage::getValue()
{
  gatherSum(_sum_of_squares);
  return std::sqrt(_sum_of_squares)/2.0;
}

void
L2TimeAverage::threadJoin(const UserObject & y)
{
  const L2TimeAverage & pps = static_cast<const L2TimeAverage &>(y);
  _sum_of_squares += pps._sum_of_squares;
}
