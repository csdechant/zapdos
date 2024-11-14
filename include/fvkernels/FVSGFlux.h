
#pragma once

#include "FVFluxKernel.h"

class FVSGFlux : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVSGFlux(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _mu_elem;
  const ADMaterialProperty<Real> & _mu_neighbor;

  const ADMaterialProperty<Real> & _diff_elem;
  const ADMaterialProperty<Real> & _diff_neighbor;

  const MaterialProperty<Real> & _sign;
  const Real _r_units;

  Moose::FV::InterpMethod _advected_interp_method;
};
