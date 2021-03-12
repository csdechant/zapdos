//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EconomouDielectricWithEffEfieldBC.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", EconomouDielectricWithEffEfieldBC);

template <>
InputParameters
validParams<EconomouDielectricWithEffEfieldBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("dielectric_constant", "The dielectric constant of the material.");
  params.addRequiredParam<Real>("thickness", "The thickness of the material.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("mean_en", "The mean energy.");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredCoupledVar("ip", "The ion density.");

  params.addRequiredCoupledVar("Ex", "The EField in the x-direction");
  params.addCoupledVar("Ey", 0, "The EField in the y-direction"); // only required in 2D and 3D
  params.addCoupledVar("Ez", 0, "The EField in the z-direction"); // only required in 3D

  params.addParam<Real>("users_gamma",
                        "A secondary electron emission coeff. only used for this BC.");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  params.addClassDescription("Dielectric boundary condition"
                             "(Based on DOI: https://doi.org/10.1116/1.579300)");
  return params;
}

EconomouDielectricWithEffEfieldBC::EconomouDielectricWithEffEfieldBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _r_units(1. / getParam<Real>("position_units")),

    _mean_en(coupledValue("mean_en")),
    _mean_en_id(coupled("mean_en")),
    _em(coupledValue("em")),
    _em_id(coupled("em")),
    _ip(coupledValue("ip")),
    _ip_var(*getVar("ip", 0)),
    _ip_id(coupled("ip")),

    _Ex(coupledValue("Ex")),
    _Ey(coupledValue("Ey")),
    _Ez(coupledValue("Ez")),

    _Ex_id(coupled("Ex")),
    _Ey_id(coupled("Ey")),
    _Ez_id(coupled("Ez")),

    _grad_u_dot(_var.gradSlnDot()),
    _u_dot(_var.uDot()),
    _du_dot_du(_var.duDotDu()),

    _e(getMaterialProperty<Real>("e")),
    _sgnip(getMaterialProperty<Real>("sgn" + _ip_var.name())),
    _muip(getMaterialProperty<Real>("NonAD_mu" + _ip_var.name())),
    _massem(getMaterialProperty<Real>("massem")),
    _user_se_coeff(getParam<Real>("users_gamma")),

    _epsilon_d(getParam<Real>("dielectric_constant")),
    _thickness(getParam<Real>("thickness")),
    _a(0.5),
    _ion_flux(0, 0, 0),
    _v_thermal(0),
    _em_flux(0, 0, 0),
    _d_ion_flux_du(0, 0, 0),
    _d_em_flux_du(0, 0, 0),
    _d_v_thermal_d_mean_en(0),
    _d_em_flux_d_mean_en(0, 0, 0),
    _d_v_thermal_d_em(0),
    _d_em_flux_d_em(0, 0, 0),
    _d_ion_flux_d_ip(0, 0, 0),
    _d_em_flux_d_ip(0, 0, 0),
    _d_ion_flux_d_Efield(0, 0, 0),
    _d_em_flux_d_Efield(0, 0, 0),
    _potential_units(getParam<std::string>("potential_units"))

{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000;
}

Real
EconomouDielectricWithEffEfieldBC::computeQpResidual()
{
  RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

  if (_normals[_qp] * _sgnip[_qp] * EField >= 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  _ion_flux =
      (_a * _sgnip[_qp] * _muip[_qp] * EField * _r_units * std::exp(_ip[_qp]));

  _v_thermal =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));

  _em_flux =
      (0.25 * _v_thermal * std::exp(_em[_qp]) * _normals[_qp]) - (_user_se_coeff * _ion_flux);

  return _test[_i][_qp] * _r_units *
         (_e[_qp] * 6.022e23 * (_ion_flux - _em_flux) * _normals[_qp] / _voltage_scaling +
         8.8542e-12 * -_grad_u_dot[_qp] * _r_units * _normals[_qp] -
         (_epsilon_d / _thickness) * _u_dot[_qp]);
}

Real
EconomouDielectricWithEffEfieldBC::computeQpJacobian()
{

  return _test[_i][_qp] * _r_units *
         (8.8542e-12 * _du_dot_du[_qp] * -_grad_phi[_j][_qp] * _r_units * _normals[_qp] -
         (_epsilon_d / _thickness) * _du_dot_du[_qp] * _phi[_j][_qp]);
}

Real
EconomouDielectricWithEffEfieldBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _mean_en_id)
  {
    _v_thermal = std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) /
                           (M_PI * _massem[_qp]));

    _d_v_thermal_d_mean_en = 0.5 / _v_thermal * 8 * _e[_qp] * 2.0 / 3 *
                             std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp]) *
                             _phi[_j][_qp];

    _d_em_flux_d_mean_en = (0.25 * _d_v_thermal_d_mean_en * std::exp(_em[_qp]) * _normals[_qp]);

    return _test[_i][_qp] * _r_units *
           (-_e[_qp] * 6.022e23 * _d_em_flux_d_mean_en) * _normals[_qp] / _voltage_scaling;
  }

  else if (jvar == _em_id)
  {
    _v_thermal = std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) /
                           (M_PI * _massem[_qp]));

    _d_v_thermal_d_em = 0.5 / _v_thermal * 8 * _e[_qp] * 2.0 / 3 *
                        std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp]) * -_phi[_j][_qp];

    _d_em_flux_d_em = (0.25 * _d_v_thermal_d_em * std::exp(_em[_qp]) +
                       0.25 * _v_thermal * std::exp(_em[_qp]) * _phi[_j][_qp]) * _normals[_qp];

    return _test[_i][_qp] * _r_units * (-_e[_qp] * 6.022e23 * _d_em_flux_d_em) *
           _normals[_qp] / _voltage_scaling;
  }

  else if (jvar == _ip_id)
  {
    RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);

    if (_normals[_qp] * _sgnip[_qp] * EField >= 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    _d_ion_flux_d_ip = (_a * _sgnip[_qp] * _muip[_qp] * EField * _r_units *
                        std::exp(_ip[_qp]) * _phi[_j][_qp]);

    _d_em_flux_d_ip = -_user_se_coeff * _d_ion_flux_d_ip;

    return _test[_i][_qp] * _r_units *
           _e[_qp] * 6.022e23 * (_d_ion_flux_d_ip - _d_em_flux_d_ip) * _normals[_qp] /
           _voltage_scaling;
  }

  else if (jvar == _Ex_id || jvar == _Ey_id || jvar == _Ez_id)
  {
    RealVectorValue EField(_Ex[_qp], _Ey[_qp], _Ez[_qp]);
    RealVectorValue d_EField_d_comp(0, 0, 0);

    //_d_ion_flux_d_Efield.zero();
    //_d_em_flux_d_Efield.zero();

    int comp = 4;
    if (jvar == _Ex_id)
      comp = 0;
    if (jvar == _Ey_id)
      comp = 1;
    if (jvar == _Ez_id)
      comp = 2;

    if (_normals[_qp] * _sgnip[_qp] * EField >= 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    d_EField_d_comp(comp) = _phi[_j][_qp];

    _d_ion_flux_d_Efield =
        (_a * _sgnip[_qp] * _muip[_qp] * d_EField_d_comp * _r_units * std::exp(_ip[_qp]));

    _d_em_flux_d_Efield = -_user_se_coeff * _d_ion_flux_d_Efield;

    return _test[_i][_qp] * _r_units *
           _e[_qp] * 6.022e23 * (_d_ion_flux_d_Efield - _d_em_flux_d_Efield) *
           _normals[_qp] / _voltage_scaling;
  }

  else
    return 0.0;
}
