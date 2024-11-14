//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "FVFluxBC.h"

class Function;

class FVSakiyamaElectronDiffusionBC : public FVFluxBC
{
public:
  FVSakiyamaElectronDiffusionBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  Real _r_units;

  // Coupled variables
  const ADVariableValue & _mean_en;
  const ADVariableValue & _mean_en_neighbor;

  const MaterialProperty<Real> & _massem;
  const MaterialProperty<Real> & _e;

  ADReal _v_thermal;

  Moose::FV::InterpMethod _advected_interp_method;
};
