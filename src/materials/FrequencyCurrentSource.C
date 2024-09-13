/*
#include "PlasmaDielectricConstant.h"

registerMooseObject("ZapdosApp", PlasmaDielectricConstant);

InputParameters
PlasmaDielectricConstant::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("");
  params.addRequiredParam<Real>("electron_neutral_collision_frequency",
                                "The electron-neutral collision frequency (in Hz).");
  params.addRequiredParam<Real>("driving_frequency", "Driving frequency of plasma (in Hz).");
  params.addRequiredCoupledVar("em", "Electron density coupled variable.");
  return params;
}

PlasmaDielectricConstant::PlasmaDielectricConstant(const InputParameters & parameters)
  : ADMaterial(parameters),
    _eps_r_real(declareADProperty<Real>("plasma_dielectric_constant_real")),
    _em(adCoupledValue("em")),
    _em_grad(adCoupledGradient("em")),
    _eps_r_real(getADMaterialProperty<Real>("eps_rel_real")),

    _r_units(1. / getParam<Real>("position_units")),

    _density_var(*getVar("density_log", 0)),
    _density_log(coupledValue("density_log")),
    _grad_density_log(coupledGradient("density_log")),
    _electric_field(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("field_property_name"))),
    _mu(getGenericMaterialProperty<Real, is_ad>("mu" + _density_var.name())),
    _sgn(getMaterialProperty<Real>("sgn" + _density_var.name())),
    _diff(getGenericMaterialProperty<Real, is_ad>("diff" + _density_var.name())),
    _art_diff(getParam<bool>("art_diff"))
{
}

void
PlasmaDielectricConstant::computeQpProperties()
{

  Real r =
      _sgn[_qp] * 1.6e-19 * 6.02e23 *
      (_sgn[_qp] * raw_value(_mu[_qp]) * raw_value(_electric_field[_qp](0)) * _r_units *
           std::exp(_density_log[_qp]) -
       raw_value(_diff[_qp]) * std::exp(_density_log[_qp]) * _grad_density_log[_qp](0) * _r_units);

  if (_art_diff)
  {
    Real vd_mag = raw_value(_mu[_qp]) * raw_value((-_electric_field[_qp]).norm()) * _r_units;
    Real delta = vd_mag * _current_elem->hmax() / 2.;
    r += _sgn[_qp] * 1.6e-19 * 6.02e23 * -delta * std::exp(_density_log[_qp]) *
         _grad_density_log[_qp](0) * _r_units;
  }

  return r;
}
*/
