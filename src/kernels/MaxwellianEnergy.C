//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MaxwellianEnergy.h"

registerADMooseObject("ZapdosApp", MaxwellianEnergy);

InputParameters
MaxwellianEnergy::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredParam<unsigned>("component", "The Efield component that this is applied to.");
  params.addParam<std::string>("field_property_name",
                               "field_solver_interface_property",
                               "Name of the solver interface material property.");
  params.addClassDescription("");
  return params;
}

MaxwellianEnergy::MaxwellianEnergy(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _em(adCoupledValue("em")),
    _grad_em(adCoupledGradient("em")),
    _component(getParam<unsigned>("component")),
    _electric_field(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("field_property_name")))
{
}

ADReal
MaxwellianEnergy::computeQpResidual()
{
  return _test[_i][_qp] *
         (_electric_field[_qp](_component) +
          2.0 / 3.0 * _u[_qp] / std::exp(std::exp(_em[_qp])) * _grad_em[_qp](_component));
}
