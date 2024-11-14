
#pragma once

#include "FVFluxKernel.h"

class FVCoeffDiffusion : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVCoeffDiffusion(const InputParameters & params);

protected:
  ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _diff_elem;
  const ADMaterialProperty<Real> & _diff_neighbor;
  const Real _r_units;

  Moose::FV::InterpMethod _advected_interp_method;
};
