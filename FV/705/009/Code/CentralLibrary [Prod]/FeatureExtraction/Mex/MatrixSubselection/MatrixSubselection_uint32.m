function m3ui32SubMatrix = MatrixSubselection_uint32(m3ui32Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui32SubMatrix = MatrixSubselection(...
    m3ui32Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'uint32');


end

