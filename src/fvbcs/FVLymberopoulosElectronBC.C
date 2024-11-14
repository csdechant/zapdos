//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVLymberopoulosElectronBC.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVLymberopoulosElectronBC);

InputParameters
FVLymberopoulosElectronBC::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredParam<Real>("ks", "The recombination coefficient");
  params.addRequiredParam<Real>("gamma", "The secondary electron coefficient");
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredCoupledVar("ion", "The ion density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Simpified kinetic electron boundary condition"
                             "(Based on DOI: https://doi.org/10.1063/1.352926)");

  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVLymberopoulosElectronBC::FVLymberopoulosElectronBC(const InputParameters & parameters)
  : FVFluxBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _ks(getParam<Real>("ks")),
    _gamma(getParam<Real>("gamma")),

    _sign(1)
{

  _num_ions = coupledComponents("ion");

  // Resize the vectors to store _num_ions values:
  _ion_elem.resize(_num_ions);
  _ion_neighbor.resize(_num_ions);
  _muion_elem.resize(_num_ions);
  _muion_neighbor.resize(_num_ions);
  _sgnion.resize(_num_ions);

  // Retrieve the values for each ion and store in the relevant vectors.
  // Note that these need to be dereferenced to get the values inside the
  // main body of the code.
  // e.g. instead of "_ip[_qp]" it would be "(*_ip[i])[_qp]", where "i"
  // refers to a single ion species.
  for (unsigned int i = 0; i < _num_ions; ++i)
  {
    _ion_elem[i] = &adCoupledValue("ion", i);
    _ion_neighbor[i] = &adCoupledNeighborValue("ion", i);
    _muion_elem[i] = &getADMaterialProperty<Real>("mu" + (*getFieldVar("ion", i)).name());
    _muion_neighbor[i] =
        &getNeighborADMaterialProperty<Real>("mu" + (*getFieldVar("ion", i)).name());
    _sgnion[i] = &getMaterialProperty<Real>("sgn" + (*getFieldVar("ion", i)).name());
  }

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
FVLymberopoulosElectronBC::computeQpResidual()
{
  using namespace Moose::FV;
  const auto state = determineState();

  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info, state);

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  _ion_flux.zero();
  for (unsigned int i = 0; i < _num_ions; ++i)
  {
    ADReal muion;
    const auto & muion_neighbor =
        elem_is_interior ? (*_muion_elem[i])[_qp] : (*_muion_neighbor[i])[_qp];

    interpolate(
        InterpMethod::Average, muion, (*_muion_elem[i])[_qp], muion_neighbor, *_face_info, true);

    ADReal ion_face;
    const auto & ion_neighbor = elem_is_interior ? (*_ion_elem[i])[_qp] : (*_ion_neighbor[i])[_qp];

    interpolate(_advected_interp_method,
                ion_face,
                (*_ion_elem[i])[_qp],
                ion_neighbor,
                grad_potential,
                *_face_info,
                true);

    _ion_flux += (*_sgnion[i])[_qp] * muion * -grad_potential * _r_units * std::exp(ion_face);
  }

  const auto face = makeFace(*_face_info, Moose::FV::limiterType(_advected_interp_method), false);
  ADReal u_interface = _var(face, determineState());

  return _r_units * (_sign * _ks * std::exp(u_interface) - _gamma * _ion_flux * _normal);
}
