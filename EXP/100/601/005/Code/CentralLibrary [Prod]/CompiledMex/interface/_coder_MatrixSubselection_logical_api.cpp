/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_MatrixSubselection_logical_api.cpp
 *
 * Code generation for function '_coder_MatrixSubselection_logical_api'
 *
 */

/* Include files */
#include "_coder_MatrixSubselection_logical_api.h"
#include "MatrixSubselection_logical.h"
#include "MatrixSubselection_logical_data.h"
#include "MatrixSubselection_logical_emxutil.h"
#include "rt_nonfinite.h"

/* Function Declarations */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_boolean_T *y);
static real_T (*c_emlrt_marshallIn(const mxArray *vdRowBounds, const char_T
  *identifier))[2];
static real_T (*d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId))[2];
static void e_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_boolean_T *ret);
static void emlrt_marshallIn(const mxArray *m3bMatrix, const char_T *identifier,
  emxArray_boolean_T *y);
static const mxArray *emlrt_marshallOut(const emxArray_boolean_T *u);
static real_T (*f_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *
  msgId))[2];

/* Function Definitions */
static void b_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier
  *parentId, emxArray_boolean_T *y)
{
  e_emlrt_marshallIn(emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static real_T (*c_emlrt_marshallIn(const mxArray *vdRowBounds, const char_T
  *identifier))[2]
{
  real_T (*y)[2];
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char *>(identifier);
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = d_emlrt_marshallIn(emlrtAlias(vdRowBounds), &thisId);
  emlrtDestroyArray(&vdRowBounds);
  return y;
}
  static real_T (*d_emlrt_marshallIn(const mxArray *u, const emlrtMsgIdentifier *
  parentId))[2]
{
  real_T (*y)[2];
  y = f_emlrt_marshallIn(emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static void e_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier
  *msgId, emxArray_boolean_T *ret)
{
  static const int32_T dims[3] = { -1, -1, -1 };

  const boolean_T bv[3] = { true, true, true };

  int32_T iv[3];
  int32_T i;
  emlrtCheckVsBuiltInR2012b(emlrtRootTLSGlobal, msgId, src, "logical", false, 3U,
    dims, &bv[0], iv);
  ret->allocatedSize = iv[0] * iv[1] * iv[2];
  i = ret->size[0] * ret->size[1] * ret->size[2];
  ret->size[0] = iv[0];
  ret->size[1] = iv[1];
  ret->size[2] = iv[2];
  emxEnsureCapacity_boolean_T(ret, i);
  ret->data = (boolean_T *)emlrtMxGetData(src);
  ret->canFreeData = false;
  emlrtDestroyArray(&src);
}

static void emlrt_marshallIn(const mxArray *m3bMatrix, const char_T *identifier,
  emxArray_boolean_T *y)
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = const_cast<const char *>(identifier);
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  b_emlrt_marshallIn(emlrtAlias(m3bMatrix), &thisId, y);
  emlrtDestroyArray(&m3bMatrix);
}

static const mxArray *emlrt_marshallOut(const emxArray_boolean_T *u)
{
  const mxArray *y;
  const mxArray *m;
  static const int32_T iv[3] = { 0, 0, 0 };

  y = NULL;
  m = emlrtCreateLogicalArray(3, iv);
  emlrtMxSetData((mxArray *)m, &u->data[0]);
  emlrtSetDimensions((mxArray *)m, u->size, 3);
  emlrtAssign(&y, m);
  return y;
}

static real_T (*f_emlrt_marshallIn(const mxArray *src, const emlrtMsgIdentifier *
  msgId))[2]
{
  real_T (*ret)[2];
  static const int32_T dims[2] = { 1, 2 };

  emlrtCheckBuiltInR2012b(emlrtRootTLSGlobal, msgId, src, "double", false, 2U,
    dims);
  ret = (real_T (*)[2])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}
  void MatrixSubselection_logical_api(const mxArray * const prhs[4], int32_T,
  const mxArray *plhs[1])
{
  emxArray_boolean_T *m3bMatrix;
  emxArray_boolean_T *m3bSubMatrix;
  real_T (*vdRowBounds)[2];
  real_T (*vdColBounds)[2];
  real_T (*vdSliceBounds)[2];
  emlrtHeapReferenceStackEnterFcnR2012b(emlrtRootTLSGlobal);
  emxInit_boolean_T(&m3bMatrix, 3, true);
  emxInit_boolean_T(&m3bSubMatrix, 3, true);

  /* Marshall function inputs */
  m3bMatrix->canFreeData = false;
  emlrt_marshallIn(emlrtAlias(prhs[0]), "m3bMatrix", m3bMatrix);
  vdRowBounds = c_emlrt_marshallIn(emlrtAlias(prhs[1]), "vdRowBounds");
  vdColBounds = c_emlrt_marshallIn(emlrtAlias(prhs[2]), "vdColBounds");
  vdSliceBounds = c_emlrt_marshallIn(emlrtAlias(prhs[3]), "vdSliceBounds");

  /* Invoke the target function */
  MatrixSubselection_logical(m3bMatrix, *vdRowBounds, *vdColBounds,
    *vdSliceBounds, m3bSubMatrix);

  /* Marshall function outputs */
  m3bSubMatrix->canFreeData = false;
  plhs[0] = emlrt_marshallOut(m3bSubMatrix);
  emxFree_boolean_T(&m3bSubMatrix);
  emxFree_boolean_T(&m3bMatrix);
  emlrtHeapReferenceStackLeaveFcnR2012b(emlrtRootTLSGlobal);
}

/* End of code generation (_coder_MatrixSubselection_logical_api.cpp) */
