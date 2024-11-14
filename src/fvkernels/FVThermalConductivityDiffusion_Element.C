/*
#include "FVThermalConductivityDiffusion_Element.h"

registerMooseObject("ZapdosApp", FVThermalConductivityDiffusion_Element);

InputParameters
FVThermalConductivityDiffusion_Element::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("em", "The log of the electron density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Electron energy diffusion term "
                             "that assumes a thermal conductivity of "
                             "$K = 3/2 D_e n_e$ ");

  return params;
}

FVThermalConductivityDiffusion_Element::FVThermalConductivityDiffusion_Element(const InputParameters & parameters)
  : FVElementalKernel(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _coeff(2.0 / 3.0),

    _diffem(getADMaterialProperty<Real>("diffem")),

    _em(adCoupledValue("em")),
    _grad_em(adCoupledGradient("em")),
    _grad_u(_var.adGradSln())
{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000.;
  else
    mooseError("Potential units " + _potential_units + " not valid! Use V or kV.");
}

ADReal
FVThermalConductivityDiffusion_Element::computeQpResidual()
{
  return _r_units * _coeff * _diffem[_qp] *
          (std::exp(_u[_qp]) * _grad_u[_qp] * _r_units -
           std::exp(_u[_qp] - _em[_qp]) * std::exp(_em[_qp]) * _grad_em[_qp] * _r_units);
}
*/
