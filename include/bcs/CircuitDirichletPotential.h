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

#include "ADNodalBC.h"

/**
 *  Dirichlet circuit boundary condition for potential
 *  (The current is given through an UserObject)
 */
class CircuitDirichletPotential : public ADNodalBC
{
public:
  static InputParameters validParams();

  CircuitDirichletPotential(const InputParameters & parameters);

protected:
  virtual ADReal computeQpResidual() override;

  /// Current provided as a postprocessor
  const PostprocessorValue & _current;
  /// 
  const Function & _surface_potential;
  const std::string _surface;
  const Real _resist;
  const Real _coulomb_charge;
  const Real _N_A;
  const std::string _potential_units;
  const Real _r_units;
  const bool _convert_moles;
  const Real _A;

  Real _current_sign;
  Real _voltage_scaling;
};
