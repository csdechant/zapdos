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

class EconomouDielectricWithEffEfieldBC;

template <>
InputParameters validParams<EconomouDielectricWithEffEfieldBC>();

class EconomouDielectricWithEffEfieldBC : public IntegratedBC
{
public:
  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  EconomouDielectricWithEffEfieldBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  Real _r_units;

  const VariableValue & _mean_en;
  unsigned int _mean_en_id;
  const VariableValue & _em;
  unsigned int _em_id;
  const VariableValue & _ip;
  MooseVariable & _ip_var;
  unsigned int _ip_id;


  const VariableValue & _Ex;
  const VariableValue & _Ey;
  const VariableValue & _Ez;

  unsigned int _Ex_id;
  unsigned int _Ey_id;
  unsigned int _Ez_id;


  const VariableGradient & _grad_u_dot;
  const VariableValue & _u_dot;
  const VariableValue & _du_dot_du;

  const MaterialProperty<Real> & _e;
  const MaterialProperty<Real> & _epsilon_0;
  const MaterialProperty<Real> & _N_A;

  const MaterialProperty<Real> & _sgnip;
  const MaterialProperty<Real> & _muip;
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
};