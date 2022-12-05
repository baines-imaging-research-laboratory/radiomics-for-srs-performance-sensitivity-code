/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * MatrixSubselection_logical.h
 *
 * Code generation for function 'MatrixSubselection_logical'
 *
 */

#pragma once

/* Include files */
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "MatrixSubselection_logical_types.h"

/* Function Declarations */
CODEGEN_EXPORT_SYM void MatrixSubselection_logical(const emxArray_boolean_T
  *m3bMatrix, const real_T vdRowBounds[2], const real_T vdColBounds[2], const
  real_T vdSliceBounds[2], emxArray_boolean_T *m3bSubMatrix);

/* End of code generation (MatrixSubselection_logical.h) */
