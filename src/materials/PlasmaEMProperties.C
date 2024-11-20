
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
<<<<<<< HEAD:src/materials/PlasmaDielectricConstant.C
  params.addCoupledVar("electrons", "The electron density in log form");
  params.addClassDescription("Provides the real and complex components, the spatial gradient and "
                             "the first time derivative of the plasma dielectric.");
=======
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
>>>>>>> 6a7b3540 (Consolidating of version of PlasmaDielectricConstant and renaming to PlasmaEMProperties):src/materials/PlasmaEMProperties.C
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
    _em(adCoupledValue("electrons")),
    _em_grad(adCoupledGradient("electrons")),
    _em_var(getVar("electrons", 0)),
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
  using std::exp;
  using std::pow;
  using std::sqrt;
  /// Calculate the plasma frequency
  Real omega_pe_const = sqrt(pow(_elementary_charge, 2) / (_eps_vacuum * _electron_mass));
  ADReal omega_pe = omega_pe_const * sqrt(exp(_em[_qp]));

  // Calculate the value of the plasma dielectric constant
  _eps_r_real[_qp] =
      1.0 - (pow(omega_pe, 2) / (pow(2 * _pi * _frequency, 2) + pow(2 * _pi * _nu, 2)));
  _eps_r_imag[_qp] = (-1.0 * pow(omega_pe, 2) * 2 * _pi * _nu) /
                     (pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * pow(2 * _pi * _nu, 2));

  // Calculate the gradient of the plasma dielectric constant
  ADReal grad_const = -pow(omega_pe, 2) / (pow(2 * _pi * _frequency, 2) + pow(2 * _pi * _nu, 2));
  _eps_r_real_grad[_qp] = grad_const * _em_grad[_qp];
  _eps_r_imag_grad[_qp] = (grad_const * _nu / (2 * _pi * _frequency)) * _em_grad[_qp];

  if (_fe_problem.isTransient())
  {
    // Calculate the first time derivative of the linear electron density
    ADReal lin_dot = _em_dot[_qp] * exp(_em[_qp]);

    // Calculate the first time derivative of the plasma dielectric constant
    _eps_r_real_dot[_qp] = -1.0 * pow(omega_pe_const, 2) * lin_dot /
                           (pow(2 * _pi * _frequency, 2) + pow(2 * _pi * _nu, 2));

    _eps_r_imag_dot[_qp] =
        -1.0 * pow(omega_pe_const, 2) * 2 * _pi * _nu * lin_dot /
        (pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * pow(2 * _pi * _nu, 2));

    /*
     *  TODO: The second derivative of the dielectric coefficient is currently showing
     *        a convergence slope of less than 2 using the manufactured solution in file
     *        /test/tests/mms/materials/2D_PlasmaDielectricConstant.i.
     *
     *        The current theory is that one of the terms in 'lin_dot_dot' is
     *        significantly smaller than the other term that the error is affecting the
     *        convergence slope, but more study is needed.
     */
    /*
    // Calculate the second time derivative of the linear electron density
    ADReal lin_dot_dot =
        _em_dot_dot[_qp] * exp(_em[_qp]) + pow(_em_dot[_qp], 2) * exp(_em[_qp]);

    // Calculate the second time derivative of the plasma dielectric constant
    _eps_r_real_dot_dot[_qp] = -1.0 * pow(omega_pe_const, 2) * lin_dot_dot /
                               (pow(2 * _pi * _frequency, 2) + pow(2 * _pi * _nu, 2));
    _eps_r_imag_dot_dot[_qp] =
        -1.0 * pow(omega_pe_const, 2) * 2 * _pi * _nu * lin_dot_dot /
        (pow(2 * _pi * _frequency, 3) + 2 * _pi * _frequency * pow(2 * _pi * _nu, 2));
    */
  }
}
