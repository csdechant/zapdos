//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html


#pragma once

/**
 *  
 */
namespace LTP
{
/// Enum used when determining ...
enum ComponentEnum
{
  MEAN_ENERGY,
  REDUDE_EFIELD
};

/// Enum used when determining ...
enum RelativeEnum
{
  RELATIVE,
  ABSOLUTE
};
} // namespace LTP
