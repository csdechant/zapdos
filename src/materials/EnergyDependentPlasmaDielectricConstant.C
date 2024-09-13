#include "EnergyDependentPlasmaDielectricConstant.h"

registerMooseObject("ZapdosApp", EnergyDependentPlasmaDielectricConstant);

InputParameters
EnergyDependentPlasmaDielectricConstant::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("");

  params.addRequiredParam<Real>("driving_frequency", "Driving frequency of plasma (in Hz).");

  params.addRequiredCoupledVar("em", "Electron density coupled variable.");
  params.addRequiredCoupledVar("mean_en", "The electron mean energy in log form.");

  params.addParam<Real>("user_electron_neutral_collision_frequency",
                        0,
                        "The electron-neutral collision frequency (in Hz).");
  params.addRequiredParam<FileName>(
      "property_tables_file", "The file containing interpolation tables for material properties.");
  return params;
}

EnergyDependentPlasmaDielectricConstant::EnergyDependentPlasmaDielectricConstant(
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

    _mean_en(adCoupledValue("mean_en")),

    _k_boltz(getMaterialProperty<Real>("k_boltz")),
    _T_gas(getMaterialProperty<Real>("T_gas")),
    _p_gas(getMaterialProperty<Real>("p_gas"))
{
  std::vector<Real> actual_mean_energy;
  std::vector<Real> nu;

  std::string file_name = getParam<FileName>("property_tables_file");
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
      nu.push_back(value);
    }
    myfile.close();
  }

  else
    mooseError("Unable to open file");

  _nu_interpolation.setData(actual_mean_energy, nu);
}

