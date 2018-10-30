#include "GenericEnergyDependentReactionRate.h"
#include "MooseUtils.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", GenericEnergyDependentReactionRate);

template <>
InputParameters
validParams<GenericEnergyDependentReactionRate>()
{
  InputParameters params = validParams<Material>();
  params.addRequiredParam<std::string>(
      "property_file", "The file containing interpolation tables for material properties.");
  params.addRequiredParam<std::string>("reaction", "The full reaction equation.");
  params.addRequiredParam<Real>("position_units", "The units of position.");
  params.addRequiredParam<FileName>("file_location", "The name of the file that stores the reaction rate tables.");
  params.addParam<bool>("elastic_collision", false,
                        "Determining whether or not a collision is elastic. Energy change for elastic collisions is calculated on the fly, not pre-assigned.");
  params.addParam<std::string>("reaction_coefficient_format", "townsend",
    "The format of the reaction coefficient. Options: rate or townsend.");
  params.addCoupledVar("target_species", "The heavy (target) species. Optional (default: _n_gas).");
  params.addCoupledVar("mean_en", "The electron mean energy in log form.");
  params.addCoupledVar("em", "The electron density.");
  params.addCoupledVar("potential", "The electric potential.");

  return params;
}

GenericEnergyDependentReactionRate::GenericEnergyDependentReactionRate(const InputParameters & parameters)
  : Material(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _coefficient_format(getParam<std::string>("reaction_coefficient_format")),
    _reaction_rate(declareProperty<Real>("k_"+getParam<std::string>("reaction"))),
    _townsend_coefficient(declareProperty<Real>("alpha_"+getParam<std::string>("reaction"))),
    _energy_elastic(declareProperty<Real>("energy_elastic_"+getParam<std::string>("reaction"))),
    _d_k_d_en(declareProperty<Real>("d_k_d_en_"+getParam<std::string>("reaction"))),
    _d_alpha_d_en(declareProperty<Real>("d_alpha_d_en_"+getParam<std::string>("reaction"))),
    _d_muem_d_actual_mean_en(getMaterialProperty<Real>("d_muem_d_actual_mean_en")),
    _n_gas(getMaterialProperty<Real>("n_gas")),
    _muem(getMaterialProperty<Real>("muem")),
    _massElectron(getMaterialProperty<Real>("massem")),
    _massGas(getMaterialProperty<Real>("massGas")),

    // Electron information
    _target_species(isCoupled("target_species") ? coupledValue("target_species") : _zero),
    _em(isCoupled("em") ? coupledValue("em") : _zero),
    _mean_en(isCoupled("mean_en") ? coupledValue("mean_en") : _zero),
    _grad_potential(isCoupled("potential") ? coupledGradient("potential") : _grad_zero),

    // Elastic collision check
    _elastic_collision(getParam<bool>("elastic_collision"))
{
  // if (_coefficient_format == "townsend" && !isCoupled("potential"))
  // {
    // mooseError("Reaction coefficient type 'townsend' requires coupling of potential into GenericEnergyDependentReactionRate.");
  // }

  std::vector<Real> actual_mean_energy;
  std::vector<Real> rate_coefficient;
  // std::vector<Real> d_alpha_d_actual_mean_energy;
  // std::string file_name = getParam<FileName>("property_tables_file");
  //std::string file_name = getParam<std::string>("file_location") + "/" + getParam<FileName>("property_file");
  std::string file_name = getParam<FileName>("file_location") + "/" + getParam<std::string>("property_file");
  MooseUtils::checkFileReadable(file_name);
  const char * charPath = file_name.c_str();
  std::ifstream myfile(charPath);
  Real value;

  if (myfile.is_open())
  {
    while (myfile >> value)
    {
      actual_mean_energy.push_back(value);
      myfile >> value;
      rate_coefficient.push_back(value);
    }
    myfile.close();
  }
  else
    mooseError("Unable to open file");

  _coefficient_interpolation.setData(actual_mean_energy, rate_coefficient);

  if (_coefficient_format != "rate" && _coefficient_format != "townsend")
    mooseError("Reaction coefficient format '" + _coefficient_format + "' not recognized. Only 'townsend' and 'rate' are accepted.");
}

void
GenericEnergyDependentReactionRate::computeQpProperties()
{
  Real actual_mean_energy = std::exp(_mean_en[_qp] - _em[_qp]);
  if (_coefficient_format == "townsend")
  {
    _townsend_coefficient[_qp] = _coefficient_interpolation.sample(actual_mean_energy);
    _d_alpha_d_en[_qp] = _coefficient_interpolation.sampleDerivative(actual_mean_energy);


    if (isCoupled("target_species"))
    {
      _townsend_coefficient[_qp] = _townsend_coefficient[_qp] * std::exp(_target_species[_qp]) / _n_gas[_qp];
    }

    if (_elastic_collision == true)
    {
      _energy_elastic[_qp] = -3.0 * _massElectron[_qp] / _massGas[_qp] * 2.0 / 3.0 * std::exp(_mean_en[_qp] - _em[_qp]);
    }
  }
  else
  {
    _reaction_rate[_qp] = _coefficient_interpolation.sample(actual_mean_energy);
    _d_k_d_en[_qp] = _coefficient_interpolation.sampleDerivative(actual_mean_energy);
  }


  /* Creating a townsend coefficient from the reaction rate does not seem to work.
  * (The values are very close...but including the Jacobian for the reaction rate
  * requires multiple derivatives. Including this in the energy equation causes convergence issues.)
  * I will need to figure that out later. For now, townsend coefficients are calculated
  * in Bolos (or BOLSIG+).
  */

  // _reaction_rate[_qp] = _rate_coefficient_interpolation.sample(actual_mean_energy);
  // _d_k_d_en[_qp] = _rate_coefficient_interpolation.sampleDerivative(actual_mean_energy);
  //
  // if (isCoupled("target_species"))
  // {
  //   _townsend_coefficient[_qp] = std::exp(_target_species[_qp]) * _reaction_rate[_qp] / (_muem[_qp] * (_grad_potential[_qp](0) * _r_units));
  //   _d_alpha_d_en[_qp] = (std::exp(_target_species[_qp]) / _grad_potential[_qp](0)) * (_d_k_d_en[_qp] / _muem[_qp] + (_reaction_rate[_qp]/(_muem[_qp]*_muem[_qp]))*(_d_muem_d_actual_mean_en[_qp]));
  // }
  // else
  // {
  //   _townsend_coefficient[_qp] = _n_gas[_qp] * (6.022e23) * _reaction_rate[_qp] / (_muem[_qp] * (_grad_potential[_qp](0)));
  //   _d_alpha_d_en[_qp] = (_n_gas[_qp] * (6.022e23) / _grad_potential[_qp](0)) * ((_d_k_d_en[_qp] / _muem[_qp]) + (_reaction_rate[_qp]/(_muem[_qp]*_muem[_qp]))*(_d_muem_d_actual_mean_en[_qp]));
  // }

}
