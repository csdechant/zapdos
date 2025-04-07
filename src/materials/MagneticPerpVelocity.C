#include "MagneticPerpVelocity.h"

registerMooseObject("ZapdosApp", MagneticPerpVelocity);

InputParameters
MagneticPerpVelocity::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Supplies the components of the magnetic perpendicular (Currently "
                             "just $ \vec{E} \times \vec{B} $ drift)");
  params.addRequiredCoupledVar("magnetic_field",
                               "Magnetic field variable provided by electromagnetic solver.");
  params.addParam<std::string>("field_property_name",
                               "field_solver_interface_property",
                               "Name of the solver interface material property.");
  return params;
}

MagneticPerpVelocity::MagneticPerpVelocity(const InputParameters & parameters)
  : Material(parameters),
    _magnetic_field(adCoupledVectorValue("magnetic_field")),
    _curl_magnetic_field(adCoupledCurl("magnetic_field")),
    _electric_field(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("field_property_name"))),
    _curl_electric_field(getADMaterialProperty<RealVectorValue>(
        getParam<std::string>("field_property_name") + "_curl")),
    _E_cross_drift(declareADProperty<RealVectorValue>("E_cross_drift")),
    _div_E_cross_drift(declareADProperty<Real>("div_E_cross_drift"))

{
}

void
MagneticPerpVelocity::computeQpProperties()
{
  Real B_mag = raw_value((_magnetic_field[_qp]).norm());

  _E_cross_drift[_qp] = _electric_field[_qp].cross(_magnetic_field[_qp]) / (B_mag * B_mag);

  /**
   *  NOTE: The divergence of a cross product,
   *        such that (\nabla \cdot [\vec{A} \times \vec{B}]), is:
   *
   *        \vec{B} \cdot (\nabla \times \vec{A}) - \vec{A} \cdot (\nabla \times \vec{B})
   *
   */
  _div_E_cross_drift[_qp] = (_magnetic_field[_qp] * _curl_electric_field[_qp] -
                             _electric_field[_qp] * _curl_magnetic_field[_qp]) /
                            (B_mag * B_mag);
}
