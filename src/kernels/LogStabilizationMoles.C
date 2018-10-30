#include "LogStabilizationMoles.h"

template <>
InputParameters
validParams<LogStabilizationMoles>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredParam<Real>("offset",
                                "The offset parameter that goes into the exponential function");
  params.addRequiredParam<Real>("time_units", "Units of time.");
  return params;
}

LogStabilizationMoles::LogStabilizationMoles(const InputParameters & parameters)
  : Kernel(parameters),

  _time_units(getParam<Real>("time_units")),
  _offset(getParam<Real>("offset"))
{
}

LogStabilizationMoles::~LogStabilizationMoles() {}

Real
LogStabilizationMoles::computeQpResidual()
{
  return -_test[_i][_qp] * std::exp(-(_offset + _u[_qp])) * _time_units;
}

Real
LogStabilizationMoles::computeQpJacobian()
{
  return -_test[_i][_qp] * std::exp(-(_offset + _u[_qp])) * _time_units * -_phi[_j][_qp];
}
