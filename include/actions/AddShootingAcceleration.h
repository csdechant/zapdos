#pragma once

#include "AddVariableAction.h"
#include "Action.h"
#include "ChemicalReactionsBase.h"

class AddShootingAcceleration : public ChemicalReactionsBase
{
public:
  AddShootingAcceleration(InputParameters params);

  static InputParameters validParams();

  virtual void act();

protected:
  // virtual void addEnergyKernel();
  /*
  virtual void addEEDFKernel(const unsigned & reaction_num,
                             const unsigned & species_num,
                             const std::string & kernel_name);
                             */
  //virtual void addEEDFCoefficient(const unsigned & reaction_num);
  virtual void addTimeDiffusionKernels(const std::string & sm,
                                       const std::string & species);

  virtual void addEEDFKernel(const unsigned & reaction_num,
                             const unsigned & species_num,
                             const std::string & kernel_name,
                             const int & electron_index,
                             const int & target_index);
  //virtual void addEEDFEnergy(const unsigned & reaction_num, const std::string & kernel_name);
  //virtual void addConstantRateCoefficient(const unsigned & reaction_num);
  //virtual void addFunctionRateCoefficient(const unsigned & reaction_num);
  //virtual void addSuperelasticRateCoefficient(const unsigned & reaction_num);
  virtual void addNonEEDFKernel(const unsigned & reaction_num,
                                 const unsigned & species_num,
                                 const std::string & kernel_name);
  virtual std::string
  getKernelName(const unsigned & num_reactants);

  virtual void addShootingTransfer(const std::string & _name,
                                   const std::string & _source_var,
                                   const std::string & _var,
                                   const bool & to_multiapp);
  //virtual std::string getElectronImpactKernelName(const bool & energy_kernel,
  //                                                const bool & elastic_kernel,
  //                                                const bool & is_aux);

  //virtual void addAuxRate(const std::string & aux_kernel_name,
  //                        const unsigned & reaction_num,
  //                        const bool & is_townsend);

  // virtual void add

  const std::vector<NonlinearVariableName> _accel_species;
  std::string _coefficient_format;
  bool _use_ad;

  std::string _ad_prepend;
  std::string _townsend_append;
  std::string _log_append;
  std::vector<std::string> _reactant_names;
  std::vector<std::string> _SM_species;
};
