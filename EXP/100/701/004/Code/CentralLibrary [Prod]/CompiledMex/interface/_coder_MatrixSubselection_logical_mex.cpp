/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_MatrixSubselection_logical_mex.cpp
 *
 * Code generation for function '_coder_MatrixSubselection_logical_mex'
 *
 */

/* Include files */
#include "_coder_MatrixSubselection_logical_mex.h"
#include "MatrixSubselection_logical.h"
#include "MatrixSubselection_logical_data.h"
#include "MatrixSubselection_logical_initialize.h"
#include "MatrixSubselection_logical_terminate.h"
#include "_coder_MatrixSubselection_logical_api.h"

/* Function Declarations */
MEXFUNCTION_LINKAGE void c_MatrixSubselection_logical_me(int32_T nlhs, mxArray
  *plhs[1], int32_T nrhs, const mxArray *prhs[4]);

/* Function Definitions */
void c_MatrixSubselection_logical_me(int32_T nlhs, mxArray *plhs[1], int32_T
  nrhs, const mxArray *prhs[4])
{
  const mxArray *outputs[1];

  /* Check for proper number of arguments. */
  if (nrhs != 4) {
    emlrtErrMsgIdAndTxt(emlrtRootTLSGlobal, "EMLRT:runTime:WrongNumberOfInputs",
                        5, 12, 4, 4, 26, "MatrixSubselection_logical");
  }

  if (nlhs > 1) {
    emlrtErrMsgIdAndTxt(emlrtRootTLSGlobal,
                        "EMLRT:runTime:TooManyOutputArguments", 3, 4, 26,
                        "MatrixSubselection_logical");
  }

  /* Call the function. */
  MatrixSubselection_logical_api(prhs, nlhs, outputs);

  /* Copy over outputs to the caller. */
  emlrtReturnArrays(1, plhs, outputs);
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(MatrixSubselection_logical_atexit);

  /* Module initialization. */
  MatrixSubselection_logical_initialize();

  /* Dispatch the entry-point. */
  c_MatrixSubselection_logical_me(nlhs, plhs, nrhs, prhs);

  /* Module termination. */
  MatrixSubselection_logical_terminate();
}

emlrtCTX mexFunctionCreateRootTLS()
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_MatrixSubselection_logical_mex.cpp) */
