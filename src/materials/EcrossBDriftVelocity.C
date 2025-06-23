
#include "EcrossBDriftVelocity.h"

registerMooseObject("ZapdosApp", EcrossBDriftVelocity);

InputParameters
EcrossBDriftVelocity::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addParam<std::string>("magnetic_unit_vector_name",
                               "magnetic_unit_vector",
                               "Name of the magnetic unit vector as a material property.");
  params.addParam<std::string>("electric_field_name",
                               "field_solver_interface_property",
                               "Name of the electric field as a material property.");
  params.addClassDescription("Supplies the $ \vec{E} \times \vec{B} $ drift velocity");
  return params;
}

EcrossBDriftVelocity::EcrossBDriftVelocity(const InputParameters & parameters)
  : Material(parameters),
    _magnetic_unit_vector(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("magnetic_unit_vector_name"))),
    _curl_magnetic_unit_vector(getADMaterialProperty<RealVectorValue>(
        "curl_" + getParam<std::string>("magnetic_unit_vector_name"))),

    _mag_magnetic_field(getADMaterialProperty<Real>("mag_magnetic_field")),
    _grad_mag_magnetic_field(getADMaterialProperty<RealVectorValue>("grad_mag_magnetic_field")),

    _electric_field(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("electric_field_name"))),
    _curl_electric_field(getADMaterialProperty<RealVectorValue>(
        "curl_" + getParam<std::string>("electric_field_name"))),

    _E_cross_B_drift(declareADProperty<RealVectorValue>("E_cross_B_drift")),
    _div_E_cross_B_drift(declareADProperty<Real>("div_E_cross_B_drift"))
{
}

void
EcrossBDriftVelocity::computeQpProperties()
{
  _E_cross_B_drift[_qp] =
      _electric_field[_qp].cross(_magnetic_unit_vector[_qp]) / _mag_magnetic_field[_qp];

  _div_E_cross_B_drift[_qp] = (_magnetic_unit_vector[_qp] * _curl_electric_field[_qp] -
                               _electric_field[_qp] * _curl_magnetic_unit_vector[_qp]) /
                                  _mag_magnetic_field[_qp] -
                              _grad_mag_magnetic_field[_qp] *
                                  _electric_field[_qp].cross(_magnetic_unit_vector[_qp]) /
                                  (_mag_magnetic_field[_qp] * _mag_magnetic_field[_qp]);
}
