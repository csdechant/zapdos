//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "AmbipolarEField.h"

registerMooseObject("ElectromagneticsApp", AmbipolarEField);

InputParameters
AmbipolarEField::validParams()
{
  InputParameters params = ADVectorKernel::validParams();
  params.addClassDescription("");
  params.addRequiredCoupledVar("em", "The electron density");
  params.addRequiredParam<MaterialPropertyName>("ion_diffusion",
                                                "The diffusion coeff. of the ions.");
  params.addRequiredParam<MaterialPropertyName>("ion_mobility", "The mobility coeff. of the ions.");
  return params;
}

AmbipolarEField::AmbipolarEField(const InputParameters & parameters)
  : ADVectorKernel(parameters),
    _em(adCoupledValue("em")),
    _grad_em(adCoupledGradient("em")),
    _diffem(getADMaterialProperty<Real>("diffem")),
    _muem(getADMaterialProperty<Real>("muem")),
    _diffion(getADMaterialProperty<Real>("ion_diffusion")),
    _muion(getADMaterialProperty<Real>("ion_mobility"))
{
}

ADReal
AmbipolarEField::computeQpResidual()
{
  return _test[_i][_qp] *
         (_u[_qp] - _grad_em[_qp] * (_diffion[_qp] - _diffem[_qp]) / (_muion[_qp] - _muem[_qp]));
}
