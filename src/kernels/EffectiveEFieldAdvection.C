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
  params.addRequiredCoupledVar("u", "x-Effective Efield");
  params.addCoupledVar("v", 0, "y-Effective Efield"); // only required in 2D and 3D
  params.addCoupledVar("w", 0, "z-Effective Efield"); // only required in 3D
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
    _u_Efield_id(coupled("u")),
    _v_Efield_id(coupled("v")),
    _w_Efield_id(coupled("w")),

    _u_Efield(coupledValue("u")),
    _v_Efield(coupledValue("v")),
    _w_Efield(coupledValue("w"))
{
}

Real
EffectiveEFieldAdvection::computeQpResidual()
{

  RealVectorValue Efield(_u_Efield[_qp], _v_Efield[_qp], _w_Efield[_qp]);

  return _mu[_qp] * _sign[_qp] * std::exp(_u[_qp]) * Efield * _r_units *
         -_grad_test[_i][_qp] * _r_units;
}

Real
EffectiveEFieldAdvection::computeQpJacobian()
{
  RealVectorValue Efield(_u_Efield[_qp], _v_Efield[_qp], _w_Efield[_qp]);

  return _mu[_qp] * _sign[_qp] * std::exp(_u[_qp]) * _phi[_j][_qp] * Efield * _r_units *
         -_grad_test[_i][_qp] * _r_units;
}

Real
EffectiveEFieldAdvection::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _u_Efield_id || jvar == _v_Efield_id || jvar == _w_Efield_id)
  {
    RealVectorValue Efield(_u_Efield[_qp], _v_Efield[_qp], _w_Efield[_qp]);
    RealVectorValue d_EField_d_comp(0, 0, 0);

    int comp = 4;
    if (jvar == _u_Efield_id)
      comp = 0;
    if (jvar == _v_Efield_id)
      comp = 1;
    if (jvar == _w_Efield_id)
      comp = 2;

    d_EField_d_comp(comp) = _phi[_j][_qp];

    return _mu[_qp] * _sign[_qp] * std::exp(_u[_qp]) * d_EField_d_comp * _r_units *
           -_grad_test[_i][_qp] * _r_units;
  }
  else
    return 0.0;
}
