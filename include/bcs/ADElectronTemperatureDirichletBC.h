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

#include "ADNodalBC.h"

/**
 * Implements a simple coupled boundary condition where u=v on the boundary.
 */
class ADElectronTemperatureDirichletBC : public ADNodalBC
{
public:
  static InputParameters validParams();

  ADElectronTemperatureDirichletBC(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  const ADVariableValue & _em;
  Real _value;
  Real _penalty_value;
};