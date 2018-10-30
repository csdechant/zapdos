/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef REACTANTABRXN2_H
#define REACTANTABRXN2_H

#include "Kernel.h"

// Forward Declaration
class ReactantABRxn2;

template <>
InputParameters validParams<ReactantABRxn2>();

class ReactantABRxn2 : public Kernel
{
public:
  ReactantABRxn2(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  // The reaction coefficient
  // MooseVariable & _coupled_var_A;
  const MaterialProperty<Real> & _reaction_coeff;
  const VariableValue & _v;
  unsigned int _v_id;
  const MaterialProperty<Real> & _n_gas;
  Real _stoichiometric_coeff;

};
#endif // REACTANTABRXN2_H
