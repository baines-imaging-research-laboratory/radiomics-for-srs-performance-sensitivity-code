/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * MatrixSubselection_logical_terminate.cpp
 *
 * Code generation for function 'MatrixSubselection_logical_terminate'
 *
 */

/* Include files */
#include "MatrixSubselection_logical_terminate.h"
#include "MatrixSubselection_logical.h"
#include "MatrixSubselection_logical_data.h"
#include "_coder_MatrixSubselection_logical_mex.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void MatrixSubselection_logical_atexit()
{
  mexFunctionCreateRootTLS();
  emlrtEnterRtStackR2012b(emlrtRootTLSGlobal);
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void MatrixSubselection_logical_terminate()
{
  emlrtLeaveRtStackR2012b(emlrtRootTLSGlobal);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (MatrixSubselection_logical_terminate.cpp) */
