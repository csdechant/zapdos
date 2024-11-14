
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVShootMethod : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVShootMethod(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  const ADVariableValue & _density_at_start_cycle;
  const ADVariableValue & _density_at_end_cycle;
  const ADVariableValue & _sensitivity;
  const Real & _limit;
};
