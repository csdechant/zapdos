//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef EffectiveEFieldSourceTerm_H
#define EffectiveEFieldSourceTerm_H

#include "Kernel.h"

class EffectiveEFieldSourceTerm;

template <>
InputParameters validParams<EffectiveEFieldSourceTerm>();

class EffectiveEFieldSourceTerm : public Kernel
{
public:
  EffectiveEFieldSourceTerm(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  // Material properties

  Real _r_units;
  Real _nu;

  const VariableGradient & _grad_potential;
  unsigned int _potential_id;

  int _component;
};

#endif // EffectiveEFieldSourceTerm_H
