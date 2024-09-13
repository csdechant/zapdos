#pragma once

#include "ADMaterial.h"
// #include "SplineInterpolation.h"
#include "LinearInterpolation.h"

/**
 *
 */
class ReduceEFieldDependentPlasmaDielectricConstant : public ADMaterial
{
public:
  static InputParameters validParams();

  ReduceEFieldDependentPlasmaDielectricConstant(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  std::unique_ptr<LinearInterpolation> _nu_interpolation;
  std::unique_ptr<LinearInterpolation> _temp_interpolation;

  ADMaterialProperty<Real> & _sigma_pe_real;

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
  const Real & _user_nu;

  /// Operating frequency (Hz)
  const Real & _frequency;

  /// Electron density coupled variable value
  const ADVariableValue & _em;

  /// Electron density coupled variable gradient
  const ADVariableGradient & _em_grad;

  /// Electron density variable
  MooseVariable * _em_var;

  /// Electron density first time derivative
  const ADVariableValue & _em_dot;

  /// Electron density second time derivative
  const ADVariableValue & _em_dot_dot;

  const ADMaterialProperty<RealVectorValue> & _electric_field;

  const MaterialProperty<Real> & _k_boltz;
  const MaterialProperty<Real> & _T_gas;
  const MaterialProperty<Real> & _p_gas;

  ADMaterialProperty<Real> & _e_temp;
};
