//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef DIELECTRICPOTENTIALNEUMANNBC_H
#define DIELECTRICPOTENTIALNEUMANNBC_H

#include "IntegratedBC.h"

// Forward Declarations
class DielectricPotentialNeumannBC;

template <>
InputParameters validParams<DielectricPotentialNeumannBC>();

/**
 * Implements a simple constant Neumann BC where grad(u)=alpha * v on the boundary.
 * Uses the term produced from integrating the diffusion operator by parts.
 */
class DielectricPotentialNeumannBC : public IntegratedBC
{
public:
  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  DielectricPotentialNeumannBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

private:

  Real _eps;
  const VariableValue & _surface_charge;

  Real _r_units;
  std::string _potential_units;
  Real _voltage_scaling;
};

#endif // DielectricPotentialNeumannBC_H
