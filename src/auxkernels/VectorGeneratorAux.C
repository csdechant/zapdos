//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "VectorGeneratorAux.h"

registerMooseObject("MooseApp", VectorGeneratorAux);

InputParameters
VectorGeneratorAux::validParams()
{
  InputParameters params = VectorAuxKernel::validParams();
  params.addClassDescription("");
  params.addRequiredCoupledVar("u", "x-component");
  params.addCoupledVar("v", 0, "y-component"); // only required in 2D and 3D
  params.addCoupledVar("w", 0, "z-component"); // only required in 3D
  return params;
}

VectorGeneratorAux::VectorGeneratorAux(const InputParameters & parameters)
  : VectorAuxKernel(parameters),
    _x_comp(coupledValue("u")),
    _y_comp(coupledValue("v")),
    _z_comp(coupledValue("w"))
{
}

RealVectorValue
VectorGeneratorAux::computeValue()
{
  RealVectorValue Vector(_x_comp[_qp], _y_comp[_qp], _z_comp[_qp]);

  return Vector;
}
