#include "ReduceEFieldDependentPlasmaDielectricConstant.h"
#include "MooseUtils.h"

#include "MooseVariable.h"

registerMooseObject("ZapdosApp", ReduceEFieldDependentPlasmaDielectricConstant);

InputParameters
ReduceEFieldDependentPlasmaDielectricConstant ::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("");

  params.addRequiredParam<Real>("driving_frequency", "Driving frequency of plasma (in Hz).");

  params.addRequiredCoupledVar("em", "Electron density coupled variable.");
  params.addParam<std::string>("field_property_name",
                               "field_solver_interface_property",
                               "Name of the solver interface material property.");

  params.addParam<Real>("user_electron_neutral_collision_frequency",
                        0,
                        "The electron-neutral collision frequency (in Hz).");
  params.addRequiredParam<FileName>(
      "property_tables_file", "The file containing interpolation tables for material properties.");
  return params;
}

ReduceEFieldDependentPlasmaDielectricConstant::ReduceEFieldDependentPlasmaDielectricConstant(
    const InputParameters & parameters)
  : ADMaterial(parameters),

    _sigma_pe_real(declareADProperty<Real>("plasma_conductivity_real")),

    _eps_r_real(declareADProperty<Real>("plasma_dielectric_constant_real")),
    _eps_r_real_grad(declareADProperty<RealVectorValue>("plasma_dielectric_constant_real_grad")),
    _eps_r_real_dot(declareADProperty<Real>("plasma_dielectric_constant_real_dot")),
    _eps_r_real_dot_dot(declareADProperty<Real>("plasma_dielectric_constant_real_dot_dot")),
    _eps_r_imag(declareADProperty<Real>("plasma_dielectric_constant_imag")),
    _eps_r_imag_grad(declareADProperty<RealVectorValue>("plasma_dielectric_constant_imag_grad")),
    _eps_r_imag_dot(declareADProperty<Real>("plasma_dielectric_constant_imag_dot")),
    _eps_r_imag_dot_dot(declareADProperty<Real>("plasma_dielectric_constant_imag_dot_dot")),
    _elementary_charge(1.6022e-19),
    _electron_mass(9.1095e-31),
    _eps_vacuum(8.8542e-12),
    _pi(libMesh::pi),

    _user_nu(getParam<Real>("user_electron_neutral_collision_frequency")),

    _frequency(getParam<Real>("driving_frequency")),
    _em(adCoupledValue("em")),
    _em_grad(adCoupledGradient("em")),
    _em_var(getVar("em", 0)),
    _em_dot(_fe_problem.isTransient() ? _em_var->adUDot() : _ad_zero),
    _em_dot_dot(_fe_problem.isTransient() ? _em_var->adUDotDot() : _ad_zero),

    _electric_field(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("field_property_name"))),

    _k_boltz(getMaterialProperty<Real>("k_boltz")),
    _T_gas(getMaterialProperty<Real>("T_gas")),
    _p_gas(getMaterialProperty<Real>("p_gas")),

    _e_temp(declareADProperty<Real>("electron_temp"))
{
  std::vector<Real> reduce_E_field;
  std::vector<Real> nu;
  std::vector<Real> e_temp;

  std::string file_name = getParam<FileName>("property_tables_file");
  MooseUtils::checkFileReadable(file_name);
  const char * charPath = file_name.c_str();
  std::ifstream myfile(charPath);
  Real value;

  if (myfile.is_open())
  {
    while (myfile >> value)
    {
      reduce_E_field.push_back(value);
      myfile >> value;
      nu.push_back(value);
      myfile >> value;
      e_temp.push_back(value);
    }
    myfile.close();
  }

  else
    mooseError("Unable to open file");

  //_nu_interpolation = std::make_unique<LinearInterpolation>(reduce_E_field, nu, true);
  _nu_interpolation = std::make_unique<LinearInterpolation>(reduce_E_field, nu, true);
  _temp_interpolation = std::make_unique<LinearInterpolation>(reduce_E_field, e_temp, true);
}

