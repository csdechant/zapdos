//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SideTotalCurrent.h"

// MOOSE includes
#include "MooseVariable.h"

using MetaPhysicL::raw_value;

registerMooseObject("ZapdosApp", SideTotalCurrent);

InputParameters
SideTotalCurrent::validParams()
{
  InputParameters params = SideIntegralVariablePostprocessor::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("potential", "The potential");
  params.addRequiredCoupledVar("ions", "The ions");
  params.addRequiredCoupledVar("mean_en", "The electron mean energy");
  params.addParam<Real>("users_gamma",
                        "A secondary electron emission coeff. only used for this BC.");
  params.addClassDescription("");
  return params;
}

SideTotalCurrent::SideTotalCurrent(const InputParameters & parameters)
  : SideIntegralVariablePostprocessor(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    _sgnem(getMaterialProperty<Real>("sgn" + _variable->name())),
    _muem(getADMaterialProperty<Real>("mu" + _variable->name())),
    _diffem(getADMaterialProperty<Real>("diff" + _variable->name())),

    _ion(coupledValue("ions")),
    _grad_ion(coupledGradient("ions")),
    _sgnion(getMaterialProperty<Real>("sgn" + (*getVar("ions", 0)).name())),
    _muion(getADMaterialProperty<Real>("mu" + (*getVar("ions", 0)).name())),
    _diffion(getADMaterialProperty<Real>("diff" + (*getVar("ions", 0)).name())),

    _grad_potential(coupledGradient("potential")),

    em_flux(0.0),
    ion_flux(0.0),

    _a(0.5),

    _mean_en(coupledValue("mean_en")),

    _massem(getMaterialProperty<Real>("massem")),
    _e(getMaterialProperty<Real>("e")),
    _v_thermal(0),

    _user_se_coeff(getParam<Real>("users_gamma"))
{
}

Real
SideTotalCurrent::computeQpIntegral()
{
  // em_flux = _sgnem[_qp] * raw_value(_muem[_qp]) * -_grad_potential[_qp] * _r_units * _normals[_qp] * std::exp(_u[_qp])
  //           - raw_value(_diffem[_qp]) * std::exp(_u[_qp]) * _grad_u[_qp] * _r_units * _normals[_qp];
  //
  // ion_flux = _sgnion[_qp] * raw_value(_muion[_qp]) * -_grad_potential[_qp] * _r_units * _normals[_qp] * std::exp(_ion[_qp])
  //           - raw_value(_diffion[_qp]) * std::exp(_ion[_qp]) * _grad_ion[_qp] * _r_units * _normals[_qp];


  if (_normals[_qp] * _sgnion[_qp] * -_grad_potential[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  ion_flux = _a * _sgnion[_qp] * raw_value(_muion[_qp]) * -_grad_potential[_qp] * _r_units * std::exp(_ion[_qp]) *
          _normals[_qp];

  _v_thermal =
   std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _u[_qp]) / (M_PI * _massem[_qp]));


  em_flux = 0.25 * _v_thermal * std::exp(_u[_qp]) - _a * _user_se_coeff * ion_flux;


  return _r_units * 1.6e-19 * 6.02e23 * (_sgnion[_qp] * ion_flux + _sgnem[_qp] * em_flux);
}
