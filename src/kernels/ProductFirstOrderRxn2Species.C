#include "ProductFirstOrderRxn2Species.h"

// MOOSE includes
#include "MooseVariable.h"

template <>
InputParameters
validParams<ProductFirstOrderRxn2Species>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("v", "The variable that is reacting to create u.");
  params.addRequiredParam<std::string>("product_species_name", "The name of the product species.");
  params.addRequiredParam<std::string>("reactant_species_name", "The name of the reactant species.");

  return params;
}

ProductFirstOrderRxn2Species::ProductFirstOrderRxn2Species(const InputParameters & parameters)
  : Kernel(parameters),
    _user_reactant_name(getParam<std::string>("reactant_species_name")),
    _user_product_name(getParam<std::string>("product_species_name")),
    _coupled_var(*getVar("v", 0)),
    _v(coupledValue("v")),
    _v_id(coupled("v")),
    _reaction_coeff(getMaterialProperty<Real>("k_" + getParam<std::string>("reactant_species_name") + "_" + getParam<std::string>("product_species_name"))),
    _n_gas(getMaterialProperty<Real>("n_gas"))
{
}

Real
ProductFirstOrderRxn2Species::computeQpResidual()
{
  return -_test[_i][_qp] * (1.) * _reaction_coeff[_qp] * std::exp(_n_gas[_qp]);
}

Real
ProductFirstOrderRxn2Species::computeQpJacobian()
{
  return 0.0;
}

Real
ProductFirstOrderRxn2Species::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _v_id)
    return -_test[_i][_qp] * (1.) * _reaction_coeff[_qp] * std::exp(_n_gas[_qp]) * _phi[_j][_qp];

  else
    return 0.0;
}
