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

#include "ADKernel.h"

/*
 * The directional potential gradient for the Hasegawa-Wakatani model
 */
class DirectionalPotentialGradient : public ADKernel
{
public:
  static InputParameters validParams();

  DirectionalPotentialGradient(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:

  /// Position units
  const Real _r_units;

  /// Gradient of the coupled potential variable
  const ADVariableGradient & _grad_potential;

  /// The equilibrium density profile parameter
  const ADMaterialProperty<Real> & _k;

  /// Component of the gradient of the potential
  const int _component;
};
