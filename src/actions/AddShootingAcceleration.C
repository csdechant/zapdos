#include "AddShootingAcceleration.h"
#include "Parser.h"
#include "FEProblem.h"
#include "Factory.h"
#include "MooseEnum.h"
#include "AddVariableAction.h"
#include "Conversion.h"
#include "ActionFactory.h"
#include "MooseObjectAction.h"
#include "MooseApp.h"

#include "libmesh/vector_value.h"

#include "pcrecpp.h"

#include <sstream>
#include <stdexcept>

// libmesh includes
#include "libmesh/libmesh.h"
#include "libmesh/exodusII_io.h"
#include "libmesh/equation_systems.h"
#include "libmesh/nonlinear_implicit_system.h"
#include "libmesh/explicit_system.h"
#include "libmesh/string_to_enum.h"
#include "libmesh/fe.h"

registerMooseAction("ZapdosApp", AddShootingAcceleration, "add_variable");
registerMooseAction("ZapdosApp", AddShootingAcceleration, "add_aux_variable");
registerMooseAction("ZapdosApp", AddShootingAcceleration, "add_aux_kernel");
registerMooseAction("ZapdosApp", AddShootingAcceleration, "add_material");
registerMooseAction("ZapdosApp", AddShootingAcceleration, "add_kernel");
registerMooseAction("ZapdosApp", AddShootingAcceleration, "add_transfer");
registerMooseAction("ZapdosApp", AddShootingAcceleration, "add_multi_app");

InputParameters
AddShootingAcceleration::validParams()
{
  MooseEnum families(AddVariableAction::getNonlinearVariableFamilies());
  MooseEnum orders(AddVariableAction::getNonlinearVariableOrders());

  InputParameters params = ChemicalReactionsBase::validParams();
  params.addRequiredParam<std::vector<NonlinearVariableName>>(
      "accel_species",
      "Name of the species being accelerated. Currently only non-charged species.");
  params.addRequiredParam<Real>("position_units", "Units of position");
  params.addRequiredParam<std::string>(
      "reaction_coefficient_format",
      "The format of the reaction coefficient. Options: rate or townsend.");
  params.addParam<std::vector<VariableName>>(
      "potential", "The electric potential, used for energy-dependent reaction rates.");
  params.addParam<std::vector<std::string>>(
      "aux_species", "Auxiliary species that are not included in nonlinear solve.");
  params.addParam<std::vector<SubdomainName>>("block",
                                              "The subdomain that this action applies to.");
  params.addClassDescription(
      "This Action automatically adds the necessary kernels and materials for a reaction network.");

  return params;
}

AddShootingAcceleration::AddShootingAcceleration(InputParameters params)
  : ChemicalReactionsBase(params),
    _accel_species(getParam<std::vector<NonlinearVariableName>>("accel_species")),
    _coefficient_format(getParam<std::string>("reaction_coefficient_format")),
    _use_ad(getParam<bool>("use_ad"))

{
  if (_num_eedf_reactions > 0 && !isParamValid("electron_density"))
    mooseError(
        "[Reactions]: Input parameter electron_density must be set to use EEDF-type reactions.");

  if (_num_eedf_reactions > 0 && !isParamValid("electron_energy"))
    mooseError(
        "[Reactions]: Input parameter electron_energy must be set to use EEDF-type reactions.");

  if (_coefficient_format == "townsend")
  {
    //The current acceleration method only calls for reaction rates
    //TO DO: Add acceleration method that uses Townsend coefficients
    mooseError(
        "Coefficient format type 'townsend' currently is not used for acceleration methods.");
  }
  else
    _townsend_append = "";

  // Define reactant names for kernels
  // (In kernels, coupled variables are typically referred to as "v", "w", "x", etc...)
  _reactant_names.resize(2);
  _reactant_names[0] = "v";
  _reactant_names[1] = "w";

  _SM_species.resize(_accel_species.size());
  for (unsigned int cur_num = 0; cur_num < _SM_species.size(); cur_num++)
  {
    std::string accel_name = "SM_" + _accel_species[cur_num];
    _SM_species[cur_num] = accel_name;
  }

}

