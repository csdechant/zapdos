//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVDriftDiffusionDoNothingBC.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVDriftDiffusionDoNothingBC);

InputParameters
FVDriftDiffusionDoNothingBC::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Boundary condition where the flux at the boundary is equal to the "
                             "bulk dift-diffusion equation");

  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVDriftDiffusionDoNothingBC::FVDriftDiffusionDoNothingBC(const InputParameters & parameters)
  : FVFluxBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _diff_elem(getADMaterialProperty<Real>("diff" + _var.name())),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diff" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name()))
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
FVDriftDiffusionDoNothingBC::computeQpResidual()
{
  using namespace Moose::FV;
  const auto state = determineState();

  ADReal dudn = Moose::FV::gradUDotNormal(*_face_info, _var, state, false);

  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info, state);

  const bool elem_is_upwind = -1.0 * grad_potential * _normal >= 0;
  const auto face =
      makeFace(*_face_info, Moose::FV::limiterType(_advected_interp_method), elem_is_upwind);
  ADReal u_interface = _var(face, determineState());

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  const auto & mu_neighbor = elem_is_interior ? _mu_elem[_qp] : _mu_neighbor[_qp];

  ADReal mobility;
  interpolate(
      Moose::FV::InterpMethod::Average, mobility, _mu_elem[_qp], mu_neighbor, *_face_info, true);

  const auto & diff_neighbor = elem_is_interior ? _diff_elem[_qp] : _diff_neighbor[_qp];

  ADReal diffusivity;
  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              diff_neighbor,
              *_face_info,
              true);

  return _r_units *
         (_sign[_qp] * mobility * -grad_potential * _r_units * std::exp(u_interface) * _normal -
          diffusivity * dudn * std::exp(u_interface) * _r_units);
}
