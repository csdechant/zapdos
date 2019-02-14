#ifndef PROCRATEWITHRATECOEFF_H
#define PROCRATEWITHRATECOEFF_H

#include "AuxKernel.h"

class ProcRateWithRateCoeff;

template <>
InputParameters validParams<ProcRateWithRateCoeff>();

class ProcRateWithRateCoeff : public AuxKernel
{
public:
  ProcRateWithRateCoeff(const InputParameters & parameters);

  virtual ~ProcRateWithRateCoeff() {}
  virtual Real computeValue();

protected:
  const VariableValue & _v;
  const VariableValue & _w;
  unsigned int _v_id;
  unsigned int _w_id;
  const MaterialProperty<Real> & _n_gas;

  const MaterialProperty<Real> & _reaction_coeff;
  Real _stoichiometric_coeff;
  bool _v_eq_u;
  bool _w_eq_u;
  bool _v_coupled;
  bool _w_coupled;
};

#endif // ProcRateWithRateCoeff_H
