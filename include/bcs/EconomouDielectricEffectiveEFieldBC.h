//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef EconomouDielectricEffectiveEFieldBC_H
#define EconomouDielectricEffectiveEFieldBC_H

#include "IntegratedBC.h"

class EconomouDielectricEffectiveEFieldBC;

template <>
InputParameters validParams<EconomouDielectricEffectiveEFieldBC>();

class EconomouDielectricEffectiveEFieldBC : public IntegratedBC
{
public:
  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  EconomouDielectricEffectiveEFieldBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  Real _r_units;

  const VariableValue & _mean_en;
  unsigned int _mean_en_id;
  const VariableValue & _em;
  unsigned int _em_id;
  std::vector<MooseVariable *> _ip_var;
  std::vector<const VariableValue *> _ip;
  const VariableGradient & _grad_u_dot;
  const VariableValue & _u_dot;
  const VariableValue & _du_dot_du;

  const VariableValue & _Ex;
  const VariableValue & _Ey;
  const VariableValue & _Ez;

  unsigned int _Ex_id;
  unsigned int _Ey_id;
  unsigned int _Ez_id;

  const MaterialProperty<Real> & _e;
  std::vector<const MaterialProperty<Real> *> _sgnip;
  std::vector<const MaterialProperty<Real> *> _muip;
  const MaterialProperty<Real> & _massem;
  Real _user_se_coeff;

  const Real & _epsilon_d;
  const Real & _thickness;
  Real _a;
  RealVectorValue _ion_flux;
  Real _v_thermal;
  RealVectorValue _em_flux;
  RealVectorValue _d_ion_flux_du;
  RealVectorValue _d_em_flux_du;
  Real _d_v_thermal_d_mean_en;
  RealVectorValue _d_em_flux_d_mean_en;
  Real _d_v_thermal_d_em;
  RealVectorValue _d_em_flux_d_em;
  RealVectorValue _d_ion_flux_d_ip;
  RealVectorValue _d_em_flux_d_ip;
  RealVectorValue _d_ion_flux_d_Efield;
  RealVectorValue _d_em_flux_d_Efield;
  std::string _potential_units;

  Real _voltage_scaling;

  std::vector<unsigned int> _ion_id;
  unsigned int _num_ions;
  unsigned int _ip_index;
  std::vector<unsigned int>::iterator _iter;
  std::vector<unsigned int>::iterator _iter_potential;
};

#endif // LymberopoulosElectronBC_H
