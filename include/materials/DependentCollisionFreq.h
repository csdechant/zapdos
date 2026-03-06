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
#include "SplineInterpolation.h"

/**
 *  Material property for electron momentum-transfer collision frequency
 */
class DependentCollisionFreq : public ADMaterial
{
public:
  static InputParameters validParams();

  DependentCollisionFreq(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Spline Interpolation fuction for electron momentum-transfer collision frequency
  SplineInterpolation _nu_interpolation;
  /// Electron momentum-transfer collision frequency
  ADMaterialProperty<Real> & _nu_neutral;
  /// Gradient of the electron momentum-transfer collision frequency
  ADMaterialProperty<RealVectorValue> & _grad_nu_neutral;
  /// Variable that holds user interpolation type (mean energy or reduce electric field)
  const MooseEnum _interp;
  /// Electron density
  const ADVariableValue & _em;
  /// Electron mean energy density
  const ADVariableValue & _mean_en;
  /// Gradient of electron density
  const ADVariableGradient & _grad_em;
  /// Gradient of mean energy density
  const ADVariableGradient & _grad_mean_en;
  /// Electric field vector variable
  const ADMaterialProperty<RealVectorValue> & _electric_field;

  /// Coupled background gas temperature variable
  const VariableValue & _T_gas;
  /// Coupled background gas pressure variable
  const VariableValue & _p_gas;
  /// Drive frequency of the system
  const Real & _frequency;
  /// Constant of pi
  const Real _pi;
  /// Doppler broadening parameter
  const Real & _delta;
};
