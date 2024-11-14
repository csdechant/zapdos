
#include "FVEFieldAdvectionNonLog.h"
#include "Assembly.h"

#include "MooseTypes.h"
#include "SubProblem.h"
#include "FEProblem.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerADMooseObject("ZapdosApp", FVEFieldAdvectionNonLog);

InputParameters
FVEFieldAdvectionNonLog::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription(
      "Generic electric field driven advection term using finite volume method.");
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params += Moose::FV::advectedInterpolationParameter();
  return params;
}

FVEFieldAdvectionNonLog::FVEFieldAdvectionNonLog(const InputParameters & params)
  : FVFluxKernel(params),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
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
FVEFieldAdvectionNonLog::computeQpResidual()
{
  using namespace Moose::FV;
  const auto state = determineState();

  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info, state);

  const bool elem_is_upwind = -1.0 * grad_potential * _normal >= 0;
  const auto face =
      makeFace(*_face_info, Moose::FV::limiterType(_advected_interp_method), elem_is_upwind);
  ADReal u_interface = _var(face, determineState());

  ADReal mobility;

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  const auto & mu_neighbor = elem_is_interior ? _mu_elem[_qp] : _mu_neighbor[_qp];

  interpolate(
      Moose::FV::InterpMethod::Average, mobility, _mu_elem[_qp], mu_neighbor, *_face_info, true);

  return _sign[_qp] * mobility * -1.0 * grad_potential * _r_units * _normal * u_interface;
}
