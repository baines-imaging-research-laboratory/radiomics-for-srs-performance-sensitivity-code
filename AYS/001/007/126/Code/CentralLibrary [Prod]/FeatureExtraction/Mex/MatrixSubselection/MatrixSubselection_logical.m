function m3bSubMatrix = MatrixSubselection_logical(m3bMatrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3bSubMatrix = MatrixSubselection(...
    m3bMatrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'logical');


end

