//* This file is part of CRANE, an open-source
//* application for the simulation of plasmas
//* https://github.com/lcpp-org/crane
//*
//* CRANE is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EEDFElasticLogTempDepend.h"

registerMooseObject("CraneApp", EEDFElasticLogTempDepend);

template <>
InputParameters
validParams<EEDFElasticLogTempDepend>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("electrons", "The electron density.");
  params.addRequiredCoupledVar("target", "The target species variable.");
  params.addRequiredParam<std::string>("reaction",
                                       "Stores the name of the reaction (townsend) coefficient, "
                                       "unique to each individual reaction.");
  params.addParam<std::string>(
      "number",
      "",
      "The reaction number. Optional, just for material property naming purposes. If a single "
      "reaction has multiple different rate coefficients (frequently the case when multiple "
      "species are lumped together to simplify a reaction network), this will prevent the same "
      "material property from being declared multiple times.");
  return params;
}

EEDFElasticLogTempDepend::EEDFElasticLogTempDepend(const InputParameters & parameters)
  : Kernel(parameters),
    _reaction_coeff(getMaterialProperty<Real>("k" + getParam<std::string>("number") + "_" +
                                              getParam<std::string>("reaction"))),
    _massTarget(getMaterialProperty<Real>("mass" + (*getVar("target", 0)).name())),
    _d_k_d_actual_mean_en(getMaterialProperty<Real>("d_k" + getParam<std::string>("number") +
                                                    "_d_en_" + getParam<std::string>("reaction"))),
    _em(coupledValue("electrons")),
    _em_id(coupled("electrons")),
    _target(coupledValue("target")),
    _target_id(coupled("target")),

    _e(getMaterialProperty<Real>("e")),
    _kb(getMaterialProperty<Real>("k_boltz")),
    _T_Target(getMaterialProperty<Real>("T" + (*getVar("target", 0)).name()))
{
  _massem = 9.11e-31;
}

EEDFElasticLogTempDepend::~EEDFElasticLogTempDepend() {}

Real
EEDFElasticLogTempDepend::computeQpResidual()
{
  Real Eel = -3.0 * _massem / _massTarget[_qp] *
               ((2.0 / 3. * std::exp(_u[_qp] - _em[_qp])) - (_kb[_qp] / _e[_qp] * _T_Target[_qp]));

  return -_test[_i][_qp] * _reaction_coeff[_qp] * std::exp(_em[_qp] + _target[_qp]) * Eel;
}

Real
EEDFElasticLogTempDepend::computeQpJacobian()
{
  Real d_actual_mean_en_d_mean_en = std::exp(_u[_qp] - _em[_qp]) * _phi[_j][_qp];
  Real d_k_d_mean_en = _d_k_d_actual_mean_en[_qp] * d_actual_mean_en_d_mean_en;

  Real Eel = -3.0 * _massem / _massTarget[_qp] *
               ((2.0 / 3. * std::exp(_u[_qp] - _em[_qp])) - (_kb[_qp] / _e[_qp] * _T_Target[_qp]));
  Real d_Eel_d_mean_en =
      -3.0 * _massem / _massTarget[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) * _phi[_j][_qp];

  return -_test[_i][_qp] * std::exp(_em[_qp] + _target[_qp]) *
         (d_k_d_mean_en * Eel + _reaction_coeff[_qp] * d_Eel_d_mean_en);
}

Real
EEDFElasticLogTempDepend::computeQpOffDiagJacobian(unsigned int jvar)
{
  Real d_actual_mean_en_d_em = -std::exp(_u[_qp] - _em[_qp]) * _phi[_j][_qp];
  Real d_k_d_em = _d_k_d_actual_mean_en[_qp] * d_actual_mean_en_d_em;

  Real Eel = -3.0 * _massem / _massTarget[_qp] *
               ((2.0 / 3. * std::exp(_u[_qp] - _em[_qp])) - (_kb[_qp] / _e[_qp] * _T_Target[_qp]));
  Real d_Eel_d_em =
      -3.0 * _massem / _massTarget[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) * -_phi[_j][_qp];

  if (jvar == _em_id)
    return -_test[_i][_qp] *
           (d_k_d_em * std::exp(_em[_qp] + _target[_qp]) * Eel +
            _reaction_coeff[_qp] * std::exp(_em[_qp] + _target[_qp]) * _phi[_j][_qp] * Eel +
            _reaction_coeff[_qp] * std::exp(_em[_qp] + _target[_qp]) * d_Eel_d_em);
  else if (jvar == _target_id)
    return -_test[_i][_qp] * _reaction_coeff[_qp] * Eel * std::exp(_em[_qp] + _target[_qp]) *
           _phi[_j][_qp];
  else
    return 0.0;
}
