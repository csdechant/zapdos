#include "DependentCollisionFreq.h"
#include "MooseUtils.h"

#include "MooseVariable.h"

registerMooseObject("ZapdosApp", DependentCollisionFreq);

InputParameters
DependentCollisionFreq ::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("");

  params.addCoupledVar("mean_energy", "The electron mean energy in log form.");
  params.addCoupledVar("electrons", "The electron density.");
  params.addParam<Real>("driving_frequency", 0.0, "Driving frequency of plasma (in Hz).");
  params.addParam<Real>("delta", 20.0, "The Doppler broadening parameter");
  params.addRequiredParam<std::string>(
      "file_location", "The name of the file that stores the reaction rate tables.");
  params.addRequiredParam<FileName>(
      "property_file", "The file containing interpolation tables for material properties.");
  params.addParam<std::string>("field_property_name",
                               "field_solver_interface_property",
                               "Name of the solver interface material property.");
  params.addParam<bool>("use_mean_energy", true, "whether to mean energy or reduce Efield");
  return params;
}

DependentCollisionFreq::DependentCollisionFreq(const InputParameters & parameters)
  : ADMaterial(parameters),

    _use_energy(getParam<bool>("use_mean_energy")),
    _nu_neutral(declareADProperty<Real>("nu_neutral")),
    _grad_nu_neutral(declareADProperty<RealVectorValue>("grad_nu_neutral")),
    _em(adCoupledValue("electrons")),
    _mean_en(adCoupledValue("mean_energy")),
    _grad_em(adCoupledGradient("electrons")),
    _grad_mean_en(adCoupledGradient("mean_energy")),
    _electric_field(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("field_property_name"))),

    _k_boltz(getMaterialProperty<Real>("k_boltz")),
    _T_gas(getMaterialProperty<Real>("T_gas")),
    _p_gas(getMaterialProperty<Real>("p_gas")),
    _pi(libMesh::pi),
    _frequency(getParam<Real>("driving_frequency")),
    _delta(getParam<Real>("delta"))
{
  std::vector<Real> val_x;
  std::vector<Real> nu;
  std::string file_name =
      getParam<std::string>("file_location") + "/" + getParam<FileName>("property_file");
  MooseUtils::checkFileReadable(file_name);
  const char * charPath = file_name.c_str();
  std::ifstream myfile(charPath);
  Real value;

  if (myfile.is_open())
  {
    while (myfile >> value)
    {
      val_x.push_back(value);
      myfile >> value;
      nu.push_back(value);
    }
    myfile.close();
  }
  else
    mooseError("Unable to open file");

  _nu_interpolation = std::make_unique<LinearInterpolation>(val_x, nu, true);
}

void
DependentCollisionFreq::computeQpProperties()
{
  Real _N_gas = _p_gas[_qp] / (_k_boltz[_qp] * _T_gas[_qp]);

  if (_use_energy)
  {
    //_nu_neutral[_qp].value() =
    //    _nu_interpolation->sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas +
    //    (15.39e9 / 20);
    _nu_neutral[_qp].value() =
        _nu_interpolation->sample(std::exp(_mean_en[_qp].value() - _em[_qp].value())) * _N_gas +
        (2 * _pi * _frequency) / _delta;
    ;
    _nu_neutral[_qp].derivatives() =
        _nu_interpolation->sampleDerivative(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
        _N_gas * std::exp(_mean_en[_qp].value() - _em[_qp].value()) *
        (_mean_en[_qp].derivatives() - _em[_qp].derivatives());

    _grad_nu_neutral[_qp] =
        _nu_interpolation->sampleDerivative(std::exp(_mean_en[_qp].value() - _em[_qp].value())) *
        _N_gas * std::exp(_mean_en[_qp] - _em[_qp]) * (_grad_mean_en[_qp] - _grad_em[_qp]);

    // Safeguard agains zero values resulting from extrapolation
    if (_nu_neutral[_qp].value() < 0)
    {
      _nu_neutral[_qp].value() = 0;
      _nu_neutral[_qp].derivatives() = 0;

      _grad_nu_neutral[_qp] = 0;
    }
  }
  else
  {
    Real Td = _N_gas * 1e-21;

    _nu_neutral[_qp] =
        _nu_interpolation->sample(std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                            std::pow(_electric_field[_qp](1).value(), 2) +
                                            std::pow(_electric_field[_qp](2).value(), 2)) /
                                  Td) *
        _N_gas;

    _grad_nu_neutral[_qp] = _nu_interpolation->sampleDerivative(
                                std::sqrt(std::pow(_electric_field[_qp](0).value(), 2) +
                                          std::pow(_electric_field[_qp](1).value(), 2) +
                                          std::pow(_electric_field[_qp](2).value(), 2)) /
                                Td) *
                            _N_gas;
  }
}
