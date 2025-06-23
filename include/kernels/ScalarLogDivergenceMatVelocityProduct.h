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
 *  Contributes the product of a logarithmic case variable and the
 *  divergence of a vector (the vector is supplied as a material property
 */
class ScalarLogDivergenceMatVelocityProduct : public ADKernel
{
public:
  static InputParameters validParams();

  ScalarLogDivergenceMatVelocityProduct(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Position units
  const Real _r_units;

  /// Divergence of the vector variable as a material property
  const ADMaterialProperty<Real> & _div_vector;
};
