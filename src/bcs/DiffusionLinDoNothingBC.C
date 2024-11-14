//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DiffusionLinDoNothingBC.h"

registerMooseObject("ZapdosApp", DiffusionLinDoNothingBC);

InputParameters
DiffusionLinDoNothingBC ::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addRequiredParam<Real>("position_units", "Units of position");
  params.addClassDescription("Boundary condition where the election diffusion flux at the boundary "
                             "is equal to the bulk election diffusion equation");
  return params;
}

// This diffusion kernel should only be used with species whose values are in the logarithmic form.

DiffusionLinDoNothingBC ::DiffusionLinDoNothingBC(const InputParameters & parameters)
  : ADIntegratedBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    _diff(getADMaterialProperty<Real>("diff" + _var.name()))
{
}

ADReal
DiffusionLinDoNothingBC ::computeQpResidual()
{
  return -_diff[_qp] * _grad_u[_qp] * _r_units * _normals[_qp] * _test[_i][_qp] * _r_units;
}
