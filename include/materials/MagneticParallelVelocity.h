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
#include "MooseTypes.h"

class SystemBase;
class MeshAlignment;
namespace libMesh
{
template <typename>
class NumericVector;
}

/**
 *  Material object that provides the vector form of the parallel velocity.
 */
class MagneticParallelVelocity : public ADMaterial
{
public:
  static InputParameters validParams();

  MagneticParallelVelocity(const InputParameters & parameters);

protected:
  virtual void computeProperties() override;
  virtual void computeQpProperties() override;

  /// Coupled magnetic field variable
  const ADVectorVariableValue & _magnetic_field;
  /// Gradient of magnetic field
  const ADVectorVariableGradient & _grad_magnetic_field;

  /// Coupled variable of the magnetic field magnitude
  const ADVariableValue & _magnetic_field_magnitude;
  /// Gradient of the magnetic field magnitude
  const ADVariableGradient & _grad_magnetic_field_magnitude;

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

  /// The velocity variable
  const VectorMooseVariable * const _velocity_var;

  /// A scalar Lagrange FE data member to compute the velocity second derivatives since
  /// they're currently not supported for vector FE types
  const FEBase * const & _scalar_lagrange_fe;

  ADTemplateVariableValue<ADRealVectorValue> vec_test;
  /*
  /// Coupled scalar form of the parallel velocity
  ADTemplateVariableValue<ADReal> mag_x;
  ADTemplateVariableValue<ADReal> mag_y;
  ADTemplateVariableValue<ADReal> mag_z;
  /// Gradient of the scalar form of the parallel velocity
  ADTemplateVariableValue<ADRealVectorValue> grad_mag_x;
  ADTemplateVariableValue<ADRealVectorValue> grad_mag_y;
  ADTemplateVariableValue<ADRealVectorValue> grad_mag_z;
  */
};
