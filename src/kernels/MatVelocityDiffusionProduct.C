//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MatVelocityDiffusionProduct.h"

registerADMooseObject("ZapdosApp", MatVelocityDiffusionProduct);

InputParameters
MatVelocityDiffusionProduct::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<std::string>("velocity",
                               "Name of the velocity material property.");
  params.addClassDescription("Contributes the product of the gradient of the species and the "
                             "velocity (the velocity is supplied as a material property)");
  return params;
}

MatVelocityDiffusionProduct::MatVelocityDiffusionProduct(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _velocity(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("velocity")))
{
}

ADReal
MatVelocityDiffusionProduct::computeQpResidual()
{
  return _velocity[_qp] * std::exp(_u[_qp]) * _grad_u[_qp] * _r_units;
}
