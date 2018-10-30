#include "GenericReaction.h"
#include "MooseUtils.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", GenericReaction);

template <>
InputParameters
validParams<GenericReaction>()
{
  InputParameters params = validParams<Material>();
  params.addRequiredParam<std::string>("first_reactant_name", "The name of the first reactant.");
  params.addRequiredParam<std::string>("second_reactant_name", "The name of second reactant.");
  params.addParam<std::string>("third_reactant_name", "the name of the third reactant (optional).");
  params.addRequiredParam<std::string>("first_product_name", "The name of the first product.");
  params.addRequiredParam<std::string>("second_product_name", "The name of the second product.");
  params.addParam<std::string>("third_product_name", "The name of the third product (optional).");

  params.addRequiredParam<Real>("reaction_rate_value", "The value of the reaction rate (constant).");

  return params;
}

GenericReaction::GenericReaction(const InputParameters & parameters)
  : Material(parameters),

    // _reaction_rate(declareProperty<Real>("k" + getParam<std::string>("first_reactant_name") + "_" + getParam<std::string>("second_reactant_name") + "__" + getParam<std::string>("first_product_name") + "_" + getParam<std::string>("second_product_name"))),
    _reaction_rate(declareProperty<Real>("k" + getParam<std::string>("first_reactant_name") + getParam<std::string>("second_reactant_name"))),
    _rate_value(getParam<Real>("reaction_rate_value"))
{}

void
GenericReaction::computeQpProperties()
{
  _reaction_rate[_qp] = _rate_value;

  // _alpha_dex[_qp] = _alpha_ex[_qp] * std::exp(_density[_qp]) / _n_gas[_qp];





}
