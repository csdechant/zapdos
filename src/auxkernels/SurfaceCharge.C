/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "SurfaceCharge.h"

template <>
InputParameters
validParams<SurfaceCharge>()
{
  InputParameters params = validParams<AuxKernel>();

  params.addRequiredParam<Real>("r_em", "The reflection coefficient for electrons");
  params.addRequiredParam<Real>("r_ip", "The reflection coefficient for ions");
  params.addRequiredCoupledVar("em", "The electron density");
  params.addRequiredCoupledVar("Arp", "The ion density.");
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredCoupledVar("mean_en", "The mean energy.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("time_units", "Units of time.");
  params.addRequiredParam<bool>("use_moles", "Whether to convert from units of moles to #.");

  return params;
}

SurfaceCharge::SurfaceCharge(const InputParameters & parameters)
  : AuxKernel(parameters),

  _normals(_var.normals()),

  _time_units(getParam<Real>("time_units")),
  _r_units(1. / getParam<Real>("position_units")),
  _r_em(getParam<Real>("r_em")),
  _r_ip(getParam<Real>("r_ip")),


  _em(coupledValue("em")),
  _muem(getMaterialProperty<Real>("muem")),
  _massem(getMaterialProperty<Real>("massem")),

  _ip(coupledValue("Arp")),
  _muArp(getMaterialProperty<Real>("muArp")),
  _massArp(getMaterialProperty<Real>("massArp")),
  _kb(getMaterialProperty<Real>("k_boltz")),
  _T_heavy(getMaterialProperty<Real>("T_heavy")),

  _grad_potential(coupledGradient("potential")),
  _mean_en(coupledValue("mean_en")),

  _e(getMaterialProperty<Real>("e")),
  _convert_moles(getParam<bool>("use_moles")),
  _N_A(6.02e23),
  _a(0.5),
  _b(0.5),
  _v_thermal_em(0),
  _v_thermal_ip(0),
  _electron_flux(0),
  _ion_flux(0)
{
}

Real
SurfaceCharge::computeValue()
{
  if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
  {
    _a = 1.0;
    _b = 0.0;
  }
  else
  {
    _a = 0.0;
    _b = 1.0;
  }

  _v_thermal_em =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));

  _electron_flux =
      _r_units * (1. - _r_em) / (1. + _r_em) * (-(2 * _a - 1) * _muem[_qp] * -_grad_potential[_qp] *
      _r_units * std::exp(_em[_qp]) * _normals[_qp] +
      0.5 * _v_thermal_em * _time_units * std::exp(_em[_qp]));

  _v_thermal_ip = std::sqrt(8 * _kb[_qp] * _T_heavy[_qp] / (M_PI * _massArp[_qp]));

  _ion_flux =
      _r_units * (1. - _r_ip) / (1. + _r_ip) * ((2 * _b - 1) * _muArp[_qp] * -_grad_potential[_qp] *
      _r_units *  std::exp(_ip[_qp]) * _normals[_qp] +
      0.5 * _v_thermal_ip * _time_units * std::exp(_ip[_qp]));

  if (_convert_moles)
    return _e[_qp] * (_ion_flux - _electron_flux) * _N_A * (_dt / _time_units) + _u_old[_qp];
  else
    return _e[_qp] * (_ion_flux - _electron_flux) * (_dt / _time_units) + _u_old[_qp];

  //return _e[_qp] * _dt + _u_old[_qp];
}