void
AddShootingAcceleration::act()
{
  if (_current_task == "add_variable")
  {
    // The variable type for the nonlinear variables
    auto fe_type = AddVariableAction::feType(_pars);
    auto type = AddVariableAction::variableType(fe_type);
    auto var_params = _factory.getValidParams(type);
    var_params.set<MooseEnum>("order") = "FIRST";
    var_params.set<MooseEnum>("family") = "LAGRANGE";
    var_params.set<std::vector<SubdomainName>>("block") =
        getParam<std::vector<SubdomainName>>("block");

    // The variable type for the aux variables
    auto aux_params = _factory.getValidParams(type);
    aux_params.set<MooseEnum>("order") = "FIRST";
    aux_params.set<MooseEnum>("family") = "LAGRANGE";
    aux_params.set<std::vector<SubdomainName>>("block") =
        getParam<std::vector<SubdomainName>>("block");

    // Add the ion variables and their density aux variables
    for (unsigned int cur_num = 0; cur_num < _accel_species.size(); cur_num++)
    {
      std::string accel_name = _SM_species[cur_num];
      std::string species_name = _accel_species[cur_num];

      _problem->addVariable(type, accel_name, var_params);
      _problem->addAuxVariable(type, accel_name + "Reset", aux_params);
      _problem->addAuxVariable(type, species_name + "S", aux_params);
    }
  }

  if (_current_task == "add_kernel")
  {
    std::string kernel_name;

    /*
     *
     * TIME DERIVATIVES & DIFFUSION
     *
     */
    for (unsigned int i = 0; i < _accel_species.size(); ++i)
    {
      std::string accel_SM = _SM_species[i];
      std::string accel_name = _accel_species[i];
      addTimeDiffusionKernels(accel_SM, accel_name);
    }


    for (unsigned int i = 0; i < _num_eedf_reactions; ++i)
    {
      // We need to find the non-electron species index
      int electron_index;
      int target_index;

      //This separate between electrons and non-electrons
      for (unsigned int kk = 0; kk < _reactants[_eedf_reaction_number[i]].size(); ++kk)
      {
        if (_reactants[_eedf_reaction_number[i]][kk] == getParam<std::string>("electron_density"))
          electron_index = kk;
        else
          target_index = kk;
      }

      //This needs to add the EEDFReactionLogForShootMethod kernel
      for (unsigned int j = 0; j < _species.size(); ++j)
      {
        for (unsigned int k = 0; k < _accel_species.size(); ++k)
        {
          if ((_species_count[_eedf_reaction_number[i]][j] != 0) && (_species[j] == _accel_species[k]) && (_reactants[_eedf_reaction_number[i]][target_index] == _accel_species[k]))
          {
            kernel_name = "EEDFReactionLogForShootMethod";
            addEEDFKernel(_eedf_reaction_number[i], j, kernel_name, electron_index, target_index);
          }
        }
      }
    }

    for (unsigned int i = 0; i < _num_function_reactions; ++i)
    {
      for (unsigned int j = 0; j < _species.size(); ++j)
      {

        kernel_name = getKernelName(_reactants[_function_reaction_number[i]].size());
        for (unsigned int k = 0; k < _accel_species.size(); ++k)
        {
          if ((_species_count[_function_reaction_number[i]][j] != 0) && (_species[j] == _accel_species[k]))
          {
            addNonEEDFKernel(_function_reaction_number[i], j, kernel_name);
          }
        }
      }
    }

    for (unsigned int i = 0; i < _num_constant_reactions; ++i)
    {
      for (unsigned int j = 0; j < _species.size(); ++j)
      {
        kernel_name = getKernelName(_reactants[_constant_reaction_number[i]].size());
        for (unsigned int k = 0; k < _accel_species.size(); ++k)
        {
          if ((_species_count[_constant_reaction_number[i]][j] != 0) && (_species[j] == _accel_species[k]))
          {
            addNonEEDFKernel(_constant_reaction_number[i], j, kernel_name);
          }
        }
      }
    }

  }



  if (_current_task == "add_aux_kernel")
  {
    for (unsigned int cur_num = 0; cur_num < _accel_species.size(); cur_num++)
    {
      std::string accel_name = _SM_species[cur_num];
      std::string species_name = _accel_species[cur_num];


      InputParameters params1 = _factory.getValidParams("SelfAux");
      params1.set<AuxVariableName>("variable") = species_name + "S";
      params1.set<std::vector<VariableName>>("v") = {species_name};
      params1.set<bool>("enable") = false;
      params1.set<ExecFlagEnum>("execute_on", true) = {EXEC_TIMESTEP_END};
      params1.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addAuxKernel("SelfAux", species_name + "S_for_Shooting", params1);


      InputParameters params2 = _factory.getValidParams("ConstantAux");
      params2.set<AuxVariableName>("variable") = accel_name + "Reset";
      params2.set<Real>("value") = {1.0};
      params2.set<ExecFlagEnum>("execute_on", true) = {EXEC_INITIAL};
      params2.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addAuxKernel("ConstantAux", "Constant_" + accel_name + "Reset", params2);
    }
  }



  if (_current_task == "add_multi_app")
  {
    InputParameters params = _factory.getValidParams("FullSolveMultiApp");
    params.set<std::vector<FileName>>("input_files") = {"RF_Plasma_NoActions_Shooting.i"};
    params.set<ExecFlagEnum>("execute_on", true) = {EXEC_TIMESTEP_END};
    params.set<bool>("enable") = false;
    _problem->addMultiApp("FullSolveMultiApp", "Shooting", params);
  }




  if (_current_task == "add_transfer")
  {
    for (unsigned int cur_num = 0; cur_num < _accel_species.size(); cur_num++)
    {
      std::string accel_name = _SM_species[cur_num];
      std::string species_name = _accel_species[cur_num];

      addShootingTransfer(accel_name + "Reset", accel_name + "Reset", accel_name + "Reset", true);
      addShootingTransfer(species_name, species_name, species_name, true);
      addShootingTransfer(species_name + "S", species_name + "S", species_name + "S", true);
      addShootingTransfer(species_name + "T", species_name, species_name + "T", true);
      addShootingTransfer(accel_name, accel_name, accel_name, true);

      addShootingTransfer(species_name, species_name, species_name, false);
      addShootingTransfer(accel_name + "Reset", accel_name + "Reset", accel_name, false);
    }
  }
}


