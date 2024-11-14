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
#pragma once

#include "ADMaterial.h"

class ADCoupledEEDFRates : public ADMaterial
{
public:
  static InputParameters validParams();
  ADCoupledEEDFRates(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  ADMaterialProperty<Real> & _rate_coefficient;

  const ADVariableValue & _rate_value;
  const ADVariableValue & _d_rate_d_actual_mean_en;

  const ADVariableValue & _em;
  const ADVariableValue & _mean_en;
};
