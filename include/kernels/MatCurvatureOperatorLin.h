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
 * Contributes the bracket operation of two variables multiple by a
 * coefficient.
 */
class MatCurvatureOperatorLin : public ADKernel
{
public:
  static InputParameters validParams();

  MatCurvatureOperatorLin(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Position units
  const Real _r_units;

  /// Coefficient variable of the operation
  const ADMaterialProperty<Real> & _coeff;

  const ADVariableGradient & _grad_v;

  const ADMaterialProperty<RealVectorValue> & _magnetic_vector;

  const ADMaterialProperty<RealVectorValue> & _curl_magnetic_vector;

  const ADMaterialProperty<RealVectorValue> & _grad_mag_magnetic_field;

  const ADMaterialProperty<Real> & _mag_magnetic_field;
};
