function m3ui32BinnedImage = BinImage_single_To_uint32(m3sgRawImage, vdRowBounds, vdColBounds, vdSliceBounds, sgFirstBinEdge, sgBinSize, sgNumBins)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui32BinnedImage = BinImage_NonInteger_To_uint32(...
    m3sgRawImage,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    sgFirstBinEdge, sgBinSize, sgNumBins);


end

