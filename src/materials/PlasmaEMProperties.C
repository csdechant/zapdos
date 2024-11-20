
#include "PlasmaEMProperties.h"
#include "PlasmaEnums.h"

registerMooseObject("ZapdosApp", PlasmaEMProperties);

InputParameters
PlasmaEMProperties::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addRequiredParam<MaterialPropertyName>(
      "electron_neutral_collision_frequency", "The electron-neutral collision frequency (in Hz).");
  params.addRequiredParam<MaterialPropertyName>(
      "electron_neutral_collision_frequency_gradient",
      "The gradient electron-neutral collision frequency (in Hz).");
  params.addRequiredParam<Real>("driving_frequency", "Driving frequency of plasma (in Hz).");
  params.addRequiredCoupledVar("em", "Electron density coupled variable.");
  params.addClassDescription(
      "Provides the real and complex components, the spatial gradient, the first time derivative, "
      "and second time derivative of the plasma dielectric and the real and complex components of "
      "the plasma conductivity.");
  MooseEnum coeff("relative absolute", "relative");
  params.addParam<MooseEnum>(
      "coeff_type",
      coeff,
      "Whether to use relative or absolute versions of the electromagnetic properties.");
  return params;
}

PlasmaEMProperties::PlasmaEMProperties(const InputParameters & parameters)
  : ADMaterial(parameters),
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
    _nu(getADMaterialProperty<Real>("electron_neutral_collision_frequency")),
    _grad_nu(
        getADMaterialProperty<RealVectorValue>("electron_neutral_collision_frequency_gradient")),
    _frequency(getParam<Real>("driving_frequency")),
    _em(adCoupledValue("em")),
    _em_grad(adCoupledGradient("em")),
    _em_var(getVar("em", 0)),
    _em_dot(_fe_problem.isTransient() ? _em_var->adUDot() : _ad_zero),
    _em_dot_dot(_fe_problem.isTransient() ? _em_var->adUDotDot() : _ad_zero),
    _N_A(getMaterialProperty<Real>("N_A")),
    _sigma_pe_real(declareADProperty<Real>("plasma_conductivity_real")),
    _sigma_pe_imag(declareADProperty<Real>("plasma_conductivity_imag")),
    _coeff_type(getParam<MooseEnum>("coeff_type"))

{
}

void
PlasmaEMProperties::computeQpProperties()
{
  /// Calculate the plasma frequency
  Real omega_pe_const = std::sqrt(std::pow(_elementary_charge, 2) / (_eps_vacuum * _electron_mass));
  ADReal omega_pe = omega_pe_const * std::sqrt(std::exp(_em[_qp]) * _N_A[_qp]);

  Real coeff = 1.0;
  if (_coeff_type == LTP::ABSOLUTE)
    coeff = _eps_vacuum;

  mooseDoOnce(std::cout << "Elementary charge is " << _elementary_charge << "\n");
  mooseDoOnce(std::cout << "Vacuum electric permittivity is " << _eps_vacuum << "\n");
  mooseDoOnce(std::cout << "Electron mass is " << _electron_mass << "\n");
  mooseDoOnce(std::cout << "Electron density (log) is " << _em[_qp] << "\n");
  mooseDoOnce(std::cout << "Electron density (linear) is " << (std::exp(_em[_qp]) * _N_A[_qp])
                        << "\n");
  mooseDoOnce(std::cout << "Plasma frequency is " << omega_pe << "\n");
  mooseDoOnce(std::cout << "Driving frequency is " << _frequency << " in Hertz. \n");
  mooseDoOnce(std::cout << "Electron neutral collision frequency is " << _nu[_qp]
                        << " in Hertz. \n");

  // Calculate the value of the plasma dielectric constant
  _eps_r_real[_qp] =
      coeff *
      (1.0 - (std::pow(omega_pe, 2) / (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu[_qp], 2))));
  _eps_r_imag[_qp] =
      coeff * (-1.0 * std::pow(omega_pe, 2) * _nu[_qp]) /
      (std::pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * std::pow(_nu[_qp], 2));

  _sigma_pe_real[_qp] = coeff * std::pow(omega_pe, 2) * _nu[_qp] /
                        (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu[_qp], 2));
  _sigma_pe_imag[_qp] = -coeff * std::pow(omega_pe, 2) * 2 * _pi * _frequency /
                        (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu[_qp], 2));

  mooseDoOnce(std::cout << "Pi is " << _pi << "\n");
  mooseDoOnce(std::cout << "Plasma dielectric constant (real) is " << _eps_r_real[_qp] << "\n");
  mooseDoOnce(std::cout << "Plasma dielectric constant (imaginary) is " << _eps_r_imag[_qp]
                        << "\n");

  // Calculate the gradient of the plasma dielectric constant
  _eps_r_real_grad[_qp] = -coeff *
                          (std::pow(omega_pe, 2) * _em_grad[_qp] *
                               (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu[_qp], 2)) -
                           std::pow(omega_pe, 2) * 2.0 * _nu[_qp] * _grad_nu[_qp]) /
                          (std::pow(omega_pe, 4) + std::pow(omega_pe, 2) * std::pow(_nu[_qp], 2) +
                           std::pow(_nu[_qp], 4));
  _eps_r_imag_grad[_qp] =
      (_eps_r_real_grad[_qp] * _nu[_qp] -
       coeff *
           (std::pow(omega_pe, 2) / (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu[_qp], 2))) *
           _grad_nu[_qp]) /
      (2 * _pi * _frequency);

  if (_fe_problem.isTransient())
  {
    // Calculate the first time derivative of the linear electron density
    ADReal lin_dot = _em_dot[_qp] * std::exp(_em[_qp]); // May need to add *_N_A[_qp]

    // Calculate the first time derivative of the plasma dielectric constant
    // TODO: Update of time dependent _nu[_qp]
    _eps_r_real_dot[_qp] = -1.0 * std::pow(omega_pe_const, 2) * lin_dot /
                           (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu[_qp], 2));

    _eps_r_imag_dot[_qp] =
        -1.0 * std::pow(omega_pe_const, 2) * _nu[_qp] * lin_dot /
        (std::pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * std::pow(_nu[_qp], 2));

    // Calculate the second time derivative of the linear electron density
    ADReal lin_dot_dot =
        _em_dot_dot[_qp] * std::exp(_em[_qp]) +
        std::pow(_em_dot[_qp], 2) * std::exp(_em[_qp]); // May need to add *_N_A[_qp]

    // Calculate the second time derivative of the plasma dielectric constant
    // TODO: Update of time dependent _nu[_qp]
    _eps_r_real_dot_dot[_qp] = -1.0 * std::pow(omega_pe_const, 2) * lin_dot_dot /
                               (std::pow(2 * _pi * _frequency, 2) + std::pow(_nu[_qp], 2));
    _eps_r_imag_dot_dot[_qp] =
        -1.0 * std::pow(omega_pe_const, 2) * _nu[_qp] * lin_dot_dot /
        (std::pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * std::pow(_nu[_qp], 2));
  }
}
