#include "MagneticPerpVelocity.h"

registerMooseObject("ZapdosApp", MagneticPerpVelocity);

InputParameters
MagneticPerpVelocity::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Supplies the components of the magnetic perpendicular (Currently "
                             "just $ \vec{E} \times \vec{B} $ drift)");
  params.addCoupledVar("magnetic_field",
                       "Magnetic field variable provided by electromagnetic solver.");
  params.addParam<std::string>("field_property_name",
                               "field_solver_interface_property",
                               "Name of the solver interface material property.");
  return params;
}

MagneticPerpVelocity::MagneticPerpVelocity(const InputParameters & parameters)
  : Material(parameters),
    _magnetic_field(isCoupled("magnetic_field") ? adCoupledVectorValue("magnetic_field")
                                                : _ad_grad_zero),
    _electric_field(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("field_property_name"))),
    _E_cross_drift(declareADProperty<RealVectorValue>("E_cross_drift")),
    _div_E_cross_drift(declareADProperty<Real>("div_E_cross_drift"))

{
}

void
MagneticPerpVelocity::computeQpProperties()
{
  Real B_mag = raw_value((_magnetic_field[_qp]).norm());
  _E_cross_drift[_qp] = _electric_field[_qp].cross(_magnetic_field[_qp]) / (B_mag * B_mag);

  
  _div_E_cross_drift[_qp] 
}
