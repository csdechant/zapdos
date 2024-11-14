
#include "FVSGFlux.h"
#include "Assembly.h"

#include "MooseTypes.h"
#include "SubProblem.h"
#include "FEProblem.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerADMooseObject("ZapdosApp", FVSGFlux);

InputParameters
FVSGFlux::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("The drift-diffusion flux using the Scharfetter-Gumme scheme.");
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params += Moose::FV::advectedInterpolationParameter();
  return params;
}

FVSGFlux::FVSGFlux(const InputParameters & params)
  : FVFluxKernel(params),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _diff_elem(getADMaterialProperty<Real>("diff" + _var.name())),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diff" + _var.name())),
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
FVSGFlux::computeQpResidual()
{
  using namespace Moose::FV;
  const auto state = determineState();

  ADRealVectorValue Efield = -1.0 * adCoupledGradientFace("potential", *_face_info, state);

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  ADReal mobility;
  const auto & mu_neighbor = elem_is_interior ? _mu_elem[_qp] : _mu_neighbor[_qp];
  interpolate(
      Moose::FV::InterpMethod::Average, mobility, _mu_elem[_qp], mu_neighbor, *_face_info, true);

  ADReal diffusivity;
  const auto & diff_neighbor = elem_is_interior ? _diff_elem[_qp] : _diff_neighbor[_qp];
  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              diff_neighbor,
              *_face_info,
              true);

  const auto & u_neighbor =
      elem_is_interior ? _var.getBoundaryFaceValue(*_face_info, state, false) : _u_neighbor[_qp];

  const auto delta = elem_is_interior
                         ? (_face_info->faceCentroid() - _face_info->elemCentroid()).norm()
                         : _face_info->dCNMag();

  ADReal alpha = -1.0 * _sign[_qp] * mobility * delta * Efield * _normal / diffusivity;

  ADReal SGFlux = diffusivity * (std::exp(_u_elem[_qp]) - std::exp(alpha) * std::exp(u_neighbor)) *
                  alpha / ((std::exp(alpha) - 1) * delta) * _face_info->eCN() * _normal;

  if (std::isnan(SGFlux))
  {
    return -1.0 * diffusivity * (std::exp(u_neighbor) - std::exp(_u_elem[_qp])) / delta *
           _face_info->eCN() * _normal;
  }

  return SGFlux;
}
