/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * MatrixSubselection_logical_initialize.cpp
 *
 * Code generation for function 'MatrixSubselection_logical_initialize'
 *
 */

/* Include files */
#include "MatrixSubselection_logical_initialize.h"
#include "MatrixSubselection_logical.h"
#include "MatrixSubselection_logical_data.h"
#include "_coder_MatrixSubselection_logical_mex.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void MatrixSubselection_logical_initialize()
{
  mex_InitInfAndNan();
  mexFunctionCreateRootTLS();
  emlrtClearAllocCountR2012b(emlrtRootTLSGlobal, false, 0U, 0);
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (MatrixSubselection_logical_initialize.cpp) */
