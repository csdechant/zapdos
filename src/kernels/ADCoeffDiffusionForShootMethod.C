//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADCoeffDiffusionForShootMethod.h"

registerADMooseObject("ZapdosApp", ADCoeffDiffusionForShootMethod);

InputParameters
ADCoeffDiffusionForShootMethod::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("density", "The log of the accelerated density.");
  params.addClassDescription("The derivative of the generic diffusion term used to calculate the "
                             "sensitivity value for the shoothing method."
                             "(Densities must be in log form)");
  return params;
}

ADCoeffDiffusionForShootMethod::ADCoeffDiffusionForShootMethod(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),

    _density_var(*getVar("density", 0)),
    _diffusivity(getADMaterialProperty<Real>("diff" + _density_var.name()))
{
}

ADReal
ADCoeffDiffusionForShootMethod::computeQpResidual()
{
  return _grad_test[_i][_qp] * _r_units * _diffusivity[_qp] *
         _grad_u[_qp] * _r_units;
}
