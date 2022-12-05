function m3ui64SubMatrix = MatrixSubselection_uint64(m3ui64Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui64SubMatrix = MatrixSubselection(...
    m3ui64Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'uint64');


end

