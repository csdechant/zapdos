
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVEEDFElastic : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVEEDFElastic(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  std::string _reaction_coeff_name;
  std::string _reaction_name;

  const ADMaterialProperty<Real> & _reaction_coefficient;
  const MaterialProperty<Real> & _massGas;

  const ADVariableValue & _em;
  const ADVariableValue & _target;
  Real _massem;
};
