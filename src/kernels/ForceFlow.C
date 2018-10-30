#include "ForceFlow.h"
#include "MooseMesh.h"

registerMooseObject("NavierStokesApp", ForceFlow);

template <>
InputParameters
validParams<ForceFlow>()
{
  InputParameters params = validParams<Kernel>();

  params.addClassDescription("This class advects a scalar variable according to velocity "
                             "components coming from a Navier-Stokes simulation.");
  // Coupled variables
  params.addRequiredCoupledVar("u", "x-velocity");
  params.addCoupledVar("v", "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("w", "z-velocity"); // only required in 3D
  params.addRequiredParam<Real>("position_units", "Units of position");
  params.addRequiredParam<Real>("time_units", "Units of time");

  return params;
}

ForceFlow::ForceFlow(const InputParameters & parameters)
  : Kernel(parameters),



    // Coupled variables
    _u_vel(coupledValue("u")),
    _v_vel(_mesh.dimension() >= 2 ? coupledValue("v") : _zero),
    _w_vel(_mesh.dimension() == 3 ? coupledValue("w") : _zero),

    // Variable numberings
    _u_vel_var_number(coupled("u")),
    _v_vel_var_number(_mesh.dimension() >= 2 ? coupled("v") : libMesh::invalid_uint),
    _w_vel_var_number(_mesh.dimension() == 3 ? coupled("w") : libMesh::invalid_uint),

    _r_units(1. / getParam<Real>("position_units")),
    _time_units(getParam<Real>("time_units"))
{
}

Real
ForceFlow::computeQpResidual()
{
  RealVectorValue velocity(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);

  return -_grad_test[_i][_qp] * _r_units * velocity * std::exp(_u[_qp]);
}

Real
ForceFlow::computeQpJacobian()
{
  RealVectorValue velocity(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);

  return -_grad_test[_i][_qp] * _r_units * velocity * std::exp(_u[_qp]) * _phi[_j][_qp];
}

Real
ForceFlow::computeQpOffDiagJacobian(unsigned jvar)
{
  RealVectorValue velocity(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);

  if (jvar == _u_vel_var_number)
    return -_grad_test[_i][_qp](0) * _r_units * _phi[_j][_qp] * std::exp(_u[_qp]);

  else if (jvar == _v_vel_var_number)
    return -_grad_test[_i][_qp](1) * _r_units * _phi[_j][_qp] * std::exp(_u[_qp]);

  else if (jvar == _w_vel_var_number)
    return -_grad_test[_i][_qp](2) * _r_units * _phi[_j][_qp] * std::exp(_u[_qp]);

  else
    return 0;
}
