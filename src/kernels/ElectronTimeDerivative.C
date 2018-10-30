#include "ElectronTimeDerivative.h"

template <>
InputParameters
validParams<ElectronTimeDerivative>()
{
  InputParameters params = validParams<TimeKernel>();
  params.addParam<bool>("lumping", false, "True for mass matrix lumping, false otherwise");
  params.addRequiredParam<Real>("time_units", "Units of time.");
  return params;
}

ElectronTimeDerivative::ElectronTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),

  _time_units(getParam<Real>("time_units")),
  _lumping(getParam<bool>("lumping"))

{
}

Real
ElectronTimeDerivative::computeQpResidual()
{
  return _test[_i][_qp] * std::exp(_u[_qp]) * _u_dot[_qp] * _time_units;
}

Real
ElectronTimeDerivative::computeQpJacobian()
{
  return _test[_i][_qp] * (std::exp(_u[_qp]) * _phi[_j][_qp] * _u_dot[_qp] * _time_units +
                           std::exp(_u[_qp]) * _du_dot_du[_qp] * _time_units * _phi[_j][_qp]);
}
