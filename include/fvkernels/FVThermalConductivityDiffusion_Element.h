/*
#pragma once

#include "FVElementalKernel.h"

class FVThermalConductivityDiffusion_Element : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVThermalConductivityDiffusion_Element(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  /// Position units
  Real _r_units;
  Real _coeff;

  const ADMaterialProperty<Real> & _diffem;

  const ADVariableValue & _em;
  const ADVariableGradient & _grad_em;
  const ADVariableGradient & _grad_u;
};
*/
