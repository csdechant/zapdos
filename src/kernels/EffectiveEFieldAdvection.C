//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EffectiveEFieldAdvection.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", EffectiveEFieldAdvection);

template <>
InputParameters
validParams<EffectiveEFieldAdvection>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("Ex", "The EField in the x-direction");
  params.addCoupledVar("Ey", 0, "The EField in the y-direction"); // only required in 2D and 3D
  params.addCoupledVar("Ez", 0, "The EField in the z-direction"); // only required in 3D
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Generic electric field driven advection term"
                             "(Densities must be in log form)");
  return params;
}

EffectiveEFieldAdvection::EffectiveEFieldAdvection(const InputParameters & parameters)
  : Kernel(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    _mu(getMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),

    // Coupled variables
    _Ex(coupledValue("Ex")),
    _Ey(coupledValue("Ey")),
    _Ez(coupledValue("Ez")),

    _Ex_id(coupled("Ex")),
    _Ey_id(coupled("Ey")),
    _Ez_id(coupled("Ez"))
{
}

Real
EffectiveEFieldAdvection::computeQpResidual()
{
  RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

  return _mu[_qp] * _sign[_qp] * std::exp(_u[_qp]) * EField *
         -_grad_test[_i][_qp] * _r_units;
}

Real
EffectiveEFieldAdvection::computeQpJacobian()
{
  RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

  return _mu[_qp] * _sign[_qp] * std::exp(_u[_qp]) * _phi[_j][_qp] * EField *
         -_grad_test[_i][_qp] * _r_units;
}

Real
EffectiveEFieldAdvection::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _Ex_id || jvar == _Ey_id || jvar == _Ez_id)
  {
    RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);
    RealVectorValue d_EField_d_comp(0, 0, 0);

    int comp = 4;
    if (jvar == _Ex_id)
      comp = 0;
    if (jvar == _Ey_id)
      comp = 1;
    if (jvar == _Ez_id)
      comp = 2;

    d_EField_d_comp(comp) = _phi[_j][_qp];

    return _mu[_qp] * _sign[_qp] * std::exp(_u[_qp]) * d_EField_d_comp *
           -_grad_test[_i][_qp] * _r_units;
  }
  else
    return 0.;
}
