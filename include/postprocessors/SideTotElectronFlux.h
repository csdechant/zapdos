#ifndef SIDETOTELECTRONFLUX_H
#define SIDETOTELECTRONFLUX_H

// MOOSE includes
#include "SideIntegralVariablePostprocessor.h"

// Forward Declarations
class SideTotElectronFlux;

template <>
InputParameters validParams<SideTotElectronFlux>();

/**
 * This postprocessor computes a side integral of the mass flux.
 */
class SideTotElectronFlux : public SideIntegralVariablePostprocessor
{
public:
  SideTotElectronFlux(const InputParameters & parameters);

protected:
  virtual Real computeQpIntegral();

  Real _r_units;
  Real _time_units;
  Real _r;

  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _massem;

  const VariableValue & _mean_en;
  const VariableGradient & _grad_potential;

  const MaterialProperty<Real> & _e;
  Real _a;
  Real _v_thermal_em;
};

#endif // SideTotElectronFlux_H
