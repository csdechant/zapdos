//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PostprocessorOverPostprocessorDt.h"

registerMooseObject("MooseApp", PostprocessorOverPostprocessorDt);

defineLegacyParams(PostprocessorOverPostprocessorDt);

InputParameters
PostprocessorOverPostprocessorDt::validParams()
{
  InputParameters params = TimeStepper::validParams();
  params.addRequiredParam<PostprocessorName>("postprocessor_numerator",
                                             "The name of the postprocessor for the numerator");
  params.addRequiredParam<PostprocessorName>("postprocessor_denominator",
                                             "The name of the postprocessor for the denominator");
  params.addParam<Real>("dt", "Initial value of dt");
  params.addParam<Real>("scale", 1, "Multiple scale and supplied postprocessor value.");
  params.addParam<Real>("factor", 0, "Add a factor to the supplied postprocessor value.");
  params.addRequiredParam<Real>("upper_limit", "The upper limit to compare to the postprocessor fraction.");
  params.addRequiredParam<Real>("lower_limit", "The lower limit to compare to the postprocessor fraction.");
  params.addRequiredParam<Real>("growth_factor", "Factor to apply to timestep if below lower limit.");
  params.addRequiredParam<Real>("cutback_factor", "Factor to apply to timestep if above upper limit.");
  return params;
}

PostprocessorOverPostprocessorDt::PostprocessorOverPostprocessorDt(const InputParameters & parameters)
  : TimeStepper(parameters),
    PostprocessorInterface(this),
    _num_pps_value(getPostprocessorValue("postprocessor_numerator")),
    _den_pps_value(getPostprocessorValue("postprocessor_denominator")),
    _has_initial_dt(isParamValid("dt")),
    _initial_dt(_has_initial_dt ? getParam<Real>("dt") : 0.),
    _scale(getParam<Real>("scale")),
    _factor(getParam<Real>("factor")),
    _upper_limit(getParam<Real>("upper_limit")),
    _lower_limit(getParam<Real>("lower_limit")),
    _growth_factor(getParam<Real>("growth_factor")),
    _cutback_factor(getParam<Real>("cutback_factor"))
{
}

Real
PostprocessorOverPostprocessorDt::computeInitialDT()
{
  if (_has_initial_dt)
    return _initial_dt;
  else
    return computeDT();
}

Real
PostprocessorOverPostprocessorDt::computeDT()
{

  Real _current_factor = _scale * (_num_pps_value/_den_pps_value) + _factor;

  if (_current_factor > _upper_limit)
  {
    return _dt * _cutback_factor;
  }
  if (_current_factor < _lower_limit)
  {
    return _dt * _growth_factor;
  }
  else{
    return _dt;
  }
}
