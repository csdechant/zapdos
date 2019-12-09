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

#include "NodalVariablePostprocessor.h"

// Forward Declarations
class L2TimeDifference;

template <>
InputParameters validParams<L2TimeDifference>();

/**
 * Computes the "nodal" L2-norm of the coupled variable, which is
 * defined by summing the square of its value at every node and taking
 * the square root.
 */
class L2TimeDifference : public NodalVariablePostprocessor
{
public:
  static InputParameters validParams();

  L2TimeDifference(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual Real getValue() override;
  virtual void threadJoin(const UserObject & y) override;

protected:
  Real _sum_of_squares;
  const VariableValue & _value_old;
};
