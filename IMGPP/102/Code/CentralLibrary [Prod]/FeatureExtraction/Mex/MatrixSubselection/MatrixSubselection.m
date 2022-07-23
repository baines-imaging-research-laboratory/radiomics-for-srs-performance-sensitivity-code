function m3xSubMatrix = MatrixSubselection(m3xMatrix, vdRowBounds, vdColBounds, vdSliceBounds, chMatrixClass)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

dNumRows = vdRowBounds(2) - vdRowBounds(1) + 1;
dNumCols = vdColBounds(2) - vdColBounds(1) + 1;
dNumSlices = vdSliceBounds(2) - vdSliceBounds(1) + 1;

m3xSubMatrix = zeros(dNumRows, dNumCols, dNumSlices, chMatrixClass);

dRowPlaceIndex = uint32(1);
dColPlaceIndex = uint32(1);
dSlicePlaceIndex = uint32(1);

for dSliceIndex = uint32(vdSliceBounds(1)):uint32(vdSliceBounds(2))
    for dColIndex = uint32(vdColBounds(1)):uint32(vdColBounds(2))
        for dRowIndex = uint32(vdRowBounds(1)):uint32(vdRowBounds(2))
            m3xSubMatrix(dRowPlaceIndex, dColPlaceIndex, dSlicePlaceIndex) = m3xMatrix(dRowIndex, dColIndex, dSliceIndex);
            
            dRowPlaceIndex = dRowPlaceIndex + uint32(1);
        end
        
        dRowPlaceIndex = uint32(1);
        dColPlaceIndex = dColPlaceIndex + uint32(1);
    end
    
    dColPlaceIndex = uint32(1);
    dSlicePlaceIndex = dSlicePlaceIndex + uint32(1);
end


end

