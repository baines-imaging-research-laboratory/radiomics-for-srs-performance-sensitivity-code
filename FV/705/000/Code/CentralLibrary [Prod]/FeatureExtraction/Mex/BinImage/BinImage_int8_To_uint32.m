function m3ui32BinnedImage = BinImage_int8_To_uint32(m3i8RawImage, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumBins)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui32BinnedImage = BinImage_Integer_To_uint32(...
    m3i8RawImage,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    dFirstBinEdge, dBinSize, dNumBins);


end

