function m3ui32BinnedImage = BinImage_uint16_To_uint32(m3ui16RawImage, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumBins)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui32BinnedImage = BinImage_Integer_To_uint32(...
    m3ui16RawImage,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    dFirstBinEdge, dBinSize, dNumBins);


end

