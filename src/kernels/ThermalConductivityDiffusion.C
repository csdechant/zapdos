//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ThermalConductivityDiffusion.h"

registerMooseObject("ZapdosApp", ThermalConductivityDiffusion);

template <>
InputParameters
validParams<ThermalConductivityDiffusion>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("em", "The log of the electron density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Electron energy diffusion term "
                             "that assumes a thermal conductivity of "
                             "$K = 3/2 D_e n_e$ ");
  return params;
}

/**
 * This diffusion kernel acts as a "correction" to compare to models that uses
 * Einstein relation version of electron heat flux.
 */

ThermalConductivityDiffusion::ThermalConductivityDiffusion(const InputParameters & parameters)
  : Kernel(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _coeff(2.0 / 3.0),

    _diffem(getMaterialProperty<Real>("diffmean_en")),
    _d_diffem_d_actual_mean_en(getMaterialProperty<Real>("d_diffem_d_actual_mean_en")),

    _em(coupledValue("em")),
    _grad_em(coupledGradient("em")),
    _em_id(coupled("em")),

    _d_diffem_d_u(0),
    _d_diffem_d_em(0)
{
}

ThermalConductivityDiffusion::~ThermalConductivityDiffusion() {}

Real
ThermalConductivityDiffusion::computeQpResidual()
{
  Real actual_mean_en = std::exp(_u[_qp] - _em[_qp]);

  return -_grad_test[_i][_qp] * _r_units * _coeff * _diffem[_qp] *
          (std::exp(_u[_qp]) * _grad_u[_qp] * _r_units -
           actual_mean_en * std::exp(_em[_qp]) * _grad_em[_qp] * _r_units);
}

Real
ThermalConductivityDiffusion::computeQpJacobian()
{
  Real actual_mean_en = std::exp(_u[_qp] - _em[_qp]);

  _d_diffem_d_u =
      _d_diffem_d_actual_mean_en[_qp] * actual_mean_en * _phi[_j][_qp];

  return -_grad_test[_i][_qp] * _r_units * _coeff * _r_units *
         (_d_diffem_d_u * std::exp(_u[_qp]) * _grad_u[_qp] +
          _diffem[_qp] * std::exp(_u[_qp]) * _phi[_j][_qp] * _grad_u[_qp] +
          _diffem[_qp] * std::exp(_u[_qp]) * _grad_phi[_j][_qp] -
          _d_diffem_d_u * actual_mean_en * std::exp(_em[_qp]) * _grad_em[_qp] -
          _diffem[_qp] * actual_mean_en * _phi[_j][_qp] * std::exp(_em[_qp]) * _grad_em[_qp]);
}

Real
ThermalConductivityDiffusion::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _em_id)
  {
    Real actual_mean_en = std::exp(_u[_qp] - _em[_qp]);

    _d_diffem_d_em =
        _d_diffem_d_actual_mean_en[_qp] * actual_mean_en * -_phi[_j][_qp];

    return -_grad_test[_i][_qp] * _r_units * _coeff * _r_units *
           (_d_diffem_d_em * std::exp(_u[_qp]) * _grad_u[_qp] -
            _d_diffem_d_em * actual_mean_en * std::exp(_em[_qp]) * _grad_em[_qp] -
            _diffem[_qp] * actual_mean_en * -_phi[_j][_qp] * std::exp(_em[_qp]) * _grad_em[_qp] -
            _diffem[_qp] * actual_mean_en * std::exp(_em[_qp]) * _phi[_j][_qp] * _grad_em[_qp] -
            _diffem[_qp] * actual_mean_en * std::exp(_em[_qp]) * _grad_phi[_j][_qp]);
  }

  else
    return 0.;
}
