#include "AddLotsOfTwoBodyReactions.h"
#include "Parser.h"
#include "FEProblem.h"
#include "Factory.h"
#include "MooseEnum.h"
#include "AddVariableAction.h"
#include "Conversion.h"
#include "DirichletBC.h"
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

registerMooseAction("ZapdosApp", AddLotsOfTwoBodyReactions, "add_material");
// registerMooseAction("ZapdosApp", AddLotsOfTwoBodyReactions, "add_variable");
registerMooseAction("ZapdosApp", AddLotsOfTwoBodyReactions, "add_kernel");
registerMooseAction("ZapdosApp", AddLotsOfTwoBodyReactions, "add_bc");

template <>
InputParameters
validParams<AddLotsOfTwoBodyReactions>()
{
  MooseEnum families(AddVariableAction::getNonlinearVariableFamilies());
  MooseEnum orders(AddVariableAction::getNonlinearVariableOrders());

  InputParameters params = validParams<AddVariableAction>();
  params.addRequiredParam<std::vector<NonlinearVariableName>>(
    "species", "List of (tracked) species included in reactions (both products and reactants)");
  params.addParam<std::vector<NonlinearVariableName>>(
    "species_energy", "List of (tracked) energy values. (Optional)");
  params.addRequiredParam<std::string>("electron_density", "The variable used for density of electrons.");
  params.addRequiredParam<std::vector<VariableName>>(
    "electron_energy", "Electron energy, used for energy-dependent reaction rates.");
  params.addRequiredParam<std::vector<std::string>>("gas_species", "All of the background gas species in the system.");
  params.addRequiredParam<bool>("gas_tracking", "If false, neutral gas is treated as uniform background (_n_gas).");
  params.addParam<std::vector<VariableName>>("potential", "The electric potential, used for energy-dependent reaction rates.");
  params.addRequiredParam<std::string>("reactions", "The list of reactions to be added");
  params.addRequiredParam<Real>("position_units", "The units of position.");
  params.addRequiredParam<std::string>("reaction_coefficient_format",
    "The format of the reaction coefficient. Options: rate or townsend.");
  params.addRequiredParam<FileName>("file_location", "The location of the reaction rate files.");
  params.addRequiredParam<bool>("use_moles", "Whether to use molar units or # units.");
  params.addClassDescription("This Action adds the necessary coupled materials and kernels for chemical reactions.");

  return params;
}

