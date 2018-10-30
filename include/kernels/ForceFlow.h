#ifndef FORCEFLOW_H
#define FORCEFLOW_H

#include "Kernel.h"

class ForceFlow;

template <>
InputParameters validParams<ForceFlow>();

// This diffusion kernel should only be used with species whose values are in the logarithmic form.

class ForceFlow : public Kernel
{
public:
  ForceFlow(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned jvar);

  // Coupled variables
  const VariableValue & _u_vel;
  const VariableValue & _v_vel;
  const VariableValue & _w_vel;

  // Variable numberings
  unsigned _u_vel_var_number;
  unsigned _v_vel_var_number;
  unsigned _w_vel_var_number;

  //position Scaling
  Real _r_units;
  Real _time_units;
};

#endif /* FORCEFLOW_H */
