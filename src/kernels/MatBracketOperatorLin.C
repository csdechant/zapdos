//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MatBracketOperatorLin.h"

registerADMooseObject("ZapdosApp", MatBracketOperatorLin);

InputParameters
MatBracketOperatorLin::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<MaterialPropertyName>("mat_coeff",
                                                "Name of the coefficient as a material property.");
  params.addRequiredCoupledVar("v", "The first variable acting on the bracket operation");
  params.addRequiredCoupledVar("w", "The second variable acting on the bracket operation");
  params.addClassDescription("Contributes the bracket operation of two variables multiple by a "
                             "coefficient.");
  return params;
}

MatBracketOperatorLin::MatBracketOperatorLin(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _coeff(getADMaterialProperty<Real>("mat_coeff")),
    _grad_v(adCoupledGradient("v")),
    _grad_w(adCoupledGradient("w")),
    _magnetic_vector(getADMaterialProperty<RealVectorValue>("magnetic_unit_vector"))
{
}

ADReal
MatBracketOperatorLin::computeQpResidual()
{

  return _coeff[_qp] * _test[_i][_qp] * _magnetic_vector[_qp] * _grad_v[_qp].cross(_grad_w[_qp]);
  // return _coeff[_qp] * _test[_i][_qp] * _magnetic_vector[_qp].cross(_grad_v[_qp]) * _grad_w[_qp];
}
