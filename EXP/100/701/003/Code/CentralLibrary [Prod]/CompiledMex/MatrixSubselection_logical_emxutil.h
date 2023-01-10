/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * MatrixSubselection_logical_emxutil.h
 *
 * Code generation for function 'MatrixSubselection_logical_emxutil'
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
CODEGEN_EXPORT_SYM void emxEnsureCapacity_boolean_T(emxArray_boolean_T *emxArray,
  int32_T oldNumel);
CODEGEN_EXPORT_SYM void emxFree_boolean_T(emxArray_boolean_T **pEmxArray);
CODEGEN_EXPORT_SYM void emxInit_boolean_T(emxArray_boolean_T **pEmxArray,
  int32_T numDimensions, boolean_T doPush);

/* End of code generation (MatrixSubselection_logical_emxutil.h) */
