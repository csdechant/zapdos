#include "ElectronTimeDerivative.h"

template <>
InputParameters
validParams<ElectronTimeDerivative>()
{
  InputParameters params = validParams<TimeKernel>();
  params.addParam<bool>("lumping", false, "True for mass matrix lumping, false otherwise");
  //Letting the kernel read the time scaling from input file
  params.addRequiredParam<Real>("time_units", "Units of time.");
  return params;
}

ElectronTimeDerivative::ElectronTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),

  // Setting in the time scaling similar to the position scaling
   _time_units(1. / getParam<Real>("time_units")),

   _lumping(getParam<bool>("lumping"))

{
}

Real
ElectronTimeDerivative::computeQpResidual()
{
  //original code
  //return _test[_i][_qp] * std::exp(_u[_qp]) * _u_dot[_qp];

  //With time scaling
  return _test[_i][_qp] * std::exp(_u[_qp]) * _u_dot[_qp] * _time_units;
}

Real
ElectronTimeDerivative::computeQpJacobian()
{
  //original code
  //return _test[_i][_qp] * (std::exp(_u[_qp]) * _phi[_j][_qp] * _u_dot[_qp] +
                           //std::exp(_u[_qp]) * _du_dot_du[_qp] * _phi[_j][_qp]);

  //With time scaling
  return _test[_i][_qp] * (std::exp(_u[_qp]) * _phi[_j][_qp] * _u_dot[_qp] * _time_units +
                          std::exp(_u[_qp]) * _du_dot_du[_qp] * _time_units * _phi[_j][_qp]);
}
