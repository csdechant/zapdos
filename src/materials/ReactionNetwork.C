#include "ReactionNetwork.h"
#include "MooseUtils.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", ReactionNetwork);

template <>
InputParameters
validParams<ReactionNetwork>()
{
  InputParameters params = validParams<Material>();
  params.addCoupledVar("potential", "The potential.");
  params.addCoupledVar("test_value", "Test of the coupling framework...");
  params.addRequiredCoupledVar("reactant_species", "Density of reactant species.");
  params.addRequiredParam<std::string>("first_reactant_name", "The name of the first reactant.");
  params.addRequiredParam<std::string>("second_reactant_name", "The name of second reactant.");
  params.addParam<std::string>("third_reactant_name", "the name of the third reactant (optional).");
  params.addRequiredParam<std::string>("first_product_name", "The name of the first product.");
  params.addRequiredParam<std::string>("second_product_name", "The name of the second product.");
  params.addParam<std::string>("third_product_name", "The name of the third product (optional).");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  // params.addRequiredParam<Real>("heavy_species_mass", "Mass of the heavy species");
  // params.addRequiredParam<std::string>("potential_units", "The potential units.");
  // params.addRequiredParam<Real>("heavy_species_charge", "Charge of heavy species.");
  // T_gas and p_gas are the neutral gas temperature and pressure.
  // Need to be found from the general "Gas.C" file!
  // params.addParam<Real>("user_T_gas", 300, "The gas temperature in Kelvin.");
  // params.addParam<Real>("user_p_gas", 1.01e5, "The gas pressure in Pascals.");
  return params;
}

ReactionNetwork::ReactionNetwork(const InputParameters & parameters)
  : Material(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _Tem(getMaterialProperty<Real>("Tem")),
    _TemVolts(getMaterialProperty<Real>("TemVolts")),
    _T_gas(getMaterialProperty<Real>("T_gas")),
    _p_gas(getMaterialProperty<Real>("p_gas")),
    _n_gas(getMaterialProperty<Real>("n_gas")),
    _muem(getMaterialProperty<Real>("muem")),
    _N_A(getMaterialProperty<Real>("N_A")),


    _alpha_ex(getMaterialProperty<Real>("alpha_ex")),


    _alpha_dex(declareProperty<Real>("alpha_dex")),
    // _alpha_exiz is the (temporary) excited argon ionization Townsend coeff.

    // _reaction_rate(getMaterialProperty<Real>("k_" + getParam<std::string>("first_reactant_name") + "_" + getParam<std::string>("first_product_name"))),
    // _townsend_rate(declareProperty<Real>("alpha_" + getParam<std::string>("first_reactant_name") + "_" + getParam<std::string>("first_product_name"))),

    _potential_id(coupled("potential")),
    _density(coupledValue("reactant_species")),
    // _grad_potential(coupledGradient("potential"))
    _grad_potential(isCoupled("potential") ? coupledGradient("potential") : _grad_zero),
    _test_value(isCoupled("test_value") ? coupledValue("test_value") : _zero)

{}

void
ReactionNetwork::computeQpProperties()
{
  _alpha_dex[_qp] = _alpha_ex[_qp] * std::exp(_density[_qp]) / _n_gas[_qp];
  // _alpha_dex[_qp] = _alpha_ex[_qp] / 2.0;

  // _alpha_dex[_qp] = _alpha_ex[_qp] * 1.0e-6;
  // std::cout << std::exp(_density[_qp]) << "\n" << _n_gas[_qp] << "\n" << std::endl;

  // _Eexiz[_qp] = 4.30;








  // Lieberman values - not very accurate. Use Bolos instead.

  // _k_Ar_Arp[_qp] = 2.34e-14 * std::pow(_TemVolts[_qp], 0.59) * std::exp(-17.44 / _TemVolts[_qp]);
  //
  // // e + Ar -> Ar(4s) + e
  // _k_Ar_Ar4s[_qp] = 5.00e-15 * std::pow(_TemVolts[_qp], 0.74) * std::exp(-11.56 / _TemVolts[_qp]);
  //
  // // e + Ar(4s) -> Ar + e
  // _k_Ar4s_Ar[_qp] = 4.30e-16 * std::pow(_TemVolts[_qp], 0.74);
  //
  // // e + Ar(4s) -> Arp + 2e
  // _k_Ar4s_Arp[_qp] = 6.80e-15 * std::pow(_TemVolts[_qp], 0.67) * std::exp(-4.20 / _TemVolts[_qp]);
  //
  // // e + Ar(4s) -> Ar(4p) + e
  // _k_Ar4s_Ar4p[_qp] = 8.90e-13 * std::pow(_TemVolts[_qp], 0.51) * std::exp(-1.59 / _TemVolts[_qp]);
  //
  // // e + Ar -> Ar(4p) + e
  // _k_Ar_Ar4p[_qp] = 1.40e-14 * std::pow(_TemVolts[_qp], 0.71) * std::exp(-13.20 / _TemVolts[_qp]);
  //
  // // e + Ar(4p) -> Arp + 2e
  // _k_Ar4p_Arp[_qp] = 1.80e-13 * std::pow(_TemVolts[_qp], 0.61) * std::exp(-2.61 / _TemVolts[_qp]);
  //
  // // e + Ar -> Ar* + e  (This one is too large; variable simply explodes)
  // _k_Ar_ArEx[_qp] = 2.48e-18 * std::pow(_TemVolts[_qp], 0.33) * std::exp(-12.78 / _TemVolts[_qp]);
  //
  // // e + Ar(4p) -> Arp + e
  // _k_Ar_Arp[_qp] = _k_Ar_Arp[_qp] * _N_A[_qp];




}