AddLotsOfTwoBodyReactions::AddLotsOfTwoBodyReactions(InputParameters params)
  : Action(params),
    _species(getParam<std::vector<NonlinearVariableName>>("species")),
    _species_energy(getParam<std::vector<NonlinearVariableName>>("species_energy")),
    _input_reactions(getParam<std::string>("reactions")),
    _r_units(getParam<Real>("position_units")),
    _coefficient_format(getParam<std::string>("reaction_coefficient_format"))
{
  // 1) split into reactants and products
  // 2) split products into products and reaction rate
  // 3) check reaction rate; if constant, store. If "BOLOS", read data file.
  // 4) split reactants and products into individual species
  // 5) Apply appropriate kernels and/or materials. (In the act() function.)
  std::string electron_density = getParam<std::string>("electron_density");
  std::istringstream iss(_input_reactions);
  std::string token;
  std::string token2;
  std::vector<std::string> rate_coefficient_string;
  std::vector<std::string> threshold_energy_string;

  size_t pos;
  size_t pos_start;
  size_t pos_end;
  int counter;
  counter = 0;
  while (std::getline(iss >> std::ws, token)) // splits by \n character (default) and ignores leading whitespace
  {
    // Define check for change of energy
    bool energy_change = true;
    pos = token.find(':'); // Looks for comma, which separates reaction and rate coefficients
    pos_start = token.find('[');
    pos_end = token.find(']');
    _reaction.push_back(token.substr(0, pos)); // Stores reactions
    rate_coefficient_string.push_back(token.substr(pos + 2, pos_start-pos-3)); // Stores rates (as strings still, at this point)
    // The above works, but it needs to automatically account for whitespaces (pos + 2).
    // Too dependent on user input formatting...
    // (Maybe I can split it by whitespace, like I do later?)
    if (pos_start != std::string::npos)
    {
      threshold_energy_string.push_back(token.substr(pos_start + 1, pos_end-pos_start-1));
      energy_change = true;
    }
    else
    {
      threshold_energy_string.push_back("\0");
    }
  }

  _num_reactions = _reaction.size();
  _rate_coefficient.resize(_num_reactions, 0);
  _threshold_energy.resize(_num_reactions, 0);

  // adds a NAN value for any rate coefficient that is being pulled from BOLOS.
  // In the act() function, a NAN check will be used to determine if a reaction
  // needs to pull data from a table.
  // (This will be done within a material, I think.) -- S. Keniley, May 7 2018
  _electron_reaction.resize(_num_reactions);
  _elastic_collision.resize(_num_reactions, false);
  std::size_t found;
  for (unsigned int i = 0; i < _num_reactions; ++i)
  {
    // Cut out trailing whitespace from reaction, rate coefficient, etc.
    found = _reaction[i].find_last_not_of(" \t");
    _reaction[i].erase(found + 1);

    found = rate_coefficient_string[i].find_last_not_of(" \t");
    rate_coefficient_string[i].erase(found + 1);

    if (threshold_energy_string[i] == "\0")
    {
      _threshold_energy[i] = 0.0;
    }
    else if (threshold_energy_string[i] == "elastic")
    {
      _threshold_energy[i] = 0.0;
      _elastic_collision[i] = true;
    }
    else
    {
      _threshold_energy[i] = stof(threshold_energy_string[i]);
    }

    if (rate_coefficient_string[i] == std::string("BOLOS"))
    {
      _rate_coefficient[i] = NAN;
    }
    else
    {
      // If not BOLOS, it must be some sort of expression. Here we will convert
      // this expression into a usable equation.
      // Algorithm:
      // (a) split expression by delimeter (* and ^)
      //    (a.1) If *, multiply; if ^, exp() (not sure how to do this)
      // (b) search for variables: Tgas or Te (only two options)
      // (c) Everything else must be a float! Use stof()
      // USE SHUNTING-YARD ALGORITHM
      try
      {
        _rate_coefficient[i] = stof(rate_coefficient_string[i]);
        std::cout << rate_coefficient_string[i] << std::endl;
        std::cout << _rate_coefficient[i] << "\n" << std::endl;
      }
      catch (int e)
      {
        std::cout << "Error Nr. " << e << std::endl;
      }
    }
  }
  _reaction_coefficient_name.resize(_num_reactions);
  _reactants.resize(_num_reactions);
  _products.resize(_num_reactions);
  _species_count.resize(_num_reactions, std::vector<Real>(_species.size()));
  _electron_index.resize(_num_reactions, 0);
  // _species_electron.resize(_num_reactions, std::vector<bool>(_species.size()));

  // Split each reaction equation into reactants and products
  for (unsigned int i = 0; i < _num_reactions; ++i)
  {
    std::istringstream iss2(_reaction[i]);
    std::string token;

    // Isolate individual terms of each reaction
    unsigned int counter = 0;
    bool react_check = true;
    while (std::getline(iss2 >> std::ws, token, ' '))
    {
      // Check for non-variable entries. Skip the plus signs, and if an equals
      // sign shows up we switch from reactants to products.
      // (This is a pretty hacky way to do this...but it works.)
      if (token == "+")
      {
        // If "+", skip to next iteration
        continue;
      }
      else if (token == "=" || token == "->" || token == "=>")
      {
        // If "=", switch from reactants to products, reset counter, and then
        // skip to next iteration.
        react_check = false;
        counter = 0;
        continue;
      }
      else if (token == "<=>" || token == "<->")
      {
        mooseError("Cannot handle reverse reactions yet. Add two separate reactions.");
      }

      // Check if we are on the left side (reactants) or right side (products)
      // of the reaction equation.
      if (react_check)
      {
        _reactants[i].push_back(token);
      }
      else
      {
        _products[i].push_back(token);
      }
      counter = counter + 1;
    }
    // Record the number of reactants and products.
    // Eventually, _num_reactants will be used to determine if a reaction is
    // two- or three-body. For now we will assume two-body for simplicity.
    _num_reactants.push_back(_reactants[i].size());
    _num_products.push_back(_products[i].size());

    _electron_reaction[i] = false;
    for (unsigned int j = 0; j < _species.size(); ++j)
    {
      for (unsigned int k = 0; k < _reactants[i].size(); ++k)
      {
        if (_reactants[i][k] == _species[j])
        {
          _species_count[i][j] -= 1;
        }
        if (_reactants[i][k] == electron_density)
        {
          _electron_reaction[i] = true;
          _electron_index[i] = k;
        }
      }
      for (unsigned int k = 0; k < _products[i].size(); ++k)
      {
        if (_products[i][k] == _species[j])
        {
          _species_count[i][j] += 1;
        }
      }
    }
  }
}

