//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "TimeStepper.h"
#include "PostprocessorInterface.h"

class PostprocessorOverPostprocessorDt;

template <>
InputParameters validParams<PostprocessorOverPostprocessorDt>();

/**
 * Computes the value of dt based on a postprocessor value
 */
class PostprocessorOverPostprocessorDt : public TimeStepper, public PostprocessorInterface
{
public:
  static InputParameters validParams();

  PostprocessorOverPostprocessorDt(const InputParameters & parameters);

protected:
  virtual Real computeInitialDT() override;
  virtual Real computeDT() override;

  const PostprocessorValue & _num_pps_value;
  const PostprocessorValue & _den_pps_value;
  bool _has_initial_dt;
  Real _initial_dt;

  /// Multiplier applied to the postprocessor value
  const Real & _scale;

  /// Factor added to the postprocessor value
  const Real & _factor;

  const Real & _upper_limit;
  const Real & _lower_limit;
  const Real & _growth_factor;
  const Real & _cutback_factor;
};
