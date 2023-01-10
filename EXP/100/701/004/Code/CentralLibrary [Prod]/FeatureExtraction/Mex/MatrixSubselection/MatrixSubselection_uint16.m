function m3ui16SubMatrix = MatrixSubselection_uint16(m3ui16Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3ui16SubMatrix = MatrixSubselection(...
    m3ui16Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'uint16');


end

