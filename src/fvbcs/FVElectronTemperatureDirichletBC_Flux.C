//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVElectronTemperatureDirichletBC_Flux.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVElectronTemperatureDirichletBC_Flux);

InputParameters
FVElectronTemperatureDirichletBC_Flux::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredParam<Real>("value", "Value of the BC");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addClassDescription("Electron temperature boundary condition");
  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVElectronTemperatureDirichletBC_Flux::FVElectronTemperatureDirichletBC_Flux(
    const InputParameters & parameters)
  : FVFluxBC(parameters),

    _em(adCoupledValue("em")),
    _em_neighbor(adCoupledNeighborValue("em")),
    _value(getParam<Real>("value"))
{
  using namespace Moose::FV;

  const auto & advected_interp_method = getParam<MooseEnum>("advected_interp_method");
  if (advected_interp_method == "average")
    _advected_interp_method = InterpMethod::Average;
  else if (advected_interp_method == "upwind")
    _advected_interp_method = InterpMethod::Upwind;
  else
    mooseError("Unrecognized interpolation type ",
               static_cast<std::string>(advected_interp_method));
}

ADReal
FVElectronTemperatureDirichletBC_Flux::computeQpResidual()
{

  using namespace Moose::FV;

  const auto face = makeFace(*_face_info, Moose::FV::limiterType(_advected_interp_method), false);
  ADReal u_face = _var(face, determineState());

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  const auto & em_neighbor = elem_is_interior ? _em[_qp] : _em_neighbor[_qp];

  ADReal em_face;
  interpolate(Moose::FV::InterpMethod::Average, em_face, _em[_qp], em_neighbor, *_face_info, true);

  return 2.0 / 3 * std::exp(u_face - em_face) - _value;
}
