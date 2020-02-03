#ifndef AddRFAcceleration_H
#define AddRFAcceleration_H

#include "AddVariableAction.h"
#include "Action.h"
#include "AddControlAction.h"
#include "Control.h"

class AddRFAcceleration;

template <>
InputParameters validParams<AddRFAcceleration>();

class AddRFAcceleration : public AddControlAction
{
public:
  AddRFAcceleration(InputParameters params);

  virtual void act();

protected:

  std::vector<std::string> _multiapp_and_transfers;
  Real _start_time;
  Real _rf_period;
  Real _rf_cycles_per_acceleration;
  Real _num_accelerations;

  std::vector<Real> _first_start_time_index;
  std::vector<Real> _first_end_time_index;
  std::vector<Real> _second_start_time_index;
  std::vector<Real> _second_end_time_index;


};

#endif // AddRFAcceleration_H
