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

#ifndef ADDDRIFTDIFFUSIONACTIONEM_H
#define ADDDRIFTDIFFUSIONACTIONEM_H

#include "AddVariableAction.h"
#include "Action.h"

class AddDriftDiffusionActionEM;

template <>
InputParameters validParams<AddDriftDiffusionActionEM>();

class AddDriftDiffusionActionEM : public AddVariableAction
{
public:
  AddDriftDiffusionActionEM(InputParameters params);

  virtual void act();

};

#endif // AddDriftDiffusionActionEM_H
