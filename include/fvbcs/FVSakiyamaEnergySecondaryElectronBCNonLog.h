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

class FVSakiyamaEnergySecondaryElectronBCNonLog : public FVFluxBC
{
public:
  FVSakiyamaEnergySecondaryElectronBCNonLog(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  Real _r_units;
  bool Te_dependent;

  const ADVariableValue & _em;
  const ADVariableValue & _em_neighbor;

  Real _se_coeff;
  Real _user_se_energy;
  Real _a;
  ADReal _se_energy;

  // Coupled variables
  std::vector<const ADVariableValue *> _ion_elem;
  std::vector<const ADVariableValue *> _ion_neighbor;

  std::vector<const ADMaterialProperty<Real> *> _muion_elem;
  std::vector<const ADMaterialProperty<Real> *> _muion_neighbor;

  std::vector<const MaterialProperty<Real> *> _sgnion;

  unsigned int _num_ions;
  unsigned int _ip_index;
  std::vector<unsigned int>::iterator _iter;

  ADRealVectorValue _ion_flux;

  Moose::FV::InterpMethod _advected_interp_method;
};
