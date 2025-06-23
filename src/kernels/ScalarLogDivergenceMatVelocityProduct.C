//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ScalarLogDivergenceMatVelocityProduct.h"

registerADMooseObject("ZapdosApp", ScalarLogDivergenceMatVelocityProduct);

InputParameters
ScalarLogDivergenceMatVelocityProduct::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addParam<Real>("position_units", 1.0, "Units of position.");
  params.addRequiredParam<std::string>("mat_vector", "Name of the vector material property.");
  params.addClassDescription(
      "Contributes the product of a logarithmic case variable and the "
      "divergence of a vector (the vector is supplied as a material property)");
  return params;
}

ScalarLogDivergenceMatVelocityProduct::ScalarLogDivergenceMatVelocityProduct(
    const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _div_vector(getADMaterialProperty<Real>("div_"+getParam<std::string>("mat_vector")))
{
}

ADReal
ScalarLogDivergenceMatVelocityProduct::computeQpResidual()
{
  return _test[_i][_qp] * std::exp(_u[_qp]) * _div_vector[_qp] * _r_units;
}
