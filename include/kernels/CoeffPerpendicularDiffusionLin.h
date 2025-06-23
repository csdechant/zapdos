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
 * This diffusion kernel is for magnetic perpendicular diffusion.
 */
class CoeffPerpendicularDiffusionLin : public ADKernel
{
public:
  static InputParameters validParams();

  CoeffPerpendicularDiffusionLin(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Position units
  const Real _r_units;

  /// Coupled magnetic unit vector
  const ADMaterialProperty<RealVectorValue> & _magnetic_unit_vector;

  /// The perpendicular diffusion coefficient
  const ADMaterialProperty<Real> & _perp_diffusivity;
};
