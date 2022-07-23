function m3ui32BinnedImage = BinImage_Integer_To_uint32(m3iRawImage, vdRowBounds, vdColBounds, vdSliceBounds, dFirstBinEdge, dBinSize, dNumberOfBins)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

dNumRows = vdRowBounds(2) - vdRowBounds(1) + 1;
dNumCols = vdColBounds(2) - vdColBounds(1) + 1;
dNumSlices = vdSliceBounds(2) - vdSliceBounds(1) + 1;

m3ui32BinnedImage = zeros(dNumRows, dNumCols, dNumSlices, 'uint32');

dRowPlaceIndex = 1;
dColPlaceIndex = 1;
dSlicePlaceIndex = 1;

for dSliceIndex = vdSliceBounds(1):vdSliceBounds(2)
    for dColIndex = vdColBounds(1):vdColBounds(2)
        for dRowIndex = vdRowBounds(1):vdRowBounds(2)
            dBinnedValue = BinImage_PerformBinCalculation(...
                double(m3iRawImage(dRowIndex, dColIndex, dSliceIndex)),...
                dFirstBinEdge, dBinSize, dNumberOfBins);

            m3ui32BinnedImage(dRowPlaceIndex, dColPlaceIndex, dSlicePlaceIndex) = ...
                uint32(dBinnedValue);
            
            dRowPlaceIndex = dRowPlaceIndex + 1;
        end
        
        dRowPlaceIndex = 1;
        dColPlaceIndex = dColPlaceIndex + 1;
    end    
    
    dColPlaceIndex = 1;
    dSlicePlaceIndex = dSlicePlaceIndex + 1;
end


end