void
AddShootingAcceleration::addTimeDiffusionKernels(const std::string & sm,
                                                 const std::string & species)
{
  _problem->haveADObjects(true);

  InputParameters params = _factory.getValidParams("MassLumpedTimeDerivative");
  params.set<NonlinearVariableName>("variable") = {sm};
  params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
  params.set<bool>("enable") = false;
  _problem->addKernel("MassLumpedTimeDerivative", sm + "_time_deriv", params);

  InputParameters params2 = _factory.getValidParams("CoeffDiffusionForShootMethod");
  params2.set<NonlinearVariableName>("variable") = {sm};
  params2.set<std::vector<VariableName>>("density") = {species};
  params2.set<Real>("position_units") = getParam<Real>("position_units");
  params2.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
  params2.set<bool>("enable") = false;
  _problem->addKernel("CoeffDiffusionForShootMethod", sm + "_diffusion", params2);

  InputParameters params3 = _factory.getValidParams("NullKernel");
  params3.set<NonlinearVariableName>("variable") = {sm};
  _problem->addKernel("NullKernel", sm + "_Null", params3);
}


std::string
AddShootingAcceleration::getKernelName(const unsigned & num_reactants)
{
  std::string name = "Reaction";

  if (num_reactants == 1)
    name += "FirstOrder";
  if (num_reactants == 2)
    name += "SecondOrder";
  if (num_reactants == 3)
    name += "ThirdOrder";

  return (name + _log_append + "LogForShootMethod");
}


