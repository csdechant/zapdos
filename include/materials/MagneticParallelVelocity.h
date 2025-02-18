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
 *  Material object that provides the vector form of the parallel velocity.
 */
class MagneticParallelVelocity : public ADMaterial
{
public:
  static InputParameters validParams();

  MagneticParallelVelocity(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Coupled magnetic field variable
  const ADVectorVariableValue & _magnetic_field;
  /// Gradient of magnetic field
  const ADVectorVariableGradient & _grad_magnetic_field;

  /// Coupled scalar form of the parallel velocity
  const ADVariableValue & _scalar_parallel_vec;
  /// Gradient of the scalar form of the parallel velocity
  const ADVariableGradient & _grad_scalar_vec;

  /// If true, convert the magnetic field into a unit vector
  bool _use_unit_vector;

  /// Vector form of the parallel velocity
  ADMaterialProperty<RealVectorValue> & _parallel_velocity;
  /// Divergence of the vector form of the parallel velocity
  ADMaterialProperty<Real> & _div_parallel_velocity;
};