void
EnergyDependentPlasmaDielectricConstant::computeQpProperties()
{

  Real N_A = 6.0221409E23;
  Real _N_gas = _p_gas[_qp] / (_k_boltz[_qp] * _T_gas[_qp]);

  /// Calculate the plasma frequency
  Real omega_pe_sq_const = std::pow(_elementary_charge, 2) / (_eps_vacuum * _electron_mass);
  // ADReal omega_pe = omega_pe_const * std::sqrt(std::exp(_em[_qp]));

  /*
  mooseDoOnce(std::cout << "Elementary charge is " << _elementary_charge << "\n");
  mooseDoOnce(std::cout << "Vacuum electric permittivity is " << _eps_vacuum << "\n");
  mooseDoOnce(std::cout << "Electron mass is " << _electron_mass << "\n");
  mooseDoOnce(std::cout << "Electron density (log) is " << _em[_qp] << "\n");
  mooseDoOnce(std::cout << "Electron density (linear) is " << std::exp(_em[_qp]) << "\n");
  mooseDoOnce(std::cout << "Plasma frequency is " << omega_pe << "\n");
  mooseDoOnce(std::cout << "Driving frequency is " << _frequency << " in Hertz. \n");
  mooseDoOnce(std::cout << "Electron neutral collision frequency is " << _nu << " in Hertz. \n");
*/

  // Calculate the value of the plasma dielectric constant
  //_eps_r_real[_qp] =
  //    1.0 - (std::pow(omega_pe, 2) / (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu, 2)));
  //_eps_r_imag[_qp] = (-1.0 * std::pow(omega_pe, 2) * _nu) /
  //                   (std::pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * std::pow(_nu,
  //

  _sigma_pe_real[_qp].value() =
      8.8542e-12 * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
      _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas /
      (std::pow(2 * _pi * _frequency, 2) +
       std::pow(_nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                    _N_gas,
                2));

  _eps_r_real[_qp].value() =
      1.0 -
      (omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A /
       (std::pow(2 * _pi * _frequency, 2) +
        std::pow(_nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                     _N_gas,
                 2)));

  _eps_r_imag[_qp].value() =
      (-1.0 * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
       _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas) /
      (std::pow(2 * _pi * _frequency, 3) +
       2 * _pi * _frequency *
           std::pow(_nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                        _N_gas,
                    2));

  _eps_r_real[_qp].derivatives() =
      -1.0 * _em[_qp].derivatives() * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A /
          (std::pow(2 * _pi * _frequency, 2) +
           std::pow(_nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                        _N_gas,
                    2)) +
      omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A * 2.0 *
          _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas *
          _nu_interpolation.sampleDerivative(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
          _N_gas * std::exp(_mean_en[_qp].value() - _em[_qp].value()) *
          (_mean_en[_qp].derivatives() - _em[_qp].derivatives()) /
          std::pow(std::pow(2 * _pi * _frequency, 2) +
                       std::pow(_nu_interpolation.sample(
                                    std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                                    _N_gas,
                                2),
                   2);

  _eps_r_imag[_qp].derivatives() =
      -1.0 * _em[_qp].derivatives() * omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
          _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas /
          (std::pow(2 * _pi * _frequency, 3) +
           2 * _pi * _frequency *
               std::pow(
                   _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                       _N_gas,
                   2)) -
      omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
          _nu_interpolation.sampleDerivative(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
          _N_gas * std::exp(_mean_en[_qp].value() - _em[_qp].value()) *
          (_mean_en[_qp].derivatives() - _em[_qp].derivatives()) /
          (std::pow(2 * _pi * _frequency, 3) +
           2 * _pi * _frequency *
               std::pow(
                   _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                       _N_gas,
                   2)) +
      omega_pe_sq_const * std::exp(_em[_qp].value()) * N_A *
          _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas *
          2 * _pi * _frequency * 2.0 *
          _nu_interpolation.sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas *
          _nu_interpolation.sampleDerivative(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
          _N_gas * std::exp(_mean_en[_qp].value() - _em[_qp].value()) *
          (_mean_en[_qp].derivatives() - _em[_qp].derivatives()) /
          std::pow(std::pow(2 * _pi * _frequency, 3) +
                       2 * _pi * _frequency *
                           std::pow(_nu_interpolation.sample(
                                        std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
                                        _N_gas,
                                    2),
                   2);

  /*
  mooseDoOnce(std::cout << "Pi is " << _pi << "\n");
  mooseDoOnce(std::cout << "Plasma dielectric constant (real) is " << _eps_r_real[_qp] << "\n");
  mooseDoOnce(std::cout << "Plasma dielectric constant (imaginary) is " << _eps_r_imag[_qp]
                        << "\n");
                        */

  // NEED TO FORMULATE ENERGY DEPENDENT DIELECTRIC CONSTANT
  /*
    // Calculate the gradient of the plasma dielectric constant
    ADReal grad_const =
        -std::pow(omega_pe, 2) / (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu, 2));
    _eps_r_real_grad[_qp] = grad_const * _em_grad[_qp];
    _eps_r_imag_grad[_qp] = (grad_const * _nu / (2 * _pi * _frequency)) * _em_grad[_qp];

    if (_fe_problem.isTransient())
    {
      // Calculate the first time derivative of the linear electron density
      ADReal lin_dot = _em_dot[_qp] * std::exp(_em[_qp]);

      // Calculate the first time derivative of the plasma dielectric constant
      _eps_r_real_dot[_qp] = -1.0 * std::pow(omega_pe_const, 2) * lin_dot /
                             (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu, 2));

      _eps_r_imag_dot[_qp] =
          -1.0 * std::pow(omega_pe_const, 2) * _nu * lin_dot /
          (std::pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * std::pow(_nu, 2));

      // Calculate the second time derivative of the linear electron density
      ADReal lin_dot_dot =
          _em_dot_dot[_qp] * std::exp(_em[_qp]) + std::pow(_em_dot[_qp], 2) * std::exp(_em[_qp]);

      // Calculate the second time derivative of the plasma dielectric constant
      _eps_r_real_dot_dot[_qp] = -1.0 * std::pow(omega_pe_const, 2) * lin_dot_dot /
                                 (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu, 2));
      _eps_r_imag_dot_dot[_qp] =
          -1.0 * std::pow(omega_pe_const, 2) * _nu * lin_dot_dot /
          (std::pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * std::pow(_nu, 2));
    }
  */
}
