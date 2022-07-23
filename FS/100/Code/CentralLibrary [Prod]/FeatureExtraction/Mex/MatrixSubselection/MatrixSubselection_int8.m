function m3i8SubMatrix = MatrixSubselection_int8(m3i8Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3i8SubMatrix = MatrixSubselection(...
    m3i8Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'int8');


end

