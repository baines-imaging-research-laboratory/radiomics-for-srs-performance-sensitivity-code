function m3i16SubMatrix = MatrixSubselection_int16(m3i16Matrix, vdRowBounds, vdColBounds, vdSliceBounds)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

m3i16SubMatrix = MatrixSubselection(...
    m3i16Matrix,...
    vdRowBounds, vdColBounds, vdSliceBounds,...
    'int16');


end

