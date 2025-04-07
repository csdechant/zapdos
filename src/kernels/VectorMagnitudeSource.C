//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "VectorMagnitudeSource.h"

registerMooseObject("ZapdosApp", VectorMagnitudeSource);

InputParameters
VectorMagnitudeSource::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Supplies a source term based on the magnitude of a coupled vector.");
  params.addRequiredCoupledVar("vector", "The vector variable to supply the magnitude.");
  return params;
}

VectorMagnitudeSource::VectorMagnitudeSource(const InputParameters & parameters)
  : Kernel(parameters), _variable_value(coupledVectorValue("vector"))
{
}

Real
VectorMagnitudeSource::computeQpResidual()
{
  return _test[_i][_qp] *
         (_u[_qp] - std::sqrt((_variable_value[_qp](0) * _variable_value[_qp](0)) +
                              (_variable_value[_qp](1) * _variable_value[_qp](1)) +
                              (_variable_value[_qp](2) * _variable_value[_qp](2))));
}
