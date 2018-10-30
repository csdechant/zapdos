#include "SideTotElectronFlux.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<SideTotElectronFlux>()
{
  InputParameters params = validParams<SideIntegralVariablePostprocessor>();

  params.addRequiredCoupledVar("em", "The electron charge density");
  params.addRequiredCoupledVar("Arp", "The ion charge density.");
  params.addRequiredCoupledVar("mean_en", "The electron mean energy density.");
  params.addRequiredCoupledVar("potential", "The potential that drives the advective flux.");
  params.addRequiredParam<Real>("r", "The reflection coefficient");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("time_units", "Units of time.");

  return params;
}

SideTotElectronFlux::SideTotElectronFlux(const InputParameters & parameters)
  : SideIntegralVariablePostprocessor(parameters),

  _r_units(1. / getParam<Real>("position_units")),
  _time_units(getParam<Real>("time_units")),
  _r(getParam<Real>("r")),

  _muem(getMaterialProperty<Real>("muem")),
  _massem(getMaterialProperty<Real>("massem")),

  _mean_en(coupledValue("mean_en")),
  _grad_potential(coupledGradient("potential")),

  _e(getMaterialProperty<Real>("e")),
  _a(0.5),
  _v_thermal_em(0)

{
}

Real
SideTotElectronFlux::computeQpIntegral()
{
  if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
    _a = 1.0;
  else
    _a = 0.0;

  _v_thermal_em =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _u[_qp]) / (M_PI * _massem[_qp]));

  return _r_units * (1. - _r) / (1. + _r) * (-(2 * _a - 1) * _muem[_qp] * -_grad_potential[_qp] *
         _r_units * std::exp(_u[_qp]) * _normals[_qp] +
         0.5 * _v_thermal_em * _time_units * std::exp(_u[_qp]));


}
