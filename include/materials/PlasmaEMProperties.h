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
 *  Provides the real and complex components, the spatial gradient, the first time derivative,
 *  and second time derivative of the plasma dielectric and the real and complex components of
 *  the plasma conductivity
 */
class PlasmaEMProperties : public ADMaterial
{
public:
  static InputParameters validParams();

  PlasmaEMProperties(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  /// Value of dielectric constant, real component
  ADMaterialProperty<Real> & _eps_r_real;
  /// Gradient of dielectric constant, real component
  ADMaterialProperty<RealVectorValue> & _eps_r_real_grad;
  /// First time derivative of dielectric constant, real component
  ADMaterialProperty<Real> & _eps_r_real_dot;
  /// Second time derivative of dielectric constant, real component
  ADMaterialProperty<Real> & _eps_r_real_dot_dot;
  /// Value of dielectric constant, imaginary component
  ADMaterialProperty<Real> & _eps_r_imag;
  /// Gradient of dielectric constant, imaginary component
  ADMaterialProperty<RealVectorValue> & _eps_r_imag_grad;
  /// First time derivative of dielectric constant, imaginary component
  ADMaterialProperty<Real> & _eps_r_imag_dot;
  /// Second time derivative of dielectric constant, imaginary component
  ADMaterialProperty<Real> & _eps_r_imag_dot_dot;
  /// Electron charge
  const Real _elementary_charge;
  /// Electron mass
  const Real _electron_mass;
  /// Vacuum permittivity
  const Real _eps_vacuum;
  /// pi
  const Real _pi;
  /// Electron-neutral collision frequency (Hz)
  const ADMaterialProperty<Real> & _nu;
  /// Gradient of electron-neutral collision frequency
  const ADMaterialProperty<RealVectorValue> & _grad_nu;
  /// Operating frequency (Hz)
  const Real & _frequency;
  /// Electron density coupled variable value
  const ADVariableValue & _em;
  /// Electron density coupled variable gradient
  const ADVariableGradient & _em_grad;
  /// Electron density variable
  const MooseVariable * _em_var;
  /// Electron density first time derivative
  const ADVariableValue & _em_dot;
  /// Electron density second time derivative
  const ADVariableValue & _em_dot_dot;
  /// Avogadro's number
  const MaterialProperty<Real> & _N_A;
  /// Value of conductivity coefficient, real component
  ADMaterialProperty<Real> & _sigma_pe_real;
  /// Value of conductivity coefficient, imaginary component
  ADMaterialProperty<Real> & _sigma_pe_imag;
  /// Variable that holds user coefficient type (relative or absolute)
  const MooseEnum _coeff_type;
};
