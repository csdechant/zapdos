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

// MOOSE includes
#include "AuxKernel.h"

/**
 * Compute an elemental field variable (single value per element) equal
 * to the Lp-norm of the differenece of two coupled Variables.
 */
class ElementLpDiffNormAux : public AuxKernel
{
public:
  static InputParameters validParams();

  ElementLpDiffNormAux(const InputParameters & parameters);

  virtual void compute() override;

protected:
  virtual Real computeValue() override;

  // The exponent used in the norm
  Real _p;

  /// First variable to compute the diff of
  const VariableValue & _coupled_v;
  /// Second variable to compute the diff of
  const VariableValue & _coupled_w;
};
