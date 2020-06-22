//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef ThermalConductivityDiffusion_H
#define ThermalConductivityDiffusion_H

#include "Kernel.h"

class ThermalConductivityDiffusion;

template <>
InputParameters validParams<ThermalConductivityDiffusion>();

class ThermalConductivityDiffusion : public Kernel
{
public:
  ThermalConductivityDiffusion(const InputParameters & parameters);
  virtual ~ThermalConductivityDiffusion();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _r_units;
  Real _coeff;

  const MaterialProperty<Real> & _diffem;
  const MaterialProperty<Real> & _d_diffem_d_actual_mean_en;

  const VariableValue & _em;
  const VariableGradient & _grad_em;
  unsigned int _em_id;

  Real _d_diffem_d_u;
  Real _d_diffem_d_em;
};

#endif /* ThermalConductivityDiffusion_H */
