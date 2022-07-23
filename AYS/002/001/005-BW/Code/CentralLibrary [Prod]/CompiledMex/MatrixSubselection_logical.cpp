/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * MatrixSubselection_logical.cpp
 *
 * Code generation for function 'MatrixSubselection_logical'
 *
 */

/* Include files */
#include "MatrixSubselection_logical.h"
#include "MatrixSubselection_logical_emxutil.h"
#include "mwmathutil.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void MatrixSubselection_logical(const emxArray_boolean_T *m3bMatrix, const
  real_T vdRowBounds[2], const real_T vdColBounds[2], const real_T
  vdSliceBounds[2], emxArray_boolean_T *m3bSubMatrix)
{
  int32_T i;
  int32_T loop_ub;
  int32_T i1;
  int32_T i2;
  uint32_T dRowPlaceIndex;
  uint32_T dColPlaceIndex;
  uint32_T dSlicePlaceIndex;
  uint32_T u;
  uint32_T u1;
  uint32_T dSliceIndex;
  uint32_T u2;
  uint32_T u3;
  uint32_T dColIndex;
  uint32_T u4;
  uint32_T u5;
  uint32_T dRowIndex;

  /* UNTITLED Summary of this function goes here */
  /*    Detailed explanation goes her */
  /* UNTITLED Summary of this function goes here */
  /*    Detailed explanation goes her */
  i = static_cast<int32_T>(((vdRowBounds[1] - vdRowBounds[0]) + 1.0));
  loop_ub = m3bSubMatrix->size[0] * m3bSubMatrix->size[1] * m3bSubMatrix->size[2];
  m3bSubMatrix->size[0] = i;
  i1 = static_cast<int32_T>(((vdColBounds[1] - vdColBounds[0]) + 1.0));
  m3bSubMatrix->size[1] = i1;
  i2 = static_cast<int32_T>(((vdSliceBounds[1] - vdSliceBounds[0]) + 1.0));
  m3bSubMatrix->size[2] = i2;
  emxEnsureCapacity_boolean_T(m3bSubMatrix, loop_ub);
  loop_ub = i * i1 * i2;
  for (i = 0; i < loop_ub; i++) {
    m3bSubMatrix->data[i] = false;
  }

  dRowPlaceIndex = 1U;
  dColPlaceIndex = 1U;
  dSlicePlaceIndex = 1U;
  u = static_cast<uint32_T>(muDoubleScalarRound(vdSliceBounds[0]));
  u1 = static_cast<uint32_T>(muDoubleScalarRound(vdSliceBounds[1]));
  for (dSliceIndex = u; dSliceIndex <= u1; dSliceIndex++) {
    u2 = static_cast<uint32_T>(muDoubleScalarRound(vdColBounds[0]));
    u3 = static_cast<uint32_T>(muDoubleScalarRound(vdColBounds[1]));
    for (dColIndex = u2; dColIndex <= u3; dColIndex++) {
      u4 = static_cast<uint32_T>(muDoubleScalarRound(vdRowBounds[0]));
      u5 = static_cast<uint32_T>(muDoubleScalarRound(vdRowBounds[1]));
      for (dRowIndex = u4; dRowIndex <= u5; dRowIndex++) {
        m3bSubMatrix->data[((static_cast<int32_T>(dRowPlaceIndex) +
                             m3bSubMatrix->size[0] * (static_cast<int32_T>
          (dColPlaceIndex) - 1)) + m3bSubMatrix->size[0] * m3bSubMatrix->size[1]
                            * (static_cast<int32_T>(dSlicePlaceIndex) - 1)) - 1]
          = m3bMatrix->data[((static_cast<int32_T>(dRowIndex) + m3bMatrix->size
                              [0] * (static_cast<int32_T>(dColIndex) - 1)) +
                             m3bMatrix->size[0] * m3bMatrix->size[1] * (
          static_cast<int32_T>(dSliceIndex) - 1)) - 1];
        dRowPlaceIndex++;
      }

      dRowPlaceIndex = 1U;
      dColPlaceIndex++;
    }

    dColPlaceIndex = 1U;
    dSlicePlaceIndex++;
  }
}

/* End of code generation (MatrixSubselection_logical.cpp) */
