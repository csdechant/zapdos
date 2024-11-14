//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVSakiyamaEnergyDiffusionBC.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVSakiyamaEnergyDiffusionBC);

InputParameters
FVSakiyamaEnergyDiffusionBC::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Kinetic electron boundary condition"
                             "(Based on DOI: https://doi.org/10.1116/1.579300)");

  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVSakiyamaEnergyDiffusionBC::FVSakiyamaEnergyDiffusionBC(const InputParameters & parameters)
  : FVFluxBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    // Coupled Variables
    _em(adCoupledValue("em")),
    _em_neighbor(adCoupledNeighborValue("em")),

    _massem(getMaterialProperty<Real>("massem")),
    _e(getMaterialProperty<Real>("e")),
    _v_thermal(0)
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
FVSakiyamaEnergyDiffusionBC::computeQpResidual()
{
  using namespace Moose::FV;

  const auto face = makeFace(*_face_info, Moose::FV::limiterType(_advected_interp_method), false);
  ADReal u_interface = _var(face, determineState());

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  const auto & em_neighbor = elem_is_interior ? _em[_qp] : _em_neighbor[_qp];

  ADReal em_interface;
  interpolate(
      Moose::FV::InterpMethod::Average, em_interface, _em[_qp], em_neighbor, *_face_info, true);

  _v_thermal = std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(u_interface - em_interface) /
                         (M_PI * _massem[_qp]));

  return _r_units * ((5.0 / 3.0) * 0.25 * _v_thermal * std::exp(u_interface));
}
