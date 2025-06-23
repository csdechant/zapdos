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
 * The adiabatic term for the Hasegawa-Wakatani model
 */
class AdiabaticTurbulence : public ADKernel
{
public:
  static InputParameters validParams();

  AdiabaticTurbulence(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:

  /// Coupled electron density
  const ADVariableValue & _density;
  /// Coupled potential variable
  const ADVariableValue & _potential;

  /// The density adiabaticity coefficient
  const ADMaterialProperty<Real> & _adiabaticity;
};
