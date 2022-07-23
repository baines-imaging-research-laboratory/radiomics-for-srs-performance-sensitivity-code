function m3i64SubMatrix = MatrixSubselection_int64(m3i64Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3i64SubMatrix = MatrixSubselection(...
    m3i64Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'int64');


end

