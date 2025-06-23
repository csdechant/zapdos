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
 *  Material object that provides the velocity and divergence of the E cross B drift.
 */
class EcrossBDriftVelocity : public ADMaterial
{
public:
  static InputParameters validParams();

  EcrossBDriftVelocity(const InputParameters & parameters);

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

  /// Coupled electric field
  const ADMaterialProperty<RealVectorValue> & _electric_field;
  /// Curl of the electric field
  const ADMaterialProperty<RealVectorValue> & _curl_electric_field;

  /// E X B drift velocity
  ADMaterialProperty<RealVectorValue> & _E_cross_B_drift;
  /// Divergence of the E X B drift velocity
  ADMaterialProperty<Real> & _div_E_cross_B_drift;
};
