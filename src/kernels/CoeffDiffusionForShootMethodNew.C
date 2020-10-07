//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CoeffDiffusionForShootMethodNew.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", CoeffDiffusionForShootMethodNew);

template <>
InputParameters
validParams<CoeffDiffusionForShootMethodNew>()
{
  InputParameters params = validParams<Diffusion>();
  params.addRequiredCoupledVar("density", "The log of the accelerated density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("The derivative of the generic diffusion term used to calculate the "
                             "sensitivity value for the shoothing method."
                             "(Densities must be in log form)");
  return params;
}

CoeffDiffusionForShootMethodNew::CoeffDiffusionForShootMethodNew(const InputParameters & parameters)
  : Diffusion(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _density_var(*getVar("density", 0)),
    _diffusivity(getMaterialProperty<Real>("diff" + _density_var.name()))
{
}

CoeffDiffusionForShootMethodNew::~CoeffDiffusionForShootMethodNew() {}

Real
CoeffDiffusionForShootMethodNew::computeQpResidual()
{
  return _grad_test[_i][_qp] * _r_units * _diffusivity[_qp] *
         _grad_u[_qp] * _r_units;
}

Real
CoeffDiffusionForShootMethodNew::computeQpJacobian()
{
  return _grad_test[_i][_qp] * _r_units * _diffusivity[_qp] *
         _grad_phi[_j][_qp] * _r_units;
}