void
AddLotsOfTwoBodyReactions::act()
{

  int v_index;
  // bool find_current;
  bool find_other;
  bool species_v, species_w;
  unsigned int target; // stores index of target species for electron-impact reactions
  // std::string electron_density = getParam<std::string>("electron_density");
  std::string product_kernel_name;
  std::string reactant_kernel_name;
  std::string energy_kernel_name;
  std::vector<NonlinearVariableName> variables =
      getParam<std::vector<NonlinearVariableName>>("species");
  std::vector<VariableName> electron_energy =
      getParam<std::vector<VariableName>>("electron_energy");
  std::string electron_density = getParam<std::string>("electron_density");
  // if (_coefficient_format == "townsend")
    // std::vector<VariableName> potential = getParam<std::vector<VariableName>>("potential");

  bool gas_tracking = getParam<bool>("gas_tracking");
  std::vector<std::string> gas_species = getParam<std::vector<std::string>>("gas_species");

  if (gas_tracking)
  {
    mooseError("Functionality for tracking neutral gas densities and temperatures is not yet implemented.");
  }

  if (_current_task == "add_material")
  {
    for (unsigned int i = 0; i < _num_reactions; ++i)
    {
      _reaction_coefficient_name[i] = "alpha_"+_reaction[i];
      if (isnan(_rate_coefficient[i]))
      {
        Real position_units = getParam<Real>("position_units");
        InputParameters params = _factory.getValidParams("GenericEnergyDependentReactionRate");
        params.set<std::string>("reaction") = _reaction[i];
        params.set<FileName>("file_location") = getParam<FileName>("file_location");
        params.set<Real>("position_units") = position_units;
        if (_coefficient_format == "townsend")
          params.set<std::vector<VariableName>>("potential") = getParam<std::vector<VariableName>>("potential");
        params.set<std::vector<VariableName>>("em") = {_reactants[i][_electron_index[i]]};
        params.set<std::vector<VariableName>>("mean_en") = electron_energy;
        params.set<std::string>("reaction_coefficient_format") = _coefficient_format;

        // This section determines if the target species is a tracked variable.
        // If it isn't, the target is assumed to be the background gas (_n_gas).
        // (This cannot handle gas mixtures yet -- base code needs to be modified to
        // distinguish between different gas densities for that to work.)
        bool target_species_tracked = false;
        for (unsigned int j = 0; j < _species.size(); ++j)
        {
          // Checking for the target species in electron-impact reactions, so
          // electrons are ignored.
          if (_species[j] == "em")
          {
            continue;
          }

          for (unsigned int k = 0; k < _reactants[i].size(); ++k)
          {
            if (_reactants[i][k] == _species[j])
            {
              target_species_tracked = true;
              target = k;
              break;
            }
          }

          if (target_species_tracked)
            break;
        }
        if (target_species_tracked)
        {
          params.set<std::vector<VariableName>>("target_species") = {_reactants[i][target]};
        }
        params.set<bool>("elastic_collision") = {_elastic_collision[i]};
        params.set<std::string>("property_file") = "reaction_"+_reaction[i]+".txt";

        _problem->addMaterial("GenericEnergyDependentReactionRate", "reaction_"+std::to_string(i), params);
      }
      else
      {
        InputParameters params = _factory.getValidParams("GenericReactionRate");
        params.set<std::string>("reaction") = _reaction[i];
        params.set<Real>("reaction_rate_value") = _rate_coefficient[i];
        _problem->addMaterial("GenericReactionRate", "reaction_"+std::to_string(i), params);
      }

    }
  }

  // Add appropriate kernels to each reactant and product.
  if (_current_task == "add_kernel")
  {
    int index; // stores index of species in the reactant/product arrays
    std::vector<std::string>::iterator iter;
    for (unsigned int i = 0; i < _num_reactions; ++i)
    {
      // if (_electron_reaction[i] == false)
      if (!isnan(_rate_coefficient[i]))
      {
        product_kernel_name = "ProductABRxn";
        reactant_kernel_name = "ReactantABRxn2";
        // if (_num_reactants[i] == 1)
        // {
          // product_kernel_name = "ProductABRxn";
          // reactant_kernel_name = "ReactantABRxn2";
        // }
        // else if (_num_reactants[i] == 2)
        // {
          // product_kernel_name = "ProductABRxn";
          // reactant_kernel_name = "ReactantABRxn2";
        // }
        if (_num_reactants[i] > 2)
        {
          mooseError("LotsOfTwoBodyReactions cannot handle "+std::to_string(_num_reactants[i])+"-body reactions! \nReaction: "+_reaction[i]);
        }
      }
      else
      {
        if (_coefficient_format == "townsend")
        {
          product_kernel_name = "ElectronImpactReactionProduct";
          reactant_kernel_name = "ElectronImpactReactionReactant";
          energy_kernel_name = "ElectronEnergyTerm";

          // Add energy equation source/sink term(s)
          InputParameters params = _factory.getValidParams(energy_kernel_name);
          params.set<NonlinearVariableName>("variable") = _species_energy[0];
          if (_coefficient_format == "townsend")
            params.set<std::vector<VariableName>>("potential") = getParam<std::vector<VariableName>>("potential");
          params.set<std::vector<VariableName>>("em") = {electron_density};
          params.set<std::string>("reaction") = _reaction[i];
          params.set<Real>("threshold_energy") = _threshold_energy[i];
          params.set<Real>("position_units") = _r_units;
          _problem->addKernel(energy_kernel_name, "energy_kernel"+std::to_string(i)+"_"+_reaction[i], params);
        }
        else
        {
          iter = std::find(_reactants[i].begin(), _reactants[i].end(), electron_density);
          index = std::distance(_reactants[i].begin(), iter);
          v_index = std::abs(index - 1);
          find_other = std::find(_species.begin(), _species.end(), _reactants[i][v_index]) != _species.end();


          product_kernel_name = "ProductABRxn";
          reactant_kernel_name = "ReactantABRxn2";
          energy_kernel_name = "ElectronEnergyTermRate";

          InputParameters params = _factory.getValidParams(energy_kernel_name);
          params.set<NonlinearVariableName>("variable") = _species_energy[0];
          params.set<std::vector<VariableName>>("em") = {electron_density};
          if (find_other)
            params.set<std::vector<VariableName>>("v") = {_reactants[i][v_index]};
          params.set<std::string>("reaction") = _reaction[i];
          params.set<Real>("threshold_energy") = _threshold_energy[i];
          params.set<Real>("position_units") = _r_units;
          _problem->addKernel(energy_kernel_name, "energy_kernel"+std::to_string(i)+"_"+_reaction[i], params);
        }
      }

      // USE SPECIES.
      // ADD ARRAY (VECTOR?) THAT STORES THE INDEX OF THE OTHER SPECIES, IF IT EXISTS,
      // FOR EACH REACTANT (FOR EACH REACTION).
      for (int j = 0; j < _species.size(); ++j)
      {
        iter = std::find(_reactants[i].begin(), _reactants[i].end(), _species[j]);
        index = std::distance(_reactants[i].begin(), iter);

        if (iter != _reactants[i].end())
        {
          // Now we see if the second reactant is a tracked species.
          // We only treat two-body reactions now. This will need to be changed for three-body reactions.
          // e.g. 1) find size of reactants array 2) use find() to search other values inside that size that are not == index
          // 3) same result!
          v_index = std::abs(index - 1);
          find_other = std::find(_species.begin(), _species.end(), _reactants[i][v_index]) != _species.end();
          if (_species_count[i][j] < 0)
          {
            // if (_electron_reaction[i] == false)
            if (!isnan(_rate_coefficient[i]))
            {
              InputParameters params = _factory.getValidParams(reactant_kernel_name);
              params.set<NonlinearVariableName>("variable") = _species[j];
              params.set<Real>("coefficient") = _species_count[i][j];
              params.set<std::string>("reaction") = _reaction[i];

              if (find_other)
              {
                params.set<std::vector<VariableName>>("v") = {_reactants[i][v_index]};
              }
              _problem->addKernel(reactant_kernel_name, "kernel"+std::to_string(j)+"_"+_reaction[i], params);
            }
            else
            {
              if (_coefficient_format == "townsend")
              {
                InputParameters params = _factory.getValidParams(reactant_kernel_name);
                // params.set<NonlinearVariableName>("variable") = _reactants[i][index];
                params.set<NonlinearVariableName>("variable") = _species[j];
                params.set<std::vector<VariableName>>("mean_en") = electron_energy;
                if (_coefficient_format == "townsend")
                  params.set<std::vector<VariableName>>("potential") = getParam<std::vector<VariableName>>("potential");
                params.set<std::vector<VariableName>>("em") = {electron_density};
                params.set<Real>("position_units") = _r_units;
                params.set<std::string>("reaction") = _reaction[i];
                params.set<std::string>("reaction_coefficient_name") = _reaction_coefficient_name[i];
                _problem->addKernel(reactant_kernel_name, "kernel"+std::to_string(j)+"_"+_reaction[i], params);
              }
              else if (_coefficient_format == "rate")
              {
                InputParameters params = _factory.getValidParams(reactant_kernel_name);
                params.set<NonlinearVariableName>("variable") = _species[j];
                params.set<Real>("coefficient") = _species_count[i][j];
                params.set<std::string>("reaction") = _reaction[i];

                if (find_other)
                {
                  params.set<std::vector<VariableName>>("v") = {_reactants[i][v_index]};
                }
                _problem->addKernel(reactant_kernel_name, "kernel"+std::to_string(j)+"_"+_reaction[i], params);

              }
            }
          }
        }

        // Now we do the same thing for the products side of the reaction
        iter = std::find(_products[i].begin(), _products[i].end(), _species[j]);
        index = std::distance(_products[i].begin(), iter);
        species_v = std::find(_species.begin(), _species.end(), _reactants[i][0]) != _species.end();
        species_w = std::find(_species.begin(), _species.end(), _reactants[i][1]) != _species.end();

        if (iter != _products[i].end())
        {

          if (_species_count[i][j] > 0)
          {
            // if (_electron_reaction[i] == false)
            if (!isnan(_rate_coefficient[i]))
            {
              InputParameters params = _factory.getValidParams(product_kernel_name);
              params.set<NonlinearVariableName>("variable") = _species[j];
              params.set<std::string>("reaction") = _reaction[i];
              if (species_v)
                params.set<std::vector<VariableName>>("v") = {_reactants[i][0]};
              if (species_w)
                params.set<std::vector<VariableName>>("w") = {_reactants[i][1]};
              params.set<Real>("coefficient") = _species_count[i][j];
              _problem->addKernel(product_kernel_name, "kernel_prod"+std::to_string(j)+"_"+_reaction[i], params);
            }
            else
            {
              if (_coefficient_format == "townsend")
              {
                InputParameters params = _factory.getValidParams(product_kernel_name);
                params.set<NonlinearVariableName>("variable") = _species[j];
                params.set<std::vector<VariableName>>("mean_en") = electron_energy;
                if (_coefficient_format == "townsend")
                  params.set<std::vector<VariableName>>("potential") = getParam<std::vector<VariableName>>("potential");
                params.set<std::vector<VariableName>>("em") = {electron_density};
                params.set<Real>("position_units") = _r_units;
                params.set<std::string>("reaction") = _reaction[i];
                params.set<std::string>("reaction_coefficient_name") = _reaction_coefficient_name[i];
                _problem->addKernel(product_kernel_name, "kernel_prod"+std::to_string(j)+"_"+_reaction[i], params);
              }
              else if (_coefficient_format == "rate")
              {
                InputParameters params = _factory.getValidParams(product_kernel_name);
                params.set<NonlinearVariableName>("variable") = _species[j];
                params.set<std::string>("reaction") = _reaction[i];
                if (species_v)
                  params.set<std::vector<VariableName>>("v") = {_reactants[i][0]};
                if (species_w)
                  params.set<std::vector<VariableName>>("w") = {_reactants[i][1]};
                params.set<Real>("coefficient") = _species_count[i][j];
                _problem->addKernel(product_kernel_name, "kernel_prod"+std::to_string(j)+"_"+_reaction[i], params);
              }
            }
          }
        }

      }
    }
  }

}
