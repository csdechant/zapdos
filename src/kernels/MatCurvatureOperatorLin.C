//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MatCurvatureOperatorLin.h"

registerADMooseObject("ZapdosApp", MatCurvatureOperatorLin);

InputParameters
MatCurvatureOperatorLin::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<MaterialPropertyName>("mat_coeff",
                                                "Name of the coefficient as a material property.");
  params.addRequiredCoupledVar("v", "The variable acting on the curvature operation");
  params.addClassDescription("Contributes the curvature operator multiple by a "
                             "coefficient.");
  return params;
}

MatCurvatureOperatorLin::MatCurvatureOperatorLin(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _coeff(getADMaterialProperty<Real>("mat_coeff")),
    _grad_v(adCoupledGradient("v")),
    _magnetic_vector(getADMaterialProperty<RealVectorValue>("magnetic_unit_vector")),
    _curl_magnetic_vector(getADMaterialProperty<RealVectorValue>("curl_magnetic_unit_vector")),
    _grad_mag_magnetic_field(getADMaterialProperty<RealVectorValue>("grad_mag_magnetic_field")),
    _mag_magnetic_field(getADMaterialProperty<Real>("mag_magnetic_field"))
{
}

ADReal
MatCurvatureOperatorLin::computeQpResidual()
{
  return _coeff[_qp] * _test[_i][_qp] *
         (_curl_magnetic_vector[_qp] +
          _magnetic_vector[_qp].cross(_grad_mag_magnetic_field[_qp]) / _mag_magnetic_field[_qp]) *
         _grad_v[_qp] / 2;
}
