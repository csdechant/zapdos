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

#ifndef PRODUCTFIRSTORDERRXN2SPECIES_H
#define PRODUCTFIRSTORDERRXN2SPECIES_H

#include "Kernel.h"

// Forward Declaration
class ProductFirstOrderRxn2Species;

template <>
InputParameters validParams<ProductFirstOrderRxn2Species>();

class ProductFirstOrderRxn2Species : public Kernel
{
public:
  ProductFirstOrderRxn2Species(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  std::string _user_reactant_name;
  std::string _user_product_name;
  MooseVariable & _coupled_var;
  const VariableValue & _v;
  unsigned int _v_id;

  // The reaction coefficient
  const MaterialProperty<Real> & _reaction_coeff;
  const MaterialProperty<Real> & _n_gas;
};
#endif // PRODUCTFIRSTORDERRXN2SPECIES_H
