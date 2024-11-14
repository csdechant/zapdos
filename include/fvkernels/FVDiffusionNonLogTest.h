
#pragma once

#include "FVFluxKernel.h"

class FVDiffusionNonLogTest : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVDiffusionNonLogTest(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  // const ADVariableValue & _potential_elem;
  // const ADVariableValue & _potential_neighbor;

  // const ADMaterialProperty<Real> & _mu_elem;
  // const ADMaterialProperty<Real> & _mu_neighbor;

  const ADMaterialProperty<Real> & _diff_elem;
  const ADMaterialProperty<Real> & _diff_neighbor;

  // const MaterialProperty<Real> & _sign;
  const Real _r_units;

  Moose::FV::InterpMethod _advected_interp_method;
};
