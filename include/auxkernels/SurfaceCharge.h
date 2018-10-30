#ifndef SurfaceCharge_H
#define SurfaceCharge_H

#include "AuxKernel.h"

class SurfaceCharge;

template <>
InputParameters validParams<SurfaceCharge>();

class SurfaceCharge : public AuxKernel
{
public:
  SurfaceCharge(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const MooseArray<Point> & _normals;

  Real _time_units;
  Real _r_units;
  Real _r_em;
  Real _r_ip;

  const VariableValue & _em;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _massem;

  const VariableValue & _ip;
  const MaterialProperty<Real> & _muArp;
  const MaterialProperty<Real> & _massArp;
  const MaterialProperty<Real> & _kb;
  const MaterialProperty<Real> & _T_heavy;

  const VariableGradient & _grad_potential;
  const VariableValue & _mean_en;

  const MaterialProperty<Real> & _e;
  bool _convert_moles;
  Real _N_A;
  Real _a;
  Real _b;
  Real _v_thermal_em;
  Real _v_thermal_ip;
  Real _electron_flux;
  Real _ion_flux;
};

#endif // SurfaceCharge_H
