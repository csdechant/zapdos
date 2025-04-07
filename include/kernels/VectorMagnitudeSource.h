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
#include "Function.h"

/**
 *  Supplies a source term based on the magnitude of a coupled vector
 */
class VectorMagnitudeSource : public Kernel
{
public:
  static InputParameters validParams();

  VectorMagnitudeSource(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

private:
  /// Coupled vector variable
  const VectorVariableValue & _variable_value;
};
