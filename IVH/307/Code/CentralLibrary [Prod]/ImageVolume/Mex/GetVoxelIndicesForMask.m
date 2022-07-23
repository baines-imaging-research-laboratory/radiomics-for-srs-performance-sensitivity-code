function m2dVoxelIndices = GetVoxelIndicesForMask(m3bMask)

% find number of points
dNumPoints = 0;

vdDims = size(m3bMask);

if length(vdDims) == 2
    vdDims = [vdDims 1];
end

for dSlice=1:vdDims(3)
    for dCol=1:vdDims(2)
        for dRow=1:vdDims(1)
            if m3bMask(dRow,dCol,dSlice)
                dNumPoints = dNumPoints + 1;
            end
        end
    end
end

% get indices
m2dVoxelIndices = zeros(dNumPoints,3);
dInsertIndex = 1;

for dSlice=1:vdDims(3)
    for dCol=1:vdDims(2)
        for dRow=1:vdDims(1)
            if m3bMask(dRow,dCol,dSlice)
                m2dVoxelIndices(dInsertIndex,:) = [dRow dCol dSlice];
                dInsertIndex = dInsertIndex + 1;
            end
        end
    end
end

end

