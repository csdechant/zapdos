//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "AddVariableAction.h"
#include "Action.h"

/**
 * This class allows us to have a section of the input file like the
 * following which automatically adds variables, kernels, aux kernels, bcs
 * for setting up the Drift-Diffusion equation for multiple plasma species
 * and automatically adds the Poisson's equation for electrostatic cases.
 *
 * [DriftDiffusionAction]
 *   [Plasma]
 *   []
 * []
 */
class AddDriftDiffusionAction : public Action
{
public:
  AddDriftDiffusionAction(const InputParameters & params);

  static InputParameters validParams();

  virtual void act();

protected:
  /// Helper function that 
  virtual void addChargeSourceKernels(const std::string & field_name,
                                      const std::string & charged_particle_name,
                                      const MooseEnum & field_solver);

  /// Helper function that 
  virtual void addADKernels(const std::string & name,
                            const std::string & field_name,
                            const bool & Using_offset,
                            const bool & charged,
                            const bool & energy);

  /// Helper function that 
  virtual void addPosition(const std::string & position_name, const int & component);

  /// Helper function that 
  virtual void addDensityLog(const std::string & particle_name);

  /// Helper function that 
  virtual void addCurrent(const std::string & particle_name,
                          const std::string & field_property_name);

  /// Helper function that 
  virtual void addEfield(const std::string & Efield_name,
                         const std::string & field_property_name,
                         const int & component);

  /// Helper function that 
  virtual void addFieldSolverMaterial(const std::string & field_name,
                                      const std::string & field_property_name,
                                      const MooseEnum & field_solver,
                                      const bool & effective_field);
};
