//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CoeffPerpendicularDiffusion.h"

registerADMooseObject("ZapdosApp", CoeffPerpendicularDiffusion);

InputParameters
CoeffPerpendicularDiffusion::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addParam<Real>("position_units", 1.0, "Units of position.");
  params.addParam<std::string>("magnetic_unit_vector_name",
                               "magnetic_unit_vector",
                               "Name of the magnetic unit vector as a material property.");

  params.addClassDescription(
      "The magnetic perpendicular diffusion (densities must be in logarithmic form), where the "
      "Jacobian is computed using forward automatic differentiation.");
  return params;
}

CoeffPerpendicularDiffusion::CoeffPerpendicularDiffusion(const InputParameters & parameters)
  : ADKernel(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _magnetic_unit_vector(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("magnetic_unit_vector_name"))),
    _perp_diffusivity(getADMaterialProperty<Real>("perp_diff" + _var.name()))
{
}

ADReal
CoeffPerpendicularDiffusion::computeQpResidual()
{

  return -_perp_diffusivity[_qp] * -_grad_test[_i][_qp] *
         (exp(_u[_qp]) * _grad_u[_qp] * _r_units -
          _magnetic_unit_vector[_qp] *
              (_magnetic_unit_vector[_qp] * exp(_u[_qp]) * _grad_u[_qp] * _r_units));
}
