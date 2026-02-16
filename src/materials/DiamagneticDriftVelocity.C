
#include "DiamagneticDriftVelocity.h"

registerMooseObject("ZapdosApp", DiamagneticDriftVelocity);

InputParameters
DiamagneticDriftVelocity::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addParam<std::string>("magnetic_unit_vector_name",
                               "magnetic_unit_vector",
                               "Name of the magnetic unit vector as a material property.");
  params.addRequiredCoupledVar("density", "The logarithmic density of the charged fluid species.");
  params.addRequiredCoupledVar("pressure", "The pressure of the charged fluid species.");
  params.addClassDescription(
      "Supplies the diamagnetic drift (i.e., $ \vec{B} \times \nabla p $ drift) velocity");
  return params;
}

DiamagneticDriftVelocity::DiamagneticDriftVelocity(const InputParameters & parameters)
  : Material(parameters),
    _magnetic_unit_vector(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("magnetic_unit_vector_name"))),
    _curl_magnetic_unit_vector(getADMaterialProperty<RealVectorValue>(
        "curl_" + getParam<std::string>("magnetic_unit_vector_name"))),

    _mag_magnetic_field(getADMaterialProperty<Real>("mag_magnetic_field")),
    _grad_mag_magnetic_field(getADMaterialProperty<RealVectorValue>("grad_mag_magnetic_field")),

    _density(adCoupledValue("density")),
    _grad_density(adCoupledGradient("density")),

    _e(getMaterialProperty<Real>("e")),
    _sgn(getMaterialProperty<Real>("sgn" + (*getVar("density", 0)).name())),
    // Note: Currently just coupling pressure directly
    //       Might want to add an option for coupling temperature and calculate the pressure
    _grad_pressure(adCoupledGradient("pressure")),

    _diamagnetic_drift(declareADProperty<RealVectorValue>("diamagnetic_drift")),
    _div_diamagnetic_drift(declareADProperty<Real>("div_diamagnetic_drift"))
{
}

void
DiamagneticDriftVelocity::computeQpProperties()
{
  _diamagnetic_drift[_qp] = _magnetic_unit_vector[_qp].cross(_grad_pressure[_qp]) /
                            (_sgn[_qp] * _e[_qp] * exp(_density[_qp]) * _mag_magnetic_field[_qp]);

  _div_diamagnetic_drift[_qp] =
      -(_grad_density[_qp] * exp(_density[_qp]) /
            (exp(_density[_qp]) * exp(_density[_qp]) * _mag_magnetic_field[_qp]) +
        _grad_mag_magnetic_field[_qp] /
            (exp(_density[_qp]) * _mag_magnetic_field[_qp] * _mag_magnetic_field[_qp])) /
          (_sgn[_qp] * _e[_qp]) * _magnetic_unit_vector[_qp].cross(_grad_pressure[_qp]) +
      _grad_pressure[_qp] * _curl_magnetic_unit_vector[_qp] /
          (_sgn[_qp] * _e[_qp] * exp(_density[_qp]) * _mag_magnetic_field[_qp]);
}
