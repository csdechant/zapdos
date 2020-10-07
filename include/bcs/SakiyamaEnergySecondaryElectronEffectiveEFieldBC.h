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

#include "IntegratedBC.h"

class SakiyamaEnergySecondaryElectronEffectiveEFieldBC;

template <>
InputParameters validParams<SakiyamaEnergySecondaryElectronEffectiveEFieldBC>();

class SakiyamaEnergySecondaryElectronEffectiveEFieldBC : public IntegratedBC
{
public:
  SakiyamaEnergySecondaryElectronEffectiveEFieldBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _r_units;
  bool Te_dependent;

  // Coupled variables

  const VariableValue & _Ex;
  const VariableValue & _Ey;
  const VariableValue & _Ez;

  unsigned int _Ex_id;
  unsigned int _Ey_id;
  unsigned int _Ez_id;

  const VariableValue & _em;
  unsigned int _em_id;

  std::vector<MooseVariable *> _ip_var;
  std::vector<const VariableValue *> _ip;
  std::vector<unsigned int> _ip_id;

  std::vector<const MaterialProperty<Real> *> _sgnip;
  std::vector<const MaterialProperty<Real> *> _muip;
  Real _se_coeff;
  Real _user_se_energy;

  Real _a;
  Real _se_energy;
  Real _d_se_energy_d_u;
  Real _d_se_energy_d_em;
  RealVectorValue _ion_flux;
  RealVectorValue _d_ion_flux_d_EField;
  RealVectorValue _d_ion_flux_d_ip;

  std::vector<unsigned int> _ion_id;
  unsigned int _num_ions;
  unsigned int _ip_index;
  std::vector<unsigned int>::iterator _iter;
};
