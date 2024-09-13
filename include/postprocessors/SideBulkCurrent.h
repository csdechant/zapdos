//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

// MOOSE includes
#include "SideIntegralVariablePostprocessor.h"

/**
 * This postprocessor computes a side integral of the mass flux.
 */
class SideBulkCurrent : public SideIntegralVariablePostprocessor
{
public:
  SideBulkCurrent(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  virtual Real computeQpIntegral();

  Real _r_units;

  const MaterialProperty<Real> & _sgn;
  const ADMaterialProperty<Real> & _mu;
  const ADMaterialProperty<Real> & _diff;

  const VariableGradient & _grad_potential;

  Real _a;
};
