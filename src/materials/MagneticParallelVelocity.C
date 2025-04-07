#include "MagneticParallelVelocity.h"
#include "InputParameters.h"
#include "NonlinearSystemBase.h"
#include "FEProblemBase.h"
#include "MaterialProperty.h"
#include "MooseArray.h"
#include "Assembly.h"
#include "MooseVariableFE.h"
#include "MooseMesh.h"

#include "libmesh/elem.h"
#include "libmesh/node.h"
#include "libmesh/fe_type.h"

registerMooseObject("ZapdosApp", MagneticParallelVelocity);

InputParameters
MagneticParallelVelocity::validParams()
{
  InputParameters params = ADMaterial::validParams();
  params.addClassDescription("Supplies the vector form of the magnetic parallel velocity.");
  params.addCoupledVar("magnetic_field",
                       "Magnetic field variable provided by electromagnetic solver.");
  params.addCoupledVar("magnetic_field_mag",
                       "The magnitude of the magnetic field variable (Needs to be provided as a "
                       "variable since the gradient of the magnitude is needed).");
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
    _magnetic_field_magnitude(adCoupledValue("magnetic_field_mag")),
    _grad_magnetic_field_magnitude(adCoupledGradient("magnetic_field_mag")),
    _scalar_parallel_vec(adCoupledValue("scalar_parallel_vel")),
    _grad_scalar_vec(adCoupledGradient("scalar_parallel_vel")),
    _use_unit_vector(getParam<bool>("convert_unit_vector")),
    _parallel_velocity(declareADProperty<RealVectorValue>("parallel_velocity")),
    _div_parallel_velocity(declareADProperty<Real>("div_parallel_velocity")),
    _velocity_var(getVectorVar("magnetic_field", 0)),
    _scalar_lagrange_fe(
        _assembly.getFE(FEType(_velocity_var->feType().order, LAGRANGE), _mesh.dimension()))
// grad_mag(0, 0, 0)
{
  _scalar_lagrange_fe->get_phi();
  _scalar_lagrange_fe->get_dphi();
}

/*
void
MagneticParallelVelocity::computeProperties()
{
  const auto & vel_dof_indices = _velocity_var->dofIndices();
  vec_test.resize(_qrule->n_points());

  // std::cout << Moose::stringify(_qrule->n_points());
  // std::cout << '\n';
  // std::cout << Moose::stringify(_velocity_var->dofIndices());
  // std::cout << '\n';
  // std::cout << Moose::stringify(vel_dof_indices);
  // std::cout << '\n';
  // std::cout << Moose::stringify(vel_dof_indices);
  // std::cout << '\n';

  for (const auto qp : make_range((_qrule->n_points())))
    vec_test[qp] = 0.;

  for (const auto i : index_range(vel_dof_indices))
  {
    // This may not work if the element and spatial dimensions are different
    mooseAssert(_current_elem->dim() == _mesh.dimension(),
                "Below logic only applicable if element and mesh dimension are the same");

    auto dimensional_component = i % _mesh.dimension();
    const auto dof_index = vel_dof_indices[i];
    ADReal dof_value = (*_velocity_var->sys().currentSolution())(dof_index);
    dof_value.derivatives().insert(dof_index) = 1;
    const auto scalar_i_component = i / _mesh.dimension();
    // const auto scalar_i_component_correction = i / _mesh.dimension();

    // std::cout << "i = ";
    // std::cout << Moose::stringify(i);
    // std::cout << '\n';
    // std::cout << "scalar_i_component = ";
    // std::cout << Moose::stringify(scalar_i_component);
    // std::cout << '\n';
    // std::cout << "dimensional_component = ";
    // std::cout << Moose::stringify(dimensional_component);
    // std::cout << '\n';
    // std::cout << "dof_value = ";
    // std::cout << Moose::stringify(raw_value(dof_value));
    // std::cout << '\n';

    for (const auto qp : make_range(_qrule->n_points()))
    {
      // vec_test[qp](dimensional_component) +=
      //    dof_value * _scalar_lagrange_fe->get_phi()[scalar_i_component][qp];
      vec_test[qp](dimensional_component) +=
         dof_value;
      vec_test[qp](dimensional_component) +=
         dof_value;
      vec_test[qp](dimensional_component) +=
         dof_value;
    }
  }

  for (const auto qp : make_range(_qrule->n_points()))
  {
    std::cout << "qp data =";
    std::cout << raw_value(_magnetic_field[qp]);
    std::cout << '\n';
  }
  std::cout << "New line";
  std::cout << '\n';
  // mooseError("Stop!");

  Material::computeProperties();
}
*/

void
MagneticParallelVelocity::computeQpProperties()
{
  ADReal magnitude =
      std::sqrt((_magnetic_field[_qp](0) * _magnetic_field[_qp](0)) + (_magnetic_field[_qp](1) * _magnetic_field[_qp](1)) +
                (_magnetic_field[_qp](2) * _magnetic_field[_qp](2)));

  _parallel_velocity[_qp] = _magnetic_field[_qp] * _scalar_parallel_vec[_qp] / magnitude;
  // _parallel_velocity[_qp] = vec_test[_qp];

  /*
   *  NOTE: For NEDELEC_ONE variable family types, the _grad_magnetic_field[_qp].tr() returns
   *        zeros due to libMesh not computing the gradients nor divergences of the shape
   *        function for HCurl elements (see warnings in libMesh file hcurl_fe_transformation.h).
   *
   *        While this is sufficient for the divergences of the magnetic field, since the
   *        divergences of the magnetic field should be zero (as defined by Gauss's law for
   *        magnetism), this does pose a problem when calculating the divergences of the unit vector
   *        of the magnetic field if casting the unit vector as a NEDELEC_ONE variable. This is
   *        because Gauss's law only ensures the magnetic field divergences is zero, not necessarily
   *        that the divergences of the unit vector of the magnetic field is zero.
   *
   *
   */

  
  _div_parallel_velocity[_qp] =
      (_scalar_parallel_vec[_qp] * _grad_magnetic_field[_qp].tr() +
       _magnetic_field[_qp] * _grad_scalar_vec[_qp]) /
          _magnetic_field_magnitude[_qp] +
      _magnetic_field[_qp] * _scalar_parallel_vec[_qp] * -_grad_magnetic_field_magnitude[_qp] /
          (_magnetic_field_magnitude[_qp] * _magnetic_field_magnitude[_qp]);
  
  // _div_parallel_velocity[_qp] = 0.0;
}
