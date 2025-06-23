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
 *  Material object that provides the velocity and divergence of the diamagnetic drift.
 */
class DiamagneticDriftVelocity : public ADMaterial
{
public:
  static InputParameters validParams();

  DiamagneticDriftVelocity(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Coupled magnetic unit vector
  const ADMaterialProperty<RealVectorValue> & _magnetic_unit_vector;
  /// Curl of the magnetic unit vector
  const ADMaterialProperty<RealVectorValue> & _curl_magnetic_unit_vector;

  /// Magnitude of the magnetic unit vector
  const ADMaterialProperty<Real> & _mag_magnetic_field;
  /// Gradient of the magnitude of the magnetic unit vector
  const ADMaterialProperty<RealVectorValue> & _grad_mag_magnetic_field;

  /// Coupled charge density variable
  const ADVariableValue & _density;
  /// Gradient of the charge density variable
  const ADVariableGradient & _grad_density;
  /// Elementary charge
  const MaterialProperty<Real> & _e;
  /// Charge sign of the species
  const MaterialProperty<Real> & _sgn;
  /// Gradient of the charge species pressure
  const ADVariableGradient & _grad_pressure;

  /// Diamagnetic drift velocity
  ADMaterialProperty<RealVectorValue> & _diamagnetic_drift;
  /// Divergence of the diamagnetic drift velocity
  ADMaterialProperty<Real> & _div_diamagnetic_drift;
};
