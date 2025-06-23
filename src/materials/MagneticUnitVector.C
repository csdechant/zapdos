#include "MagneticUnitVector.h"

registerMooseObject("ZapdosApp", MagneticUnitVector);

InputParameters
MagneticUnitVector::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addCoupledVar("magnetic_field", "Magnetic field variable.");
  params.addClassDescription(
      "Supplies the magnetic unit vector and the gradient of the magnitude of the magnetic field.");
  return params;
}

MagneticUnitVector::MagneticUnitVector(const InputParameters & parameters)
  : Material(parameters),
    _magnetic_field(adCoupledVectorValue("magnetic_field")),
    _grad_magnetic_field(adCoupledVectorGradient("magnetic_field")),
    _curl_magnetic_field(adCoupledCurl("magnetic_field")),

    _mag_magnetic_field(declareADProperty<Real>("mag_magnetic_field")),
    _grad_mag_magnetic_field(declareADProperty<RealVectorValue>("grad_mag_magnetic_field")),

    _magnetic_unit_vector(declareADProperty<RealVectorValue>("magnetic_unit_vector")),
    _div_magnetic_unit_vector(declareADProperty<Real>("div_magnetic_unit_vector")),
    _curl_magnetic_unit_vector(declareADProperty<RealVectorValue>("curl_magnetic_unit_vector"))
{
  /*
   *  NOTE: For NEDELEC_ONE and RAVIART_THOMAS variable family types, libMesh not computing
   *        the gradients nor divergences of the shape function for HCurl and HDiv elements
   *        (see warnings in libMesh files hcurl_fe_transformation.h and hdiv_fe_transformation.h).
   */
  const auto type = (*getVectorVar("magnetic_field", 0)).feType();
  if ((type.family == libMesh::NEDELEC_ONE) || (type.family == libMesh::RAVIART_THOMAS) ||
      (type.family == libMesh::L2_RAVIART_THOMAS))
    paramError("magnetic_field",
               "The gradient values of the variable family " + Moose::stringify(type.family) +
                   " are not computed within libMesh.");
}

void
MagneticUnitVector::computeQpProperties()
{
  _mag_magnetic_field[_qp] = _magnetic_field[_qp].norm();

  _magnetic_unit_vector[_qp] = _magnetic_field[_qp] / _mag_magnetic_field[_qp];

  _grad_mag_magnetic_field[_qp] = (_magnetic_field[_qp](0) * _grad_magnetic_field[_qp].row(0) +
                                   _magnetic_field[_qp](1) * _grad_magnetic_field[_qp].row(1) +
                                   _magnetic_field[_qp](2) * _grad_magnetic_field[_qp].row(2)) /
                                  _mag_magnetic_field[_qp];

  _div_magnetic_unit_vector[_qp] = _grad_magnetic_field[_qp].tr() / _mag_magnetic_field[_qp] -
                                   _magnetic_field[_qp] * _grad_mag_magnetic_field[_qp] /
                                       (_mag_magnetic_field[_qp] * _mag_magnetic_field[_qp]);

  _curl_magnetic_unit_vector[_qp] = _curl_magnetic_field[_qp] / _mag_magnetic_field[_qp] -
                                    _grad_mag_magnetic_field[_qp].cross(_magnetic_field[_qp]) /
                                        (_mag_magnetic_field[_qp] * _mag_magnetic_field[_qp]);
}
