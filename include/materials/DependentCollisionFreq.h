#pragma once

#include "ADMaterial.h"
// #include "SplineInterpolation.h"
#include "LinearInterpolation.h"

/**
 *
 */
class DependentCollisionFreq : public ADMaterial
{
public:
  static InputParameters validParams();

  DependentCollisionFreq(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  std::unique_ptr<LinearInterpolation> _nu_interpolation;

  bool _use_energy;
  ADMaterialProperty<Real> & _nu_neutral;
  ADMaterialProperty<RealVectorValue> & _grad_nu_neutral;
  const ADVariableValue & _em;
  const ADVariableValue & _mean_en;
  const ADVariableGradient & _grad_em;
  const ADVariableGradient & _grad_mean_en;
  const ADMaterialProperty<RealVectorValue> & _electric_field;

  const MaterialProperty<Real> & _k_boltz;
  const MaterialProperty<Real> & _T_gas;
  const MaterialProperty<Real> & _p_gas;

  const Real & _frequency;
  const Real _pi;
  const Real & _delta;
};
