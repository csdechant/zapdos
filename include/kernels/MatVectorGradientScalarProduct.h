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
 *  Contributes the product of the gradient of a variable and a
 *  vector (the vector is supplied as a material property)
 */
class MatVectorGradientScalarProduct : public ADKernel
{
public:
  static InputParameters validParams();

  MatVectorGradientScalarProduct(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Position units
  const Real _r_units;

  /// Vector variable as a material property
  const ADMaterialProperty<RealVectorValue> & _vector;
};
