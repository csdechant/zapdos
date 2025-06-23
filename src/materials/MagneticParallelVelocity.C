
#include "MagneticParallelVelocity.h"

registerMooseObject("ZapdosApp", MagneticParallelVelocity);

InputParameters
MagneticParallelVelocity::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addCoupledVar("scalar_parallel_vel", "The scalar form of the magnetic parallel velocity.");
  params.addParam<std::string>("magnetic_unit_vector_name",
                               "magnetic_unit_vector",
                               "Name of the magnetic unit vector as a material property.");
  params.addClassDescription("Supplies the vector form of the magnetic parallel velocity.");
  return params;
}

MagneticParallelVelocity::MagneticParallelVelocity(const InputParameters & parameters)
  : Material(parameters),
    _scalar_parallel_vec(adCoupledValue("scalar_parallel_vel")),
    _grad_scalar_vec(adCoupledGradient("scalar_parallel_vel")),

    _magnetic_unit_vector(
        getADMaterialProperty<RealVectorValue>(getParam<std::string>("magnetic_unit_vector_name"))),
    _div_magnetic_unit_vector(
        getADMaterialProperty<Real>("div_" + getParam<std::string>("magnetic_unit_vector_name"))),

    _parallel_velocity(declareADProperty<RealVectorValue>("parallel_velocity")),
    _div_parallel_velocity(declareADProperty<Real>("div_parallel_velocity"))
{
}

void
MagneticParallelVelocity::computeQpProperties()
{

  _parallel_velocity[_qp] = _magnetic_unit_vector[_qp] * _scalar_parallel_vec[_qp];

  _div_parallel_velocity[_qp] = _scalar_parallel_vec[_qp] * _div_magnetic_unit_vector[_qp] +
                                _magnetic_unit_vector[_qp] * _grad_scalar_vec[_qp];
}
