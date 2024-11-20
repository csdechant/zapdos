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

#include "ADVectorKernel.h"
#include "Function.h"

/**
 *  Calculates the ambipolar electric field based on electron and ion transport coefficients
 */
class AmbipolarEField : public ADVectorKernel
{
public:
  static InputParameters validParams();

  AmbipolarEField(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Electron density
  const ADVariableValue & _em;
  /// Gradient of electron density
  const ADVariableGradient & _grad_em;
  /// Electron diffusion coefficient
  const ADMaterialProperty<Real> & _diffem;
  /// Electron mobility coefficient
  const ADMaterialProperty<Real> & _muem;
  /// Ion diffusion coefficient
  const ADMaterialProperty<Real> & _diffion;
  /// Ion mobility coefficient
  const ADMaterialProperty<Real> & _muion;
};
