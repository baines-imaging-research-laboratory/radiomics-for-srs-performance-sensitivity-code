function m3dSubMatrix = MatrixSubselection_double(m3dMatrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3dSubMatrix = MatrixSubselection(...
    m3dMatrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'double');


end

