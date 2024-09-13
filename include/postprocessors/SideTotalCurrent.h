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
class SideTotalCurrent : public SideIntegralVariablePostprocessor
{
public:
  SideTotalCurrent(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  virtual Real computeQpIntegral();

  Real _r_units;

  const MaterialProperty<Real> & _sgnem;
  const ADMaterialProperty<Real> & _muem;
  const ADMaterialProperty<Real> & _diffem;

  const VariableValue & _ion;
  const VariableGradient & _grad_ion;
  const MaterialProperty<Real> & _sgnion;
  const ADMaterialProperty<Real> & _muion;
  const ADMaterialProperty<Real> & _diffion;

  const VariableGradient & _grad_potential;

  Real em_flux;
  Real ion_flux;

  Real _a;

  const VariableValue & _mean_en;

  const MaterialProperty<Real> & _massem;
  const MaterialProperty<Real> & _e;

  Real _v_thermal;

  Real _user_se_coeff;
};
