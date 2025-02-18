//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DensityMatVelocityDivergenceProduct.h"

registerADMooseObject("ZapdosApp", DensityMatVelocityDivergenceProduct);

InputParameters
DensityMatVelocityDivergenceProduct::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<std::string>("velocity", "Name of the velocity material property.");
  params.addClassDescription(
      "Contributes the product of the density and the "
      "divergence of the velocity (the velocity is supplied as a material property)");
  return params;
}

DensityMatVelocityDivergenceProduct::DensityMatVelocityDivergenceProduct(
    const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _div_velocity(getADMaterialProperty<Real>("div_"+getParam<std::string>("velocity")))
{
}

ADReal
DensityMatVelocityDivergenceProduct::computeQpResidual()
{
  return std::exp(_u[_qp]) * _div_velocity[_qp] * _r_units;
}
