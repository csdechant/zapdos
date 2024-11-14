
#include "FVCoeffDiffusion.h"

registerMooseObject("ZapdosApp", FVCoeffDiffusion);

InputParameters
FVCoeffDiffusion::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic diffusion term for finite volume method.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.set<unsigned short>("ghost_layers") = 2;
  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  params.set<unsigned short>("ghost_layers") = 2;
  return params;
}

FVCoeffDiffusion::FVCoeffDiffusion(const InputParameters & params)
  : FVFluxKernel(params),
    _diff_elem(getADMaterialProperty<Real>("diff" + _var.name())),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diff" + _var.name())),
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
FVCoeffDiffusion::computeQpResidual()
{
  using namespace Moose::FV;
  const auto state = determineState();

  auto dudn = gradUDotNormal(state);

  const auto face = makeFace(*_face_info, Moose::FV::limiterType(_advected_interp_method), false);
  ADReal u_face = _var(face, determineState());

  ADReal diffusivity;

  const bool elem_is_interior =
      _face_info->faceType(std::make_pair(_var.number(), _var.sys().number())) ==
      FaceInfo::VarFaceNeighbors::ELEM;

  const auto & diff_neighbor = elem_is_interior ? _diff_elem[_qp] : _diff_neighbor[_qp];

  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              diff_neighbor,
              *_face_info,
              true);

  return -1.0 * diffusivity * std::exp(u_face) * dudn * _r_units;
}
