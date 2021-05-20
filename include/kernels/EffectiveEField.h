//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef EffectiveEField_H
#define EffectiveEField_H

#include "Kernel.h"

class EffectiveEField;

template <>
InputParameters validParams<EffectiveEField>();

class EffectiveEField : public Kernel
{
public:
  EffectiveEField(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

private:
  /// Position units
  const Real _r_units;
  const Real _nu;

  unsigned _component;

  unsigned int _potential_id;
  const VariableGradient & _grad_potential;
};

#endif // EffectiveEField_H
