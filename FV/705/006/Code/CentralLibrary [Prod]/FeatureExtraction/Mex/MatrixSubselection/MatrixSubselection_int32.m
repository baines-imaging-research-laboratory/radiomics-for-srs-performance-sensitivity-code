function m3i32SubMatrix = MatrixSubselection_int32(m3i32Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3i32SubMatrix = MatrixSubselection(...
    m3i32Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'int32');


end

