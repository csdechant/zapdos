#include "MagneticParallelVelocity.h"

registerMooseObject("ZapdosApp", MagneticParallelVelocity);

InputParameters
MagneticParallelVelocity::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Supplies the vector form of the magnetic parallel velocity.");
  params.addCoupledVar("magnetic_field",
                       "Magnetic field variable provided by electromagnetic solver.");
  params.addCoupledVar("scalar_parallel_vel", "The scalar form of the magnetic parallel velocity.");
  params.addParam<bool>("convert_unit_vector",
                        true,
                        "Convert the magnetic field into a unit vector (default = true)");
  return params;
}

MagneticParallelVelocity::MagneticParallelVelocity(const InputParameters & parameters)
  : Material(parameters),
    _magnetic_field(adCoupledVectorValue("magnetic_field")),
    _grad_magnetic_field(adCoupledVectorGradient("magnetic_field")),
    _scalar_parallel_vec(adCoupledValue("scalar_parallel_vel")),
    _grad_scalar_vec(adCoupledGradient("scalar_parallel_vel")),
    _use_unit_vector(getParam<bool>("convert_unit_vector")),
    _parallel_velocity(declareADProperty<RealVectorValue>("parallel_velocity")),
    _div_parallel_velocity(declareADProperty<Real>("div_parallel_velocity"))
{
}

void
MagneticParallelVelocity::computeQpProperties()
{
  Real per_unit = 1.0;
  if (_use_unit_vector)
    per_unit = 1.0 / raw_value((_magnetic_field[_qp]).norm());

  _parallel_velocity[_qp] = per_unit * _magnetic_field[_qp] * _scalar_parallel_vec[_qp];

  /*
   *  NOTE: For NEDELEC_ONE variable family types, the _grad_magnetic_field[_qp].tr() returns
   *        zeros due to libMesh not computing the gradients nor divergences of the shape function
   *        for HCurl elements (see warnings in libMesh file hcurl_fe_transformation.h).
   * 
   *        This is sufficient for now, as the divergences of the magnetic field should be
   *        zero (as defined by Gauss's law for magnetism), but this should noted.
   */

  _div_parallel_velocity[_qp] =
      per_unit * (_scalar_parallel_vec[_qp] * _grad_magnetic_field[_qp].tr() +
                  _magnetic_field[_qp] * _grad_scalar_vec[_qp]);
}
