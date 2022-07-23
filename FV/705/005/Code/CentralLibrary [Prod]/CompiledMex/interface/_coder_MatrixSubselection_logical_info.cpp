/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_MatrixSubselection_logical_info.cpp
 *
 * Code generation for function '_coder_MatrixSubselection_logical_info'
 *
 */

/* Include files */
#include "_coder_MatrixSubselection_logical_info.h"
#include "emlrt.h"
#include "rt_nonfinite.h"
#include "tmwtypes.h"

/* Function Declarations */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo();

/* Function Definitions */
static const mxArray *emlrtMexFcnResolvedFunctionsInfo()
{
  const mxArray *nameCaptureInfo;
  const char * data[8] = {
    "789ced594153d340140e0a8e8ea3d3f1e0d1a9fe00b6a915462e5a4ada521a2850d0119992265bbab09b8d9ba4a49c3879753cf9173c7af1e6815fa11ebd38e3"
    "cf30a10d4d83a14c23615af2663abb2f5f93efbdb7dd2f2f2937b1284e701c779febd8af279df19efdb9617f12dde337b87ef3e313ddf196cf776d8a9b3c3dcf",
    "8b7fe88e32550d68191d4795083c3d53a104a9926a54db1ae418d4296e41e50469200cab88c032f53845643b24ef814e1d0772e6b92694f7d74dc2b1a6de8b10"
    "7b9d5e3d3cf9729e7c27ff510f2feee67718508f840fdf12b617e6c0860e990e1405b618823ac8510526d7a046ed29540d26e132aa3389b5935b0bb0b50df250",
    "324c0605cb866403511588d002a2643064ad9b751d62d83d7ce6500dd35d244b789af4f275d6d30a99ef8301f9baf8d988fae3d8091947d0ef30d145146ad631"
    "ecf1fd0cc9c702f9faf1a8d7d9bfbe3b0179b8f51a94a77f74ed0e77bb3b3bfeb8f9f647363abe8e5d17beb0fbf361005fc2872ba6bc42f9d97c09955ba5f672",
    "7346e0db64be17476500cfa038b8003faaeb5f97fd7e1432cf4703f2747148700da946ad4119a654abd116640d4c0f6ab273b30dafeb7e0b8ac73597ef78483e"
    "f7fa3b3edfcfe7e25b8be5d7c2766e0e5418dd6512493a8d860ec46cb59c9d076be914ffbc0e0c4a719d5ac02e16c0a80e886460a97ee29e5fbf6912a17e7ffb",
    "3df53dd6ef4be28b4abff525c112160e0f2b252b9d11d3a9dc6a964f09e3a3df7f02cebf681ddf075c3fe1c32f7b5f3f3eff0bb526c41a64ffaf2f9ef4f9bdbc"
    "3b08d21bce0354647db869e7fe34dde3fb1c922f1fc8d78f0fb5ae0d644145a376c8c0a99373af8d4e475ece7eba1bf7d5a3aecbbc567d5354e5ccb2a5eeb5f2",
    "a9658115acc218e9f2a8ee5f2d64dcfef75afeb85d1ce9aa492043b2e1bcce8a4ed7e5a674f248e2f27d09c9b712c8d78f875f274fbdec058b4e1f8e5ec47a3b"
    "fa7abbf46c49abf0c57da5b90bdf15a583d9558364f2e3a3b7711f3c5cde83fa523b142259a3abcfa540be7e3cd4ba627b023a95ba82f7cc37bf26637d1e757d",
    "cee46716db0dda160b9bfc41d3422aa1441ca37e38d6e7e1f2be883e2335d6e78be933ba8aff01637dbe44bea8f479bd92de23f342bba0e456a557503436f756"
    "360aa3afcf7f01f47889e2", "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(&data[0], 8952U, &nameCaptureInfo);
  return nameCaptureInfo;
}

mxArray *emlrtMexFcnProperties()
{
  mxArray *xResult;
  mxArray *xEntryPoints;
  const char * epFieldName[6] = { "Name", "NumberOfInputs", "NumberOfOutputs",
    "ConstantInputs", "FullPath", "TimeStamp" };

  mxArray *xInputs;
  const char * propFieldName[4] = { "Version", "ResolvedFunctions",
    "EntryPoints", "CoverageInfo" };

  xEntryPoints = emlrtCreateStructMatrix(1, 1, 6, epFieldName);
  xInputs = emlrtCreateLogicalMatrix(1, 4);
  emlrtSetField(xEntryPoints, 0, "Name", emlrtMxCreateString(
    "MatrixSubselection_logical"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs", emlrtMxCreateDoubleScalar(4.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs", emlrtMxCreateDoubleScalar
                (1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(xEntryPoints, 0, "FullPath", emlrtMxCreateString(
    "D:\\Users\\ddevries\\Code Repos\\CentralLibrary [Dev]\\FeatureExtraction\\Mex\\MatrixSubselection\\MatrixSubselection_logical.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp", emlrtMxCreateDoubleScalar
                (737673.6223032407));
  xResult = emlrtCreateStructMatrix(1, 1, 4, propFieldName);
  emlrtSetField(xResult, 0, "Version", emlrtMxCreateString(
    "9.7.0.1190202 (R2019b)"));
  emlrtSetField(xResult, 0, "ResolvedFunctions", (mxArray *)
                emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

/* End of code generation (_coder_MatrixSubselection_logical_info.cpp) */
