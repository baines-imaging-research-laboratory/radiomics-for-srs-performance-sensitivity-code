function [m2iGLCM, viDims, iNumel, iIndex, iOffsetIndex, iRowIndex, iColIndex, iSliceIndex, iRowOffsetStart, iColOffsetStart, iRowOffsetIndex, iColOffsetIndex, iSliceOffsetIndex, bRowLowWatch, bRowHighWatch, bColLowWatch, bColHighWatch, bSliceLowWatch, bSliceHighWatch, vbDimsValid] = BinOnTheFly_Setup(m3xMatrix, viOffsetVector, iNumBins)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
viDims = int64(size(m3xMatrix));

if length(viDims) == 2
    viDims = [viDims, int64(1)];
end

m2iGLCM = zeros(iNumBins,iNumBins, 'uint64');

iLinearOffset = viOffsetVector(1) + viDims(1)*viOffsetVector(2) + viDims(1)*viDims(2)*viOffsetVector(3);

iNumel = int64(numel(m3xMatrix));

iIndex = int64(1);

iRowIndex = int32(1);
iColIndex = int32(1);
iSliceIndex = int32(1);

iOffsetIndex = int64(1 + iLinearOffset);

iRowOffsetStart = int32(1 + viOffsetVector(1));
iColOffsetStart = int32(1 + viOffsetVector(2));
iSliceOffsetStart = int32(1 + viOffsetVector(3));

iRowOffsetIndex = iRowOffsetStart;
iColOffsetIndex = iColOffsetStart;
iSliceOffsetIndex = iSliceOffsetStart;

bRowLowWatch = viOffsetVector(1) < 0;
bRowHighWatch = viOffsetVector(1) > 0;

bColLowWatch = viOffsetVector(2) < 0;
bColHighWatch = viOffsetVector(2) > 0;

bSliceLowWatch = viOffsetVector(3) < 0;
bSliceHighWatch = viOffsetVector(3) > 0;

vbDimsValid = [ ~bRowLowWatch, ~bColLowWatch, ~bSliceLowWatch ];

end

