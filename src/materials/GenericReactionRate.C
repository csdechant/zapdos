#include "GenericReactionRate.h"
#include "MooseUtils.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", GenericReactionRate);

template <>
InputParameters
validParams<GenericReactionRate>()
{
  InputParameters params = validParams<Material>();
  params.addRequiredParam<std::string>("reaction", "The full reaction equation.");
  params.addRequiredParam<Real>("reaction_rate_value", "The value of the reaction rate (constant).");

  return params;
}

GenericReactionRate::GenericReactionRate(const InputParameters & parameters)
  : Material(parameters),
    // _reaction_rate(declareProperty<Real>("k" + getParam<std::string>("first_reactant_name") + getParam<std::string>("second_reactant_name"))),
    _reaction_rate(declareProperty<Real>("k_" + getParam<std::string>("reaction"))),
    _rate_value(getParam<Real>("reaction_rate_value"))
{}

void
GenericReactionRate::computeQpProperties()
{
  _reaction_rate[_qp] = _rate_value;

  // _alpha_dex[_qp] = _alpha_ex[_qp] * std::exp(_density[_qp]) / _n_gas[_qp];





}
