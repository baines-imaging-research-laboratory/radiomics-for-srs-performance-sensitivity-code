function m3ui32BinnedImage = BinImage_double_To_uint32(m3dRawImage, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumBins)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui32BinnedImage = BinImage_NonInteger_To_uint32(...
    m3dRawImage,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    dFirstBinEdge, dBinSize, dNumBins);


end

