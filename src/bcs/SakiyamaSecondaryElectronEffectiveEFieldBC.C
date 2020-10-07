//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SakiyamaSecondaryElectronEffectiveEFieldBC.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", SakiyamaSecondaryElectronEffectiveEFieldBC);

template <>
InputParameters
validParams<SakiyamaSecondaryElectronEffectiveEFieldBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredCoupledVar("Ex", "The EField in the x-direction");
  params.addCoupledVar("Ey", 0, "The EField in the y-direction"); // only required in 2D and 3D
  params.addCoupledVar("Ez", 0, "The EField in the z-direction"); // only required in 3D
  params.addRequiredCoupledVar("ip", "The ion density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addParam<Real>("users_gamma",
                        "A secondary electron emission coeff. only used for this BC.");
  params.addClassDescription("Kinetic secondary electron boundary condition"
                             "(Based on DOI: https://doi.org/10.1116/1.579300)");
  return params;
}

SakiyamaSecondaryElectronEffectiveEFieldBC::SakiyamaSecondaryElectronEffectiveEFieldBC(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    // Coupled Variables
    _Ex(coupledValue("Ex")),
    _Ey(coupledValue("Ey")),
    _Ez(coupledValue("Ez")),

    _Ex_id(coupled("Ex")),
    _Ey_id(coupled("Ey")),
    _Ez_id(coupled("Ez")),

    _a(0.5),
    _ion_flux(0, 0, 0),
    _d_ion_flux_d_EField(0, 0, 0),
    _d_ion_flux_d_ip(0, 0, 0),
    _actual_mean_en(0),
    _user_se_coeff(getParam<Real>("users_gamma"))
{
  _num_ions = coupledComponents("ip");

  _ip.resize(_num_ions);
  _ip_var.resize(_num_ions);
  _muip.resize(_num_ions);
  _sgnip.resize(_num_ions);
  _ion_id.resize(_num_ions);

  for (unsigned int i = 0; i < _num_ions; ++i)
  {
    _ip_var[i] = getVar("ip", i);
    _ip[i] = &coupledValue("ip", i);
    _muip[i] = &getMaterialProperty<Real>("mu" + (*getVar("ip", i)).name());
    _ion_id[i] = _ip_var[i]->number();
    _sgnip[i] = &getMaterialProperty<Real>("sgn" + (*getVar("ip", i)).name());
  }
}

Real
SakiyamaSecondaryElectronEffectiveEFieldBC::computeQpResidual()
{
  RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

  _ion_flux.zero();
  for (unsigned int i = 0; i < _num_ions; ++i)
  {
    if (_normals[_qp] * (*_sgnip[i])[_qp] * EField > 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    _ion_flux += _a * (*_sgnip[i])[_qp] * (*_muip[i])[_qp] * EField *
                 std::exp((*_ip[i])[_qp]);
  }

  return -_test[_i][_qp] * _r_units * _a * _user_se_coeff * _ion_flux * _normals[_qp];
}

Real
SakiyamaSecondaryElectronEffectiveEFieldBC::computeQpJacobian()
{
  return 0.;
}

Real
SakiyamaSecondaryElectronEffectiveEFieldBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  _iter = std::find(_ion_id.begin(), _ion_id.end(), jvar);
  if (jvar == _Ex_id || jvar == _Ey_id || jvar == _Ez_id)
  {
    RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);
    RealVectorValue d_EField_d_comp(0, 0, 0);

    int comp = 4;
    if (jvar == _Ex_id)
      comp = 0;
    if (jvar == _Ey_id)
      comp = 1;
    if (jvar == _Ez_id)
      comp = 2;

    d_EField_d_comp(comp) = _phi[_j][_qp];


    _ion_flux.zero();
    for (unsigned int i = 0; i < _num_ions; ++i)
    {
      if (_normals[_qp] * (*_sgnip[i])[_qp] * EField > 0.0)
      {
        _a = 1.0;
      }
      else
      {
        _a = 0.0;
      }

      _d_ion_flux_d_EField = _a * (*_sgnip[i])[_qp] * (*_muip[i])[_qp] * d_EField_d_comp *
                                   std::exp((*_ip[i])[_qp]);
    }

    return -_test[_i][_qp] * _r_units * _user_se_coeff * _d_ion_flux_d_EField * _normals[_qp];
  }

  else if (_iter != _ion_id.end())
  {
    RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

    _ip_index = std::distance(_ion_id.begin(), _iter);
    if (_normals[_qp] * (*_sgnip[_ip_index])[_qp] * EField > 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    _d_ion_flux_d_ip = _a * (*_sgnip[_ip_index])[_qp] * (*_muip[_ip_index])[_qp] *
                       EField * std::exp((*_ip[_ip_index])[_qp]) *
                       _phi[_j][_qp];

    return -_test[_i][_qp] * _r_units * _user_se_coeff * _d_ion_flux_d_ip * _normals[_qp];
  }

  else
    return 0.0;
}
