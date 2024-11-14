//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVSakiyamaEnergySecondaryElectronBCNonLog.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVSakiyamaEnergySecondaryElectronBCNonLog);

InputParameters
FVSakiyamaEnergySecondaryElectronBCNonLog::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredParam<Real>("se_coeff", "The secondary electron coefficient");
  params.addRequiredParam<bool>(
      "Tse_equal_Te", "The secondary electron temperature equal the electron temperature in eV");
  params.addParam<Real>(
      "user_se_energy", 1.0, "The user's value of the secondary electron temperature in eV");
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredCoupledVar("ip", "The ion density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription(
      "Kinetic secondary electron for mean electron energy boundary condition"
      "(Based on DOI: https://doi.org/10.1116/1.579300)");

  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVSakiyamaEnergySecondaryElectronBCNonLog::FVSakiyamaEnergySecondaryElectronBCNonLog(
    const InputParameters & parameters)
  : FVFluxBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    Te_dependent(getParam<bool>("Tse_equal_Te")),

    _em(adCoupledValue("em")),
    _em_neighbor(adCoupledNeighborValue("em")),

    _se_coeff(getParam<Real>("se_coeff")),
    _user_se_energy(getParam<Real>("user_se_energy")),
    _a(0.5),
    _se_energy(0)
{

  _num_ions = coupledComponents("ip");

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
    _ion_elem[i] = &adCoupledValue("ip", i);
    _ion_neighbor[i] = &adCoupledNeighborValue("ip", i);
    _muion_elem[i] = &getADMaterialProperty<Real>("mu" + (*getFieldVar("ip", i)).name());
    _muion_neighbor[i] =
        &getNeighborADMaterialProperty<Real>("mu" + (*getFieldVar("ip", i)).name());
    _sgnion[i] = &getMaterialProperty<Real>("sgn" + (*getFieldVar("ip", i)).name());
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
FVSakiyamaEnergySecondaryElectronBCNonLog::computeQpResidual()
{
  using namespace Moose::FV;
  const auto state = determineState();

  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info, state);

  _ion_flux.zero();
  for (unsigned int i = 0; i < _num_ions; ++i)
  {
    ADReal muion;
    interpolate(InterpMethod::Average,
                muion,
                (*_muion_elem[i])[_qp],
                (*_muion_neighbor[i])[_qp],
                *_face_info,
                true);

    ADReal ion_face;
    interpolate(_advected_interp_method,
                ion_face,
                (*_ion_elem[i])[_qp],
                (*_ion_neighbor[i])[_qp],
                grad_potential,
                *_face_info,
                true);

    if (_normal * (*_sgnion[i])[_qp] * -grad_potential > 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    _ion_flux += _a * (*_sgnion[i])[_qp] * muion * -grad_potential * _r_units * ion_face;
  }

  if (Te_dependent)
  {
    ADReal energy_interface;

    interpolate(InterpMethod::Average,
                energy_interface,
                (_u[_qp] / _em[_qp]),
                (_u_neighbor[_qp] / _em_neighbor[_qp]),
                *_face_info,
                true);

    _se_energy = energy_interface;
  }
  else
  {
    _se_energy = _user_se_energy;
  }

  return -1.0 * _r_units * _se_coeff * (5.0 / 3.0) * _se_energy * _ion_flux * _normal;
}
