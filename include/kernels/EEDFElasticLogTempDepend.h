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

#include "Kernel.h"

class EEDFElasticLogTempDepend;

template <>
InputParameters validParams<EEDFElasticLogTempDepend>();

class EEDFElasticLogTempDepend : public Kernel
{
public:
  EEDFElasticLogTempDepend(const InputParameters & parameters);
  virtual ~EEDFElasticLogTempDepend();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  std::string _reaction_coeff_name;
  const MaterialProperty<Real> & _reaction_coeff;
  const MaterialProperty<Real> & _massTarget;
  const MaterialProperty<Real> & _d_k_d_actual_mean_en;

  const VariableValue & _em;
  unsigned int _em_id;
  const VariableValue & _target;
  unsigned int _target_id;

  const MaterialProperty<Real> & _e;
  const MaterialProperty<Real> & _kb;
  const MaterialProperty<Real> & _T_Target;

  Real _massem;
};
