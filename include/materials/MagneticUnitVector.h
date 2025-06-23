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
 *  Material object that provides the magnetic unit vector
 *  and the gradient of the magnitude of the magnetic field.
 */
class MagneticUnitVector : public ADMaterial
{
public:
  static InputParameters validParams();

  MagneticUnitVector(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Coupled magnetic field variable
  const ADVectorVariableValue & _magnetic_field;
  /// Gradient of magnetic field
  const ADVectorVariableGradient & _grad_magnetic_field;
  /// Curl of magnetic field
  const ADVectorVariableCurl & _curl_magnetic_field;

  /// Gradient of the magnitude of the magnetic field
  ADMaterialProperty<Real> & _mag_magnetic_field;
  /// Gradient of the magnitude of the magnetic field
  ADMaterialProperty<RealVectorValue> & _grad_mag_magnetic_field;

  /// The magnetic unit vector
  ADMaterialProperty<RealVectorValue> & _magnetic_unit_vector;
  /// Divergence of the magnetic unit vector
  ADMaterialProperty<Real> & _div_magnetic_unit_vector;
  /// Curl of the magnetic unit vector
  ADMaterialProperty<RealVectorValue> & _curl_magnetic_unit_vector;
};
