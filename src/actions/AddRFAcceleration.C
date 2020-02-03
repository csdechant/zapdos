#include "AddRFAcceleration.h"
#include "Parser.h"
#include "FEProblem.h"
#include "Factory.h"
#include "MooseEnum.h"
#include "AddVariableAction.h"
#include "Conversion.h"
#include "DirichletBC.h"
#include "ActionFactory.h"
#include "MooseObjectAction.h"
#include "MooseApp.h"
#include "Control.h"
#include "AddControlAction.h"

#include "libmesh/vector_value.h"

#include "pcrecpp.h"

#include <sstream>
#include <stdexcept>

// libmesh includes
#include "libmesh/libmesh.h"
#include "libmesh/exodusII_io.h"
#include "libmesh/equation_systems.h"
#include "libmesh/nonlinear_implicit_system.h"
#include "libmesh/explicit_system.h"
#include "libmesh/string_to_enum.h"
#include "libmesh/fe.h"

registerMooseAction("ZapdosApp", AddRFAcceleration, "add_control");

template <>
InputParameters
validParams<AddRFAcceleration>()
{
  InputParameters params = validParams<AddControlAction>();

  params.addParam<std::vector<std::string>>(
      "multiapp_and_transfers", std::vector<std::string>(), "A list of mulitapp and tranfers objects names");
  params.addParam<Real>("start_time",
      "The time at which to start the acceleration scheme");
  params.addParam<Real>("rf_frequency",
      "The rf frequency in Hz");
  params.addParam<Real>("rf_cycles_per_acceleration",
      "The number of rf cycles between accelerations");
  params.addParam<Real>("accelerations",
      "The number of accelerations");

  params.addClassDescription(
      "This Action automatically adds multiply 'TimePeriod' controllors for the uses of metastable"
      "acceleration");

  return params;
}

AddRFAcceleration::AddRFAcceleration(InputParameters params)
  : AddControlAction(params),
    _multiapp_and_transfers(getParam<std::vector<std::string>>("multiapp_and_transfers")),
    _start_time(getParam<Real>("start_time")),
    _rf_period(1. / getParam<Real>("rf_frequency")),
    _rf_cycles_per_acceleration(getParam<Real>("rf_cycles_per_acceleration")),
    _num_accelerations(getParam<Real>("accelerations"))
{
}

void
AddRFAcceleration::act()
{
  _first_start_time_index.resize(_multiapp_and_transfers.size());
  _first_end_time_index.resize(_multiapp_and_transfers.size());

  _second_start_time_index.resize(_multiapp_and_transfers.size());
  _second_end_time_index.resize(_multiapp_and_transfers.size());

  if (_current_task == "add_control")
  {
    for (unsigned int i = 0; i < _num_accelerations; ++i)
    {

      for (MooseIndex(_multiapp_and_transfers) j = 0; j < _multiapp_and_transfers.size(); ++j)
      {
        _first_start_time_index[j] = _start_time + _rf_cycles_per_acceleration * _rf_period * i;
        _first_end_time_index[j] = _start_time + _rf_cycles_per_acceleration * _rf_period * i + 1e-11;

        _second_start_time_index[j] = _start_time + 0.5 * _rf_period + _rf_cycles_per_acceleration * _rf_period * i;
        _second_end_time_index[j] = _start_time + 0.5 * _rf_period + _rf_cycles_per_acceleration * _rf_period * i + 1e-11;
      }

      if (i == 0)
      {
        InputParameters params = _factory.getValidParams("TimePeriod");
        params.set<std::vector<std::string>>("enable_objects") = _multiapp_and_transfers;
        params.set<std::vector<Real>>("start_time") = _first_start_time_index;
        params.set<std::vector<Real>>("end_time") = _first_end_time_index;
        params.set<ExecFlagEnum>("execute_on", true) = {EXEC_INITIAL, EXEC_TIMESTEP_BEGIN};
        params.set<bool>("reverse_on_false") = true;
        params.set<bool>("set_sync_times") = true;
        std::shared_ptr<Control> control = _factory.create<Control>("TimePeriod",
                                                                    "Acceleration_"+std::to_string(i)+"_F", params);
        _problem->getControlWarehouse().addObject(control);
      }
      else
      {
        InputParameters params = _factory.getValidParams("TimePeriod");
        params.set<std::vector<std::string>>("enable_objects") = _multiapp_and_transfers;
        params.set<std::vector<Real>>("start_time") = _first_start_time_index;
        params.set<std::vector<Real>>("end_time") = _first_end_time_index;
        params.set<ExecFlagEnum>("execute_on", true) = {EXEC_INITIAL, EXEC_TIMESTEP_BEGIN};
        params.set<bool>("reverse_on_false") = false;
        params.set<bool>("set_sync_times") = true;
        std::shared_ptr<Control> control = _factory.create<Control>("TimePeriod",
                                                                    "Acceleration_"+std::to_string(i)+"_F", params);
        _problem->getControlWarehouse().addObject(control);
      }
      InputParameters params = _factory.getValidParams("TimePeriod");
      params.set<std::vector<std::string>>("enable_objects") = _multiapp_and_transfers;
      params.set<std::vector<Real>>("start_time") = _second_start_time_index;
      params.set<std::vector<Real>>("end_time") = _second_end_time_index;
      params.set<ExecFlagEnum>("execute_on", true) = {EXEC_INITIAL, EXEC_TIMESTEP_BEGIN};
      params.set<bool>("reverse_on_false") = false;
      params.set<bool>("set_sync_times") = true;
      std::shared_ptr<Control> control = _factory.create<Control>("TimePeriod",
                                                                  "Acceleration_"+std::to_string(i)+"_S", params);
      _problem->getControlWarehouse().addObject(control);
    }
  }

}
