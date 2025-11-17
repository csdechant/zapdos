//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CoeffParallelDiffusionLin.h"

registerADMooseObject("ZapdosApp", CoeffParallelDiffusionLin);

InputParameters
CoeffParallelDiffusionLin::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addParam<Real>("position_units", 1.0, "Units of position.");
  params.addRequiredParam<MaterialPropertyName>("mat_coeff",
                                                "Name of the coefficient as a material property.");
  params.addRequiredCoupledVar("v", "The variable acting on the parallel operation");
  params.addClassDescription("Contributes the product of coupled variable and the parallel "
                             "magnetic gradient of another variable");
  return params;
}

CoeffParallelDiffusionLin::CoeffParallelDiffusionLin(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _coeff(getADMaterialProperty<Real>("mat_coeff")),
    _grad_v(adCoupledGradient("v")),
    _vector(getADMaterialProperty<RealVectorValue>("magnetic_unit_vector"))
{
}

ADReal
CoeffParallelDiffusionLin::computeQpResidual()
{
  return _test[_i][_qp] * _coeff[_qp] * _vector[_qp] * _grad_v[_qp] * _r_units;
}
