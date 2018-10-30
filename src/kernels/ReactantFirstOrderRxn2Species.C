#include "ReactantFirstOrderRxn2Species.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", ReactantFirstOrderRxn2Species);

template <>
InputParameters
validParams<ReactantFirstOrderRxn2Species>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredParam<std::string>("product_species_name", "The name of the product species.");
  params.addRequiredParam<std::string>("reactant_species_name", "The name of the reactant species.");
  // params.addRequiredCoupledVar("em", "The electron density.");
  return params;
}

ReactantFirstOrderRxn2Species::ReactantFirstOrderRxn2Species(const InputParameters & parameters)
  : Kernel(parameters),

    // _reaction_coeff(getMaterialProperty<Real>("k" + _var.name()))
    // _reaction_coeff(getMaterialProperty<Real>("k_" + _var.name() + "_Ar"))
    _reaction_coeff(getMaterialProperty<Real>("k" + getParam<std::string>("reactant_species_name") + getParam<std::string>("product_species_name"))),
    _n_gas(getMaterialProperty<Real>("n_gas"))
{
}

Real
ReactantFirstOrderRxn2Species::computeQpResidual()
{
  // return -_test[_i][_qp] * (-1.) * _reaction_coeff[_qp] * std::exp(_u[_qp]);
  // return -_test[_i][_qp] * (-1.) * _reaction_coeff[_qp] * std::exp(_em[_qp]);
  // return -_test[_i][_qp] * (-1.) * _reaction_coeff[_qp] * std::exp(_u[_qp]) * std::exp(_em[_qp]);
  return -_test[_i][_qp] * (-1.) * _reaction_coeff[_qp] * std::exp(_u[_qp]) * _n_gas[_qp];
}

Real
ReactantFirstOrderRxn2Species::computeQpJacobian()
{
  // return -_test[_i][_qp] * (-1.) * _reaction_coeff[_qp] * std::exp(_u[_qp]) * std::exp(_em[_qp]) * _phi[_j][_qp];
  // return -_test[_i][_qp] * (-1.) * _reaction_coeff[_qp] * std::exp(_u[_qp]) * std::exp(_n_gas[_qp]) * _phi[_j][_qp];
  return -_test[_i][_qp] * (-1.) * _reaction_coeff[_qp] * std::exp(_u[_qp]) * _n_gas[_qp] * _phi[_j][_qp];
}
