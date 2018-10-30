/****************************************************************/
/*                      DO NOT MODIFY THIS HEADER               */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*              (c) 2010 Battelle Energy Alliance, LLC          */
/*                      ALL RIGHTS RESERVED                     */
/*                                                              */
/*              Prepared by Battelle Energy Alliance, LLC       */
/*              Under Contract No. DE-AC07-05ID14517            */
/*              With the U. S. Department of Energy             */
/*                                                              */
/*              See COPYRIGHT for full restrictions             */
/****************************************************************/
#ifndef GENERICREACTION_H_
#define GENERICREACTION_H_

#include "Material.h"
/* #include "LinearInterpolation.h" */
// #include "SplineInterpolation.h"

class GenericReaction;

template <>
InputParameters validParams<GenericReaction>();

class GenericReaction : public Material
{
public:
  GenericReaction(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  MaterialProperty<Real> & _reaction_rate;

  Real _rate_value;

};

#endif // GenericReaction_H_
