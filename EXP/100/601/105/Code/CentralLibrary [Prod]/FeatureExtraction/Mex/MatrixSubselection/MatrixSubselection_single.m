function m3sgSubMatrix = MatrixSubselection_single(m3sgMatrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3sgSubMatrix = MatrixSubselection(...
    m3sgMatrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'single');


end

