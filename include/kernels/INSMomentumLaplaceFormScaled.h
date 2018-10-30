//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef INSMOMENTUMLAPLACEFORMSCALED_H
#define INSMOMENTUMLAPLACEFORMSCALED_H

#include "INSMomentumBase.h"

// Forward Declarations
class INSMomentumLaplaceFormScaled;

template <>
InputParameters validParams<INSMomentumLaplaceFormScaled>();

/**
 * This class computes momentum equation residual and Jacobian viscous
 * contributions for the "Laplacian" form of the governing equations.
 */
class INSMomentumLaplaceFormScaled : public INSMomentumBase
{
public:
  INSMomentumLaplaceFormScaled(const InputParameters & parameters);

  virtual ~INSMomentumLaplaceFormScaled() {}

protected:
  virtual Real computeQpResidualViscousPart() override;
  virtual Real computeQpJacobianViscousPart() override;
  virtual Real computeQpOffDiagJacobianViscousPart(unsigned jvar) override;

  Real _r_units;
};

#endif
