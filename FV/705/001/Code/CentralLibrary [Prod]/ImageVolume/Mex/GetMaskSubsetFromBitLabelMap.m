function m3bMask = GetMaskSubsetFromBitLabelMap(m3uiBitLabelMap, dBitPosition, vdRowBounds, vdColBounds, vdSliceBounds)

% find bounds

vdDims  = [size(m3uiBitLabelMap,1), size(m3uiBitLabelMap,2), size(m3uiBitLabelMap,3)];

% pre-allocate mask


dNumRows = vdRowBounds(2) - vdRowBounds(1)  + 1;
dNumCols = vdColBounds(2) - vdColBounds(1)  + 1;
dNumSlices = vdSliceBounds(2) - vdSliceBounds(1)  + 1;

m3bMask = false(dNumRows, dNumCols, dNumSlices);

% fill in mask

dRowGetStart = max(1, vdRowBounds(1));
dRowGetEnd = min(vdDims(1), vdRowBounds(2));

dColGetStart = max(1, vdColBounds(1));
dColGetEnd = min(vdDims(2), vdColBounds(2));

dSliceGetStart = max(1, vdSliceBounds(1));
dSliceGetEnd = min(vdDims(3), vdSliceBounds(2));

dRowLabelMapToMaskOffset = -(vdRowBounds(1) - 1);
dColLabelMapToMaskOffset = -(vdColBounds(1) - 1);
dSliceLabelMapToMaskOffset = -(vdSliceBounds(1) - 1);

for dSlice=dSliceGetStart:dSliceGetEnd
    for dCol=dColGetStart:dColGetEnd
        for dRow=dRowGetStart:dRowGetEnd
            if 1 == bitget(m3uiBitLabelMap(dRow, dCol, dSlice), dBitPosition)
                m3bMask(...
                    dRow+dRowLabelMapToMaskOffset,...
                    dCol+dColLabelMapToMaskOffset,...
                    dSlice+dSliceLabelMapToMaskOffset)...
                    = true;
            end
        end
    end
end

end

