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
 *  Material object that provides the components of the velocity perpendicular
 *  to the magnetic field.
 */
class MagneticPerpVelocity : public ADMaterial
{
public:
  static InputParameters validParams();

  MagneticPerpVelocity(const InputParameters & parameters);

protected:
  // virtual void computeQpProperties() override;

  /// Coupled magnetic field variable
  const ADVectorVariableValue & _magnetic_field;
  /// Coupled curl of the magnetic field variable
  const ADVectorVariableCurl & _curl_magnetic_field;
  /// Coupled electric field variable
  const ADMaterialProperty<RealVectorValue> & _electric_field;
  /// Coupled curl of the electric field variable
  const ADMaterialProperty<RealVectorValue> & _curl_electric_field;

  /// E X B (electric field cross magnetic field) drift velocity
  ADMaterialProperty<RealVectorValue> & _E_cross_drift;

  /// DiverE X B (electric field cross magnetic field) drift velocity
  ADMaterialProperty<Real> & _div_E_cross_drift;

  /*
  /// Gradient of coupled pressure gradient
  const ADVariableGradient & _grad_pressure;
  /// Diamagnetic drift velocity
  ADMaterialProperty<RealVectorValue> & _diamagnetic_drift;
  */
};