void
AddShootingAcceleration::addEEDFKernel(const unsigned & reaction_num,
                                  const unsigned & species_num,
                                  const std::string & kernel_name,
                                  const int & electron_index,
                                  const int & target_index)
{
  auto params = _factory.getValidParams(kernel_name);
  params.set<NonlinearVariableName>("variable") = {"SM_"+_species[species_num]};
  params.set<std::vector<VariableName>>("electron") = {_reactants[reaction_num][electron_index]};
  params.set<std::vector<VariableName>>("density") = {_reactants[reaction_num][target_index]};
  params.set<std::string>("reaction") = _reaction[reaction_num];
  params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
  params.set<Real>("coefficient") = (Real)_species_count[reaction_num][species_num];
  params.set<std::string>("number") = Moose::stringify(reaction_num);
  params.set<bool>("enable") = false;
  _problem->addKernel(kernel_name,
                      "SM_kernel_eedf_" + getParam<std::vector<SubdomainName>>("block")[0] +
                          std::to_string(reaction_num) + std::to_string(species_num) + "_" +
                          _name,
                      params);
  _problem->haveADObjects(true);
}


void
AddShootingAcceleration::addNonEEDFKernel(const unsigned & reaction_num,
                                      const unsigned & species_num,
                                      const std::string & kernel_name)
{
  std::string kernel_identifier;

  InputParameters params = _factory.getValidParams(kernel_name);
  params.set<std::string>("reaction") = _reaction[reaction_num];
  params.set<std::string>("number") = Moose::stringify(reaction_num);
  params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
  params.set<bool>("enable") = false;


  // TO DO: (1) INCLUDE VARIABLES FOR JACOBIAN CONTRIBUTION OF FUNCTION RATE COEFFICIENT

  params.set<NonlinearVariableName>("variable") = {"SM_"+_species[species_num]};

  unsigned int i = 0;
  unsigned int j = 0;
  for (unsigned int k = 0; k < _reactants[reaction_num].size(); ++k)
  {
    if ((_reactants[reaction_num][k] == _species[species_num]) && (i == 0))
    {
      params.set<std::vector<VariableName>>("density") = {_reactants[reaction_num][k]};
      ++i;
    }
    else
    {
      params.set<std::vector<VariableName>>(_reactant_names[j]) = {_reactants[reaction_num][k]};
      ++j;
    }

    params.set<Real>("coefficient") = _species_count[reaction_num][species_num];
    kernel_identifier = "SM_kernel_noneedf_" + getParam<std::vector<SubdomainName>>("block")[0] +
                        std::to_string(reaction_num) + "_" + std::to_string(species_num);
  }

  _problem->addKernel(kernel_name, kernel_identifier + "_" + _name, params);
}







void
AddShootingAcceleration::addShootingTransfer(const std::string & _name,
                                          const std::string & _source_var,
                                          const std::string & _var,
                                          const bool & to_multiapp)
{
  std::string _direction;
  std::string _dir_name;

  if(to_multiapp)
  {
    _direction = "to_multi_app";
    _dir_name = "_to_Shooting";
  }
  else
  {
    _direction = "from_multi_app";
    _dir_name = "_from_Shooting";
  }

  const std::string class_name = "MultiAppCopyTransfer";
  InputParameters params = _factory.getValidParams(class_name);
  params.set<MultiAppName>(_direction) = "Shooting";
  params.set<std::vector<AuxVariableName>>("variable") = {_var};
  params.set<std::vector<VariableName>>("source_variable") = {_source_var};
  params.set<bool>("enable") = false;
  _problem->addTransfer(class_name, _name + _dir_name, params);
}
