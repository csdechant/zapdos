#include "ReactantABRxn2.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", ReactantABRxn2);

template <>
InputParameters
validParams<ReactantABRxn2>()
{
  InputParameters params = validParams<Kernel>();
  params.addCoupledVar("v", "The first variable that is reacting to create u.");
  params.addRequiredParam<std::string>("reaction", "The full reaction equation.");
  params.addRequiredParam<Real>("coefficient", "The stoichiometric coeffient.");
  return params;
}

ReactantABRxn2::ReactantABRxn2(const InputParameters & parameters)
  : Kernel(parameters),
    // _coupled_var_A(isCoupled("v") ? *getVar("v", 0) : _zero),
    // _coupled_var_A(*getVar("v", 0)),
    _reaction_coeff(getMaterialProperty<Real>("k_"+getParam<std::string>("reaction"))),
    // _reaction_coeff(getMaterialProperty<Real>("k" + _coupled_var_A.name() + _var.name())),
    // _reaction_coeff(isCoupled("v") ? getMaterialProperty<Real>("k" + _coupled_var_A.name() + _var.name())
                    // : getMaterialProperty<Real>("k" + _var.name() + _var.name())),
    _v(isCoupled("v") ? coupledValue("v") : _zero),
    _n_gas(getMaterialProperty<Real>("n_gas")),
    _stoichiometric_coeff(getParam<Real>("coefficient"))
    // _v(isCoupled("v") ? coupledValue("v") : _zero)
{
}

Real
ReactantABRxn2::computeQpResidual()
{
  // if (isCoupled("v"))
  // {
  //   std::cout << "YES" << std::endl;
  // }
  // else
  //   std::cout << "NO" << std::endl;
  if (isCoupled("v"))
  {
    return -_test[_i][_qp] * _stoichiometric_coeff * _reaction_coeff[_qp] * std::exp(_v[_qp]) * std::exp(_u[_qp]);
  }
  else
    return -_test[_i][_qp] * _stoichiometric_coeff * _reaction_coeff[_qp] * _n_gas[_qp] * std::exp(_u[_qp]);
}

Real
ReactantABRxn2::computeQpJacobian()
{
  if (isCoupled("v"))
    return -_test[_i][_qp] * _stoichiometric_coeff * _reaction_coeff[_qp] * 1.0 * std::exp(_v[_qp]) *
           std::exp(_u[_qp]) * _phi[_j][_qp];
  else
    return -_test[_i][_qp] * _stoichiometric_coeff * _reaction_coeff[_qp] * 1.0 * _n_gas[_qp] *
           std::exp(_u[_qp]) * _phi[_j][_qp];
}

Real
ReactantABRxn2::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (isCoupled("v"))
  {
    if (jvar == _v_id)
      return -_test[_i][_qp] * _stoichiometric_coeff * _reaction_coeff[_qp] * 1.0 * std::exp(_u[_qp]) * std::exp(_v[_qp]) * _phi[_j][_qp];
    else
      return 0.0;
  }
  else
  {
    return 0.0;
  }
}
