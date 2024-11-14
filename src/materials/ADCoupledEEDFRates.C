#include "ADCoupledEEDFRates.h"
#include "MooseUtils.h"
#include "Function.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", ADCoupledEEDFRates);

InputParameters
ADCoupledEEDFRates::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addParam<std::string>("reaction", "The names of the properties this material will have");
  params.addCoupledVar("rate_value",
                       "The corresponding name of the "
                       "couple variable that are going to provide "
                       "the values for the material");
  params.addCoupledVar("d_rate_d_actual_mean_en",
                       "The corresponding names of the "
                       "couple variable that are going to provide "
                       "the derivative values wrt the"
                       "actual mean energy for the material");
  params.addCoupledVar("mean_energy", "The electron mean energy in log form.");
  params.addCoupledVar("electrons", "The electron density.");
  return params;
}

ADCoupledEEDFRates::ADCoupledEEDFRates(const InputParameters & parameters)
  : ADMaterial(parameters),
    _rate_coefficient(declareADProperty<Real>(getParam<std::string>("reaction"))),

    _rate_value(adCoupledValue("rate_value")),
    _d_rate_d_actual_mean_en(adCoupledValue("d_rate_d_actual_mean_en")),

    _em(adCoupledValue("electrons")),
    _mean_en(adCoupledValue("mean_energy"))
{
}

void
ADCoupledEEDFRates::computeQpProperties()
{
  _rate_coefficient[_qp].value() = _rate_value[_qp].value();
  _rate_coefficient[_qp].derivatives() = _d_rate_d_actual_mean_en[_qp].value() *
                                         std::exp(_mean_en[_qp].value() - _em[_qp].value()) *
                                         (_mean_en[_qp].derivatives() - _em[_qp].derivatives());

  if (_rate_coefficient[_qp].value() < 0.0)
  {
    _rate_coefficient[_qp].value() = 0.0;
    _rate_coefficient[_qp].derivatives() = 0.0;
  }
}
