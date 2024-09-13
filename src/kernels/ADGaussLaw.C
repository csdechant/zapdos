//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADGaussLaw.h"

registerMooseObject("ElectromagneticsApp", ADGaussLaw);

InputParameters
ADGaussLaw::validParams()
{
  InputParameters params = ADVectorKernel::validParams();
  params.addClassDescription("");
  params.addRequiredCoupledVar("charged", "The charged species");
  params.addRequiredParam<MaterialPropertyName>("dielectric_constant",
                                                "The dielectric constant of the material.");
  params.addRequiredParam<MaterialPropertyName>(
      "dielectric_constant_gradient", "The gradient of the dielectric constant of the material.");
  return params;
}

ADGaussLaw::ADGaussLaw(const InputParameters & parameters)
  : ADVectorKernel(parameters),
    _charged_var(*getVar("charged", 0)),
    _charged(adCoupledValue("charged")),
    _grad_charged(adCoupledGradient("charged")),

    _nu(getADMaterialProperty<Real>("dielectric_constant")),
    _grad_nu(getADMaterialProperty<RealVectorValue>("dielectric_constant_gradient")),

    _e(getMaterialProperty<Real>("e")),
    _sgn(getMaterialProperty<Real>("sgn" + _charged_var.name())),
    _N_A(getMaterialProperty<Real>("N_A"))
{
}

ADReal
ADGaussLaw::computeQpResidual()
{
  return _test[_i][_qp] * _e[_qp] * _sgn[_qp] * _N_A[_qp] *
         (std::exp(_charged[_qp]) * _grad_charged[_qp] * _nu[_qp] -
          std::exp(_charged[_qp]) * _grad_nu[_qp]) /
         (_nu[_qp] * _nu[_qp]);
}
