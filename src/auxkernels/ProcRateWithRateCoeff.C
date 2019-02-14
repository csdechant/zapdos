#include "ProcRateWithRateCoeff.h"

registerMooseObject("ZapdosApp", ProcRateWithRateCoeff);

template <>
InputParameters
validParams<ProcRateWithRateCoeff>()
{
  InputParameters params = validParams<AuxKernel>();

  params.addCoupledVar("v", "The first variable that is reacting to create u.");
  params.addCoupledVar("w", "The second variable that is reacting to create u.");
  params.addRequiredParam<std::string>("reaction", "The full reaction equation.");
  params.addRequiredParam<Real>("coefficient", "The stoichiometric coeffient.");
  params.addParam<bool>("_v_eq_u", false, "Whether or not v and u are the same variable.");
  params.addParam<bool>("_w_eq_u", false, "Whether or not w and u are the same variable.");
  return params;
}

ProcRateWithRateCoeff::ProcRateWithRateCoeff(const InputParameters & parameters)
  : AuxKernel(parameters),

  _v(isCoupled("v") ? coupledValue("v") : _zero),
  _w(isCoupled("w") ? coupledValue("w") : _zero),
  _v_id(isCoupled("v") ? coupled("v") : 0),
  _w_id(isCoupled("w") ? coupled("w") : 0),
  _n_gas(getMaterialProperty<Real>("n_gas")),
  _reaction_coeff(getMaterialProperty<Real>("k_" + getParam<std::string>("reaction"))),
  _stoichiometric_coeff(getParam<Real>("coefficient")),
  _v_eq_u(getParam<bool>("_v_eq_u")),
  _w_eq_u(getParam<bool>("_w_eq_u"))
{
}

Real
ProcRateWithRateCoeff::computeValue()
{
  /*
  _em_current =
      6.02e23 * (_sgnem[_qp] * _muem[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_em[_qp]) -
                 _diffem[_qp] * std::exp(_em[_qp]) * _grad_em[_qp] * _r_units);

  return _alpha[_qp] * _em_current.norm();
  */

  Real mult1, mult2;

  if (isCoupled("v"))
    mult1 = std::exp(_v[_qp]);
  else
  {
    mult1 = _n_gas[_qp];
  }

  if (isCoupled("w"))
    mult2 = std::exp(_w[_qp]);
  else
  {
    mult2 = _n_gas[_qp];
  }
  return 6.02e23 * _stoichiometric_coeff * _reaction_coeff[_qp] *  mult1 * mult2;


}
