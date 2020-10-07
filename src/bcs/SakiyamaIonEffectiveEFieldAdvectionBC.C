//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SakiyamaIonEffectiveEFieldAdvectionBC.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", SakiyamaIonEffectiveEFieldAdvectionBC);

template <>
InputParameters
validParams<SakiyamaIonEffectiveEFieldAdvectionBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredCoupledVar("Ex", "The EField in the x-direction");
  params.addCoupledVar("Ey", 0, "The EField in the y-direction"); // only required in 2D and 3D
  params.addCoupledVar("Ez", 0, "The EField in the z-direction"); // only required in 3D
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Kinetic advective ion boundary condition"
                             "(Based on DOI: https://doi.org/10.1116/1.579300)");
  return params;
}

SakiyamaIonEffectiveEFieldAdvectionBC::SakiyamaIonEffectiveEFieldAdvectionBC(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    // Coupled Variables
    _Ex(coupledValue("Ex")),
    _Ey(coupledValue("Ey")),
    _Ez(coupledValue("Ez")),

    _Ex_id(coupled("Ex")),
    _Ey_id(coupled("Ey")),
    _Ez_id(coupled("Ez")),

    _mu(getMaterialProperty<Real>("mu" + _var.name())),
    _e(getMaterialProperty<Real>("e")),
    _sgn(getMaterialProperty<Real>("sgn" + _var.name())),
    _a(0.5)
{
}

Real
SakiyamaIonEffectiveEFieldAdvectionBC::computeQpResidual()
{
  RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

  if (_normals[_qp] * _sgn[_qp] * EField > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  return _test[_i][_qp] * _r_units *
         (_a * _sgn[_qp] * _mu[_qp] * EField * std::exp(_u[_qp]) *
          _normals[_qp]);
}

Real
SakiyamaIonEffectiveEFieldAdvectionBC::computeQpJacobian()
{
  RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

  if (_normals[_qp] * _sgn[_qp] * EField > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  return _test[_i][_qp] * _r_units *
         (_a * _sgn[_qp] * _mu[_qp] * EField * std::exp(_u[_qp]) *
          _phi[_j][_qp] * _normals[_qp]);
}

Real
SakiyamaIonEffectiveEFieldAdvectionBC::computeQpOffDiagJacobian(unsigned int jvar)
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

    if (_normals[_qp] * _sgn[_qp] * EField > 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    return _test[_i][_qp] * _r_units *
           (_a * _sgn[_qp] * _mu[_qp] * d_EField_d_comp * std::exp(_u[_qp]) * _normals[_qp]);
  }

  else
    return 0.0;
}
