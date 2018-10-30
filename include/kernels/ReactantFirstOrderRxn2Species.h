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

#ifndef REACTANTFIRSTORDERRXN2SPECIES_H
#define REACTANTFIRSTORDERRXN2SPECIES_H

#include "Kernel.h"

// Forward Declaration
class ReactantFirstOrderRxn2Species;

template <>
InputParameters validParams<ReactantFirstOrderRxn2Species>();

class ReactantFirstOrderRxn2Species : public Kernel
{
public:
  ReactantFirstOrderRxn2Species(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  // The reaction coefficient
  const MaterialProperty<Real> & _reaction_coeff;
  // const VariableValue & _em;
  const MaterialProperty<Real> & _n_gas;
};
#endif // REACTANTFIRSTORDERRXN2SPECIES_H
