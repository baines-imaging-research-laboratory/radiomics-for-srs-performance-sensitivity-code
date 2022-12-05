function m3ui8SubMatrix = MatrixSubselection_uint8(m3ui8Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui8SubMatrix = MatrixSubselection(...
    m3ui8Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'uint8');


end

