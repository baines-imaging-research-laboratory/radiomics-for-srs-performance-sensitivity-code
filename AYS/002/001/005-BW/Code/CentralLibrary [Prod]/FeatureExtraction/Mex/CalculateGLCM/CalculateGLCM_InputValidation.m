function CalculateGLCM_InputValidation(m3dMatrix, m3bRoiMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui64NumBins)

vdMatrixDims = size(m3dMatrix);
vdMaskDims = size(m3bRoiMask);

if length(vdMatrixDims) ~= length(vdMaskDims) || any(vdMatrixDims ~= vdMaskDims)
    error(...
        'CalculateGLCM_InputValidation:MatrixMaskDimMismatch',...
        'Provided matrix and mask must have the same dimensions.');
end

viAbsOffsetVector = abs(vi32OffsetVector);

if ~all( (viAbsOffsetVector == 0) | (viAbsOffsetVector == max(viAbsOffsetVector)) )
    error(...
        'CalculateGLCM_InputValidation:NonStandardOffset',...
        'The given offset was non-standard (e.g. not along a "90" or "45" degree increment). While this offset type is technically supported, it has not been rigourously tested at this time, and so has been disabled.');
end

if dBinSize <= 0
    error(...
        'CalculateGLCM_InputValidation:InvalidBinSize',...
        'Bin size must be strictly greater than 0');
end

if ui64NumBins <= 0
    error(...
        'CalculateGLCM_InputValidation:InvalidNumberOfBins',...
        'Number of bins must be strictly greater than 0');
end

end

