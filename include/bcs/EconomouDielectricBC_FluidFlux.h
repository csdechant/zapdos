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

class EconomouDielectricBC_FluidFlux;

template <>
InputParameters validParams<EconomouDielectricBC_FluidFlux>();

/**
 * Implements a simple constant Neumann BC where grad(u)=value on the boundary.
 * Uses the term produced from integrating the diffusion operator by parts.
 */
class EconomouDielectricBC_FluidFlux : public IntegratedBC
{
public:
  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  EconomouDielectricBC_FluidFlux(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  /// Value of grad(u) on the boundary.

  const Real & _r_units;

  const VariableValue & _mean_en;
  unsigned int _mean_en_id;

  const VariableValue & _em;
  const VariableGradient & _grad_em;
  unsigned int _em_id;

  const VariableValue & _ip;
  const VariableGradient & _grad_ip;
  MooseVariable & _ip_var;
  unsigned int _ip_id;

  const VariableValue & _potential_ion;
  unsigned int _potential_ion_id;
  const VariableGradient & _grad_potential_ion;

  const VariableGradient & _grad_u_dot;
  const VariableValue & _u_dot;
  const VariableValue & _du_dot_du;

  const MaterialProperty<Real> & _e;
  const MaterialProperty<Real> & _sgnip;
  const MaterialProperty<Real> & _muip;
  const MaterialProperty<Real> & _diffip;


  const MaterialProperty<Real> & _sgnem;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _diffem;

  Real _d_actual_mean_en_d_mean_en;

  const MaterialProperty<Real> & _d_muem_d_actual_mean_en;
  Real _d_muem_d_mean_en;
  Real _d_actual_mean_en_d_em;
  Real _d_muem_d_em;

  const MaterialProperty<Real> & _d_diffem_d_actual_mean_en;
  Real _d_diffem_d_mean_en;
  Real _d_diffem_d_em;

  Real _user_se_coeff;
  Real _a;
  Real _b;

  const Real & _epsilon_d;
  const Real & _thickness;
  RealVectorValue _ion_flux;
  RealVectorValue _em_flux;
  RealVectorValue _d_ion_flux_d_potential_ion;
  RealVectorValue _d_em_flux_du;
  RealVectorValue _d_ion_flux_du;
  RealVectorValue _d_em_flux_d_mean_en;
  RealVectorValue _d_em_flux_d_em;
  RealVectorValue _d_ion_flux_d_ip;
  std::string _potential_units;

  Real _voltage_scaling;

  //const VariableValue & _surface_charge;
};
