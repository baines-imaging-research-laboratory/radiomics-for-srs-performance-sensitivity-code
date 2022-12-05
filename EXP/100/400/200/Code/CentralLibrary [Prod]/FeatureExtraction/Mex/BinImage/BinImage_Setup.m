function m3iBinnedImage = BinImage_Setup(vdRowBounds, vdColBounds, vdSliceBounds, chBinnedImageClassName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

dNumRows = vdRowBounds(2) - vdRowBounds(1) + 1;
dNumCols = vdColBounds(2) - vdColBounds(1) + 1;
dNumSlices = vdSliceBounds(2) - vdSliceBounds(1) + 1;

switch chBinnedImageClassName
    case 'int8'
        m3iBinnedImage = zeros(dNumRows, dNumCols, dNumSlices, 'int8');
    case 'int16'
        m3iBinnedImage = zeros(dNumRows, dNumCols, dNumSlices, 'int16');
    case 'int32'
        m3iBinnedImage = zeros(dNumRows, dNumCols, dNumSlices, 'int32');
    case 'uint8'
        m3iBinnedImage = zeros(dNumRows, dNumCols, dNumSlices, 'uint8');        
    case 'uint16'
        m3iBinnedImage = zeros(dNumRows, dNumCols, dNumSlices, 'uint16');
    case 'uint32'
        m3iBinnedImage = zeros(dNumRows, dNumCols, dNumSlices, 'uint32');
    otherwise
        error(...
            'BinImage_Setup:InvalidOutputClassType',...
            'Binning can only produce integer matrices up to 32-bits');
end

end

