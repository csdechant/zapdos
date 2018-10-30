/****************************************************************/
/*                      DO NOT MODIFY THIS HEADER               */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*              (c) 2010 Battelle Energy Alliance, LLC          */
/*                      ALL RIGHTS RESERVED                     */
/*                                                              */
/*              Prepared by Battelle Energy Alliance, LLC       */
/*              Under Contract No. DE-AC07-05ID14517            */
/*              With the U. S. Department of Energy             */
/*                                                              */
/*              See COPYRIGHT for full restrictions             */
/****************************************************************/
#ifndef REACTIONNETWORK_H_
#define REACTIONNETWORK_H_

#include "Material.h"
/* #include "LinearInterpolation.h" */
#include "SplineInterpolation.h"

class ReactionNetwork;

template <>
InputParameters validParams<ReactionNetwork>();

class ReactionNetwork : public Material
{
public:
  ReactionNetwork(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  std::string _potential_units;
  Real _voltage_scaling;
  Real _r_units;
  const MaterialProperty<Real> & _Tem;
  const MaterialProperty<Real> & _TemVolts;
  const MaterialProperty<Real> & _T_gas;
  const MaterialProperty<Real> & _p_gas;
  const MaterialProperty<Real> & _n_gas;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _N_A;
  // const MaterialProperty<Real> & _reaction_rate;

  // MaterialProperty<Real> & _townsend_rate;
  // const MaterialProperty<Real> & _k_exiz;
  const MaterialProperty<Real> & _alpha_ex;
  // MaterialProperty<Real> & _k_Ar_Arp;
  // MaterialProperty<Real> & _k_Ar_Ar4s;
  // MaterialProperty<Real> & _k_Ar4s_Ar;
  // MaterialProperty<Real> & _k_Ar4s_Arp;
  // MaterialProperty<Real> & _k_Ar4s_Ar4p;
  // MaterialProperty<Real> & _k_Ar_Ar4p;
  // MaterialProperty<Real> & _k_Ar4p_Arp;
  // MaterialProperty<Real> & _k_Ar_ArEx;
  // MaterialProperty<Real> & _EFieldGas;
  // MaterialProperty<Real> & _Eexiz;


  // MaterialProperty<Real> & _alpha_Ar_Arp;
  // MaterialProperty<Real> & _alpha_Ar_Ar4s;
  // MaterialProperty<Real> & _alpha_Ar_Ar4p;
  // MaterialProperty<Real> & _alpha_exiz;
  MaterialProperty<Real> & _alpha_dex;

  unsigned int _potential_id;
  const VariableValue & _density;
  const VariableGradient & _grad_potential;
  const VariableValue & _test_value;



  // MaterialProperty<Real> & _T_gas;
  // MaterialProperty<Real> & _p_gas;  // Replace with gas fraction?
  // MaterialProperty<Real> & _n_gas;





};

#endif // REACTIONNETWORK_H_
