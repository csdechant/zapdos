
#include "FVDiffusionNonLogTest.h"
#include "Assembly.h"

#include "MooseTypes.h"
#include "SubProblem.h"
#include "FEProblem.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerADMooseObject("ZapdosApp", FVDiffusionNonLogTest);

InputParameters
FVDiffusionNonLogTest::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("The drift-diffusion flux using the Scharfetter-Gumme scheme.");
  // params.addRequiredCoupledVar(
  //     "potential", "The gradient of the potential will be used to compute the advection
  //     velocity.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params += Moose::FV::advectedInterpolationParameter();
  return params;
}

FVDiffusionNonLogTest::FVDiffusionNonLogTest(const InputParameters & params)
  : FVFluxKernel(params),
    //_potential_elem(adCoupledValue("potential")),
    //_potential_neighbor(adCoupledNeighborValue("potential")),
    //_mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    //_mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _diff_elem(getADMaterialProperty<Real>("diff" + _var.name())),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diff" + _var.name())),
    //_sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _r_units(1. / getParam<Real>("position_units"))
{
  const bool need_more_ghosting =
      Moose::FV::setInterpolationMethod(*this, _advected_interp_method, "advected_interp_method");
  if (need_more_ghosting && _tid == 0)
  {
    adjustRMGhostLayers(std::max((unsigned short)(2), _pars.get<unsigned short>("ghost_layers")));

    // If we need more ghosting, then we are a second-order nonlinear limiting scheme whose stencil
    // is liable to change upon wind-direction change. Consequently we need to tell our problem that
    // it's ok to have new nonzeros which may crop-up after PETSc has shrunk the matrix memory
    getCheckedPointerParam<FEProblemBase *>("_fe_problem_base")
        ->setErrorOnJacobianNonzeroReallocation(false);
  }
}

ADReal
FVDiffusionNonLogTest::computeQpResidual()
{
  const auto state = determineState();

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  const auto & diff_neighbor = elem_is_interior ? _diff_elem[_qp] : _diff_neighbor[_qp];
  const auto & u_neighbor =
      elem_is_interior ? _var.getBoundaryFaceValue(*_face_info, state, false) : _u_neighbor[_qp];

  ADReal diffusivity;
  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              diff_neighbor,
              *_face_info,
              true);

  return -1.0 * diffusivity * (u_neighbor - _u_elem[_qp]) / _face_info->dCNMag() *
         _face_info->eCN() * _normal;
}
