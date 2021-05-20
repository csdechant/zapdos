//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef EffectiveEFieldAdvection_H
#define EffectiveEFieldAdvection_H

#include "Kernel.h"

class EffectiveEFieldAdvection;

template <>
InputParameters validParams<EffectiveEFieldAdvection>();

class EffectiveEFieldAdvection : public Kernel
{
public:
  EffectiveEFieldAdvection(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  // Material properties

  Real _r_units;

  const MaterialProperty<Real> & _mu;
  const MaterialProperty<Real> & _sign;

private:
  // Coupled variables
  unsigned int _u_Efield_id;
  unsigned int _v_Efield_id;
  unsigned int _w_Efield_id;

  const VariableValue & _u_Efield;
  const VariableValue & _v_Efield;
  const VariableValue & _w_Efield;
};

#endif // EffectiveEFieldAdvection_H