void
ReduceEFieldDependentPlasmaDielectricConstant::computeQpProperties()
{
  Real N_A = 6.0221409E23;
  Real _N_gas = _p_gas[_qp] / (_k_boltz[_qp] * _T_gas[_qp]);
  Real Td = _N_gas * 1e-21;

  /// Calculate the plasma frequency
  Real omega_pe_sq_const = std::pow(_elementary_charge, 2) / (_eps_vacuum * _electron_mass);

  _e_temp[_qp].value() =
      _temp_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                            std::pow(_electric_field[_qp](1).value(), 2) +
                                            std::pow(_electric_field[_qp](2).value(), 2)) /
                                  Td);

  _sigma_pe_real[_qp].value() =
      8.8542e-12 * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
      _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                          std::pow(_electric_field[_qp](1).value(), 2) +
                                          std::pow(_electric_field[_qp](2).value(), 2)) /
                                Td) *
      _N_gas /
      (std::pow(2 * _pi * _frequency, 2) +
       std::pow(_nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                    std::pow(_electric_field[_qp](1).value(), 2) +
                                                    std::pow(_electric_field[_qp](2).value(), 2)) /
                                          Td) *
                    _N_gas,
                2));

  _eps_r_real[_qp].value() =
      1.0 -
      (omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A /
       (std::pow(2 * _pi * _frequency, 2) +
        std::pow(_nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                     std::pow(_electric_field[_qp](1).value(), 2) +
                                                     std::pow(_electric_field[_qp](2).value(), 2)) /
                                           Td) *
                     _N_gas,
                 2)));

  _eps_r_imag[_qp].value() =
      (-1.0 * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
       _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                           std::pow(_electric_field[_qp](1).value(), 2) +
                                           std::pow(_electric_field[_qp](2).value(), 2)) /
                                 Td) *
       _N_gas) /
      (std::pow(2 * _pi * _frequency, 3) +
       2 * _pi * _frequency *
           std::pow(
               _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                   std::pow(_electric_field[_qp](1).value(), 2) +
                                                   std::pow(_electric_field[_qp](2).value(), 2)) /
                                         Td) *
                   _N_gas,
               2));

  /*
    _eps_r_real[_qp].derivatives() =
        -1.0 * _em[_qp].derivatives() * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A /
            (std::pow(2 * _pi * _frequency, 2) +
             std::pow(
                 _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                     std::pow(_electric_field[_qp](1).value(), 2) +
                                                     std::pow(_electric_field[_qp](2).value(), 2)) /
                                           Td) *
                     _N_gas,
                 2)) +
        omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A * 2.0 *
            _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                std::pow(_electric_field[_qp](1).value(), 2) +
                                                std::pow(_electric_field[_qp](2).value(), 2)) /
                                      Td) *
            _N_gas *
            _nu_interpolation->sampleDerivative(
                std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                          std::pow(_electric_field[_qp](1).value(), 2) +
                          std::pow(_electric_field[_qp](2).value(), 2)) /
                Td) *
            _N_gas *
            (0.5 *
             std::pow(std::pow(_electric_field[_qp](0).value(), 2) +
                          std::pow(_electric_field[_qp](1).value(), 2) +
                          std::pow(_electric_field[_qp](2).value(), 2),
                      -0.5) *
             2.0 *
             (_electric_field[_qp](0).value() * _electric_field[_qp](0).derivatives() +
              _electric_field[_qp](1).value() * _electric_field[_qp](1).derivatives() +
              _electric_field[_qp](2).value() * _electric_field[_qp](2).derivatives()) /
             Td) /
            std::pow(std::pow(2 * _pi * _frequency, 2) +
                         std::pow(_nu_interpolation->sample(
                                      std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                std::pow(_electric_field[_qp](1).value(), 2) +
                                                std::pow(_electric_field[_qp](2).value(), 2)) /
                                      Td) *
                                      _N_gas,
                                  2),
                     2);

    _eps_r_imag[_qp].derivatives() =
        -1.0 * _em[_qp].derivatives() * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
            _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                std::pow(_electric_field[_qp](1).value(), 2) +
                                                std::pow(_electric_field[_qp](2).value(), 2)) /
                                      Td) *
            _N_gas /
            (std::pow(2 * _pi * _frequency, 3) +
             2 * _pi * _frequency *
                 std::pow(_nu_interpolation->sample(
                              std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                        std::pow(_electric_field[_qp](1).value(), 2) +
                                        std::pow(_electric_field[_qp](2).value(), 2)) /
                              Td) *
                              _N_gas,
                          2)) -
        omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
            _nu_interpolation->sampleDerivative(
                std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                          std::pow(_electric_field[_qp](1).value(), 2) +
                          std::pow(_electric_field[_qp](2).value(), 2)) /
                Td) *
            _N_gas *
            (0.5 *
             std::pow(std::pow(_electric_field[_qp](0).value(), 2) +
                          std::pow(_electric_field[_qp](1).value(), 2) +
                          std::pow(_electric_field[_qp](2).value(), 2),
                      -0.5) *
             2.0 *
             (_electric_field[_qp](0).value() * _electric_field[_qp](0).derivatives() +
              _electric_field[_qp](1).value() * _electric_field[_qp](1).derivatives() +
              _electric_field[_qp](2).value() * _electric_field[_qp](2).derivatives()) /
             Td) /
            (std::pow(2 * _pi * _frequency, 3) +
             2 * _pi * _frequency *
                 std::pow(_nu_interpolation->sample(
                              std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                        std::pow(_electric_field[_qp](1).value(), 2) +
                                        std::pow(_electric_field[_qp](2).value(), 2)) /
                              Td) *
                              _N_gas,
                          2)) +
        omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
            _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                std::pow(_electric_field[_qp](1).value(), 2) +
                                                std::pow(_electric_field[_qp](2).value(), 2)) /
                                      Td) *
            _N_gas * 2 * _pi * _frequency * 2.0 *
            _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                std::pow(_electric_field[_qp](1).value(), 2) +
                                                std::pow(_electric_field[_qp](2).value(), 2)) /
                                      Td) *
            _N_gas *
            _nu_interpolation->sampleDerivative(
                std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                          std::pow(_electric_field[_qp](1).value(), 2) +
                          std::pow(_electric_field[_qp](2).value(), 2)) /
                Td) *
            _N_gas *
            (0.5 *
             std::pow(std::pow(_electric_field[_qp](0).value(), 2) +
                          std::pow(_electric_field[_qp](1).value(), 2) +
                          std::pow(_electric_field[_qp](2).value(), 2),
                      -0.5) *
             2.0 *
             (_electric_field[_qp](0).value() * _electric_field[_qp](0).derivatives() +
              _electric_field[_qp](1).value() * _electric_field[_qp](1).derivatives() +
              _electric_field[_qp](2).value() * _electric_field[_qp](2).derivatives()) /
             Td) /
            std::pow(std::pow(2 * _pi * _frequency, 3) +
                         2 * _pi * _frequency *
                             std::pow(_nu_interpolation->sample(
                                          std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                                    std::pow(_electric_field[_qp](1).value(), 2) +
                                                    std::pow(_electric_field[_qp](2).value(), 2)) /
                                          Td) *
                                          _N_gas,
                                      2),
                     2);
                     */
}
