//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADIntegratedBC.h"

class ADPenaltyShootingMethodBC : public ADIntegratedBC
{
public:
  static InputParameters validParams();

  ADPenaltyShootingMethodBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

private:
  /// Penalty value
  const Real _p;

  const ADVariableValue & _density_at_start_cycle;
  const ADVariableValue & _density_at_end_cycle;
  const ADVariableValue & _sensitivity;
  const Real & _limit;
};
