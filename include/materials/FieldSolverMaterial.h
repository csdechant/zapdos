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

#include "ADMaterial.h"

/**
 * Material object that provides an interface to an external electromagnetic
 * field solver for all Zapdos objects via the "field" material property. Default
 * is an electrostatic interface, where the `potential` coupled variable parameter
 * must be provided.
 */
class FieldSolverMaterial : public ADMaterial
{
public:
  static InputParameters validParams();

  FieldSolverMaterial(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Gradient of coupled electrostatic potential
  const ADVariableGradient & _grad_potential;

  /// Coupled electric field variable
  const ADVectorVariableValue & _electric_field;

  /// Coupled curl of the electric field variable
  const ADVectorVariableValue & _electric_field_curl;

  /// Electric field material property
  ADMaterialProperty<RealVectorValue> & _field;

  /// Electric field curl material property
  ADMaterialProperty<RealVectorValue> & _field_curl;

  /// Variable that holds user solver setting (electrostatic or electromagnetic)
  const MooseEnum _mode;
};
