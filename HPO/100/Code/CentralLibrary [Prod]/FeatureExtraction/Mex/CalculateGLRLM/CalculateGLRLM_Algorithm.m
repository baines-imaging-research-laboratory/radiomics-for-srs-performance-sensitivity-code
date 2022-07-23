function m2ui64GLRLM = CalculateGLRLM_Algorithm(m3dMatrix, m3ui32BinnedMatrix, m3bRoiMask, vi32OffsetVector, dFirstBinEdge, dBinSize, ui32NumBins, dEqualityThreshold, bForNonIntegerMatrix, bBinOnTheFly, dNumberOfColumns, bTrimColumns)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her

% FINDING RUN LENGTHS:
%
% The general idea behind this algorithm is to first find the voxels at
% which runs will START from. This is found by using the offset vector. For
% example, if vi32OffsetVector(1) == -1, it would not be useful to start
% looking for a row index of 1, but rather the number of rows. This can be
% done for the column and slices indices as well (e.g. i32RowStart,
% i32ColStart, i32SliceStart).
% Next, depending on our vi32OffsetVector, we can imagine different cases
% of where our run-length "search paths" will run from and to. If
% vi32OffsetVector = [-1 0 0], we could imagine all the run-length search
% paths would start in the column-slice plane voxels at rowIndex = number
% of rows. Then we would simply loop through all the column and slice
% coordinate pairs with two nested for loops, and calculate run-lengths as
% the row index decreases from number of rows -> 1, while the column and
% slice coordinates are fixed. Then we move onto the next column-slice
% index pair within the two for loops and viola! we're done.
% The trickiness begins if we had an offset vector of [1 1 0]. Here we
% would have run-length search paths running from the rowIndex = 1 face of
% the volume AND from the colIndex = 1 face of the volume. Now we will have
% to run searches through using two distinct nested for loops, one that
% iterates over search path starting voxel column-slice index pairs, and 
% one that iterates pver row-slice index pairs. FURTHERMORE, care will have
% to be taken the shared strip of voxels where the row and column faces of
% the volume meet ARE NOT SEARCHED TWICE. This is what the i32PerpRowStart
% and i32PerpRowEnd values are for.
% This becomes more complex if the offset vector is [1 1 1]. In this case,
% three distinct nested for loops are needed for all the search-path
% starting voxels spread out along three faces of the volume. Furthermore,
% now there are three shared edges of voxels that shouldn't be searched
% twice (and one voxel that shouldn't be searched three times!). Similarly,
% i32PerpColStart and i32PerpColEnd are added to combat this.

% BINNING:
%
% This GLRLM calculator uses two "binning" type operations in conjunction.
%
% 1) To find the run-lengths, adjacent voxel values are compared to the
% starting voxel value. The0es voxel values ARE NOT BINNED! Rather, 
% dEqualityThreshold is used to specificy an absolute distance an adjacent
% RAW IMAGE value can be from the starting RAW IMAGE value (e.g. the
% accepted range size is 2*dEqualityThreshold.)
% If a mask value of false is encountered during a run-length search, the
% run-length search immediately ends
%
% 2) Once we have the run-lengths, they need to be placed within the GLRLM.
% This is where actual discretization occurs and the dFirstBinEdge, 
% dBinSize, and ui32NumBins parameters are used. They take the RAW IMAGE
% starting value that a run-length is associated with, and use the binning
% parameters to get a bin number from 1 to ui32NumBins. The index at
% m2dGLRLM(dBinNumber, dRunLength) is then increased by 1.

[m2ui64GLRLM, dNumberOfBins, vi32Dims, i32NumCols, i32NumSlices, i32RowStart, i32ColStart, i32SliceStart, i32PerpRowStart, i32PerpRowEnd, i32PerpColStart, i32PerpColEnd] ...
    = Setup(m3dMatrix, vi32OffsetVector, ui32NumBins, dNumberOfColumns);

% run lengths from a "row" face of the 3D volume

if i32RowStart ~= 0
    for i32SliceIndex = int32(1) : i32NumSlices
        for i32ColIndex = int32(1) :i32NumCols
            % find run lengths
            vi32SearchCoord = [i32RowStart, i32ColIndex, i32SliceIndex];
            
            m2ui64GLRLM = SearchFromVoxel(m2ui64GLRLM, m3dMatrix, m3ui32BinnedMatrix, m3bRoiMask, vi32SearchCoord, vi32OffsetVector, vi32Dims, dFirstBinEdge, dBinSize, dNumberOfBins, dEqualityThreshold, bForNonIntegerMatrix, bBinOnTheFly);            
        end
    end
end

% run lengths from a "col" face of the 3D volume

if i32ColStart ~= 0
    for i32SliceIndex = int32(1) : i32NumSlices
        for i32RowIndex = i32PerpRowStart : i32PerpRowEnd
            % find run lengths
            vi32SearchCoord = [i32RowIndex, i32ColStart, i32SliceIndex];
            
            m2ui64GLRLM = SearchFromVoxel(m2ui64GLRLM, m3dMatrix, m3ui32BinnedMatrix, m3bRoiMask, vi32SearchCoord, vi32OffsetVector, vi32Dims, dFirstBinEdge, dBinSize, dNumberOfBins, dEqualityThreshold, bForNonIntegerMatrix, bBinOnTheFly);
        end
    end
end


% run lengths from a "slice" face of the 3D volume

if i32SliceStart ~= 0
    for i32ColIndex = i32PerpColStart : i32PerpColEnd
        for i32RowIndex = i32PerpRowStart : i32PerpRowEnd
            % find run lengths
            vi32SearchCoord = [i32RowIndex, i32ColIndex, i32SliceStart];
            
            m2ui64GLRLM = SearchFromVoxel(m2ui64GLRLM, m3dMatrix, m3ui32BinnedMatrix, m3bRoiMask, vi32SearchCoord, vi32OffsetVector, vi32Dims, dFirstBinEdge, dBinSize, dNumberOfBins, dEqualityThreshold, bForNonIntegerMatrix, bBinOnTheFly);
        end
    end
end

% trim off columns of zero
if bTrimColumns
    m2ui64GLRLM = TrimColumns(m2ui64GLRLM);
end


end

function m2ui64GLRLM = SearchFromVoxel(m2ui64GLRLM, m3xMatrix, m3ui32BinnedMatrix, m3bRoiMask, vi32SearchCoord, vi32OffsetVector, vi32Dims, dFirstBinEdge, dBinSize, dNumberOfBins, dEqualityThreshold, bForNonIntegerMatrix, bBinOnTheFly)

i32RunCount = int32(0); % 0: No run started (mask has been false so far); 1: Run just started; >1: Multiple values in run

ui32RunStartBinnedValue = uint32(0);
    
    
if bBinOnTheFly
    if bForNonIntegerMatrix
        dRunStartValue = cast(0, 'like', m3xMatrix);
        
        dRunStartValueLowerBound = cast(0, 'like', m3xMatrix);
        dRunStartValueUpperBound = cast(0, 'like', m3xMatrix);
    else
        dRunStartValue = 0;
        
        dRunStartValueLowerBound = 0;
        dRunStartValueUpperBound = 0;
    end
else   
    if bForNonIntegerMatrix
        dRunStartValueLowerBound = cast(0, 'like', m3xMatrix);
        dRunStartValueUpperBound = cast(0, 'like', m3xMatrix);
    else
        dRunStartValueLowerBound = 0;
        dRunStartValueUpperBound = 0;
    end
end

while ~any( vi32SearchCoord > vi32Dims ) && ~any( vi32SearchCoord < 1 )
    if m3bRoiMask(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3))
        if i32RunCount == 0 % start new run
            i32RunCount = int32(1);
                        
            if bBinOnTheFly
                if bForNonIntegerMatrix
                    dRunStartValue = m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3));
                else
                    dRunStartValue = double(m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3)));
                end
                
                ui32RunStartBinnedValue = uint32(BinImage_PerformBinCalculation(dRunStartValue, dFirstBinEdge, dBinSize, dNumberOfBins));                            
            else
                ui32RunStartBinnedValue = m3ui32BinnedMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3));
                
                if bForNonIntegerMatrix
                    dRunStartValue = m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3));
                else
                    dRunStartValue = double(m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3)));
                end
            end
            
            dRunStartValueLowerBound = dRunStartValue - dEqualityThreshold;
            dRunStartValueUpperBound = dRunStartValue + dEqualityThreshold;
        else
            if bBinOnTheFly
                if bForNonIntegerMatrix
                    dNextValue = m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3));
                else
                    dNextValue = double(m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3)));
                end
            else
                if bForNonIntegerMatrix
                    dNextValue = m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3));
                else
                    dNextValue = double(m3xMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3)));
                end
            end
            
            
            if dNextValue <= dRunStartValueUpperBound && dNextValue >= dRunStartValueLowerBound
                % the run continues!!
                i32RunCount = i32RunCount + 1;
            else
                % the run is broken, need to: end run tally & set new run start value
                
                m2ui64GLRLM(ui32RunStartBinnedValue,i32RunCount) = m2ui64GLRLM(ui32RunStartBinnedValue,i32RunCount) + uint64(1);
            
                i32RunCount = int32(1);
                
                dRunStartValueLowerBound = dNextValue - dEqualityThreshold;
                dRunStartValueUpperBound = dNextValue + dEqualityThreshold;
                
                if bBinOnTheFly
                    ui32RunStartBinnedValue = uint32(BinImage_PerformBinCalculation(dNextValue, dFirstBinEdge, dBinSize, dNumberOfBins));
                else
                    ui32RunStartBinnedValue = m3ui32BinnedMatrix(vi32SearchCoord(1), vi32SearchCoord(2), vi32SearchCoord(3));
                end
            end
        end
    else % Mask value = false: Either have to end run (if one was started), or if no run was started, no nothing, keep looking for a true mask value to start a run with
        if i32RunCount ~= 0 % End run tally & Set no run started
            % End run tally:
            m2ui64GLRLM(ui32RunStartBinnedValue,i32RunCount) = m2ui64GLRLM(ui32RunStartBinnedValue,i32RunCount) + uint64(1);
            
            % Set no run started:
            i32RunCount = int32(0);
        end
    end
    
    % increment search
    vi32SearchCoord = vi32SearchCoord + vi32OffsetVector;
end

% if we ended, and we're in the middle of finding a run, tally it's value
if i32RunCount ~= 0
    m2ui64GLRLM(ui32RunStartBinnedValue,i32RunCount) = m2ui64GLRLM(ui32RunStartBinnedValue,i32RunCount) + uint64(1);            
end


end




% HELPER FUNCTIONS

function [m2ui64GLRLM, dNumberOfBins, vi32Dims, i32NumCols, i32NumSlices, i32RowStart, i32ColStart, i32SliceStart, i32PerpRowStart, i32PerpRowEnd, i32PerpColStart, i32PerpColEnd] = Setup(m3iMatrix, vi32OffsetVector, ui32NumBins, dNumberOfColumns)


dNumberOfBins = double(ui32NumBins);

vi32Dims = int32(size(m3iMatrix));

if length(vi32Dims) == 2
    vi32Dims = [vi32Dims, int32(1)];
end

i32NumRows = vi32Dims(1);
i32NumCols = vi32Dims(2);
i32NumSlices = vi32Dims(3);

m2ui64GLRLM = zeros(ui32NumBins, dNumberOfColumns, 'uint64');

% find the needed row search indices
if vi32OffsetVector(1) > 0
    i32RowStart = int32(1);
    
    i32PerpRowStart = int32(2); % these will prevent the same voxels from being used as a start point twice
    i32PerpRowEnd = i32NumRows;
elseif vi32OffsetVector(1) < 0
    i32RowStart = i32NumRows;
    
    i32PerpRowStart = int32(1);
    i32PerpRowEnd = i32NumRows-int32(1);
else
    i32RowStart = int32(0);
    
    i32PerpRowStart = int32(1);
    i32PerpRowEnd = i32NumRows;
end

% find the need col search indices
if vi32OffsetVector(2) > 0
    i32ColStart = int32(1);
    
    i32PerpColStart = int32(2);
    i32PerpColEnd = i32NumCols;
elseif vi32OffsetVector(2) < 0
    i32ColStart = vi32Dims(2);
    
    i32PerpColStart = int32(1);
    i32PerpColEnd = i32NumCols-int32(1);
else
    i32ColStart = int32(0);
    
    i32PerpColStart = int32(1);
    i32PerpColEnd = i32NumCols;
end

% find the needed slice search indices
if vi32OffsetVector(3) > 0
    i32SliceStart = int32(1);
elseif vi32OffsetVector(3) < 0
    i32SliceStart = vi32Dims(3);
else
    i32SliceStart = int32(0);
end
end


function m2ui64GLRLM = TrimColumns(m2ui64GLRLM)

% check for empty columns, remove all columns beyond the maximum non-zero
% column

dMinNonZeroColumnIndex = 0;

for dColumnIndex=1:size(m2ui64GLRLM,2)
    if max(m2ui64GLRLM(:,dColumnIndex)) ~= 0
        dMinNonZeroColumnIndex = 0;
    elseif dMinNonZeroColumnIndex == 0
        dMinNonZeroColumnIndex = dColumnIndex;
    end
end

if dMinNonZeroColumnIndex ~= 0
    m2ui64GLRLM = m2ui64GLRLM(:,1:dMinNonZeroColumnIndex-1);
end

end

function CalculateGLRLM_ValidateBinnedMatrix(m3ui32BinnedMatrix, m3iMatrix, ui32NumBins)

vdBinnedMatrixDims = size(m3ui32BinnedMatrix);
vdMatrixDims = size(m3iMatrix);

if length(vdBinnedMatrixDims) ~= length(vdMatrixDims) || any(vdBinnedMatrixDims ~= vdMatrixDims)
    error(...
        'CalculateGLRLM_ValidateBinnedMatrix:BinnedMatrixAndMatrixDimsMismatch',...
        'The binned matrix must have the identical dimensions as the raw image matrix.');
end

if any(m3ui32BinnedMatrix(:) < 1) || any(m3ui32BinnedMatrix(:) > ui32NumBins)
    error(...
        'CalculateGLRLM_ValidateBinnedMatrix:InvalidValue',...
        'The values of the binned matrix must be strictly between 1 and the number of bins (inclusive).');
end

end

function CalculateGLRLM_ValidateBinningParameters(dFirstBinEdge, dBinSize, ui32NumBins)

if ~isscalar(dFirstBinEdge) || isnan(dFirstBinEdge) || isinf(dFirstBinEdge)
    error(...
        'CalculateGLRLM_ValidateBinningParameters:InvalidFirstBinEdge',...
        'The first bin edge must be specified as a scalar, non-NaN, non-inf value.');
end

if ~isscalar(dBinSize) || isnan(dBinSize) || isinf(dBinSize) || dBinSize <= 0
    error(...
        'CalculateGLRLM_ValidateBinningParameters:InvalidBinSize',...
        'The bin size must be specified as a scalar, non-NaN, non-inf value that is strictly greater than zero.');
end

if ~isscalar(ui32NumBins) || ui32NumBins <= 0
    error(...
        'CalculateGLRLM_ValidateBinningParameters:InvalidNumberOfBins',...
        'The number of bins must be specified as a scalar integer value that is strictly greater than zero.');
end

end

function CalculateGLRLM_ValidateEqualityThreshold(dEqualityThreshold)

if ~isscalar(dEqualityThreshold) || isnan(dEqualityThreshold) || isinf(dEqualityThreshold) || dEqualityThreshold < 0
    error(...
        'CalculateGLRLM_ValidateEqualityThreshold:InvalidValue',...
        'The equality threshold must be a scalar, non-Nan, non-inf value that is strictly equal to or greater than 0.')
        
end

end

function CalculateGLRLM_ValidateMatrixAndMask(m3iMatrix, m3bRoiMask)

vdMatrixDims = size(m3iMatrix);
vdMaskDims = size(m3bRoiMask);

if length(vdMatrixDims) ~= length(vdMaskDims) || any(vdMatrixDims ~= vdMaskDims)
    error(...
        'CalculateGLRLM_ValidateMatrixAndMask:MatrixMaskDimsMismatch',...
        'The provided matrix and mask must have identical dimensions.');
end

if length(vdMatrixDims) > 3
    error(...
        'CalculateGLRLM_ValidateMatrixAndMask:InvalidDimension',...
        'The provided matrix and mask must be at maximum three dimensional.');
end

if any(isnan(m3iMatrix(:))) || any(isinf(m3iMatrix(:)))
    error(...
        'CalculateGLRLM_ValidateMatrixAndMask:InvalidMatrixValue',...
        'The provided matrix may not contained any NaN or Inf values.');
end

end



function CalculateGLRLM_ValidateOffsetVector(vi32OffsetVector)

vdDims = size(vi32OffsetVector);

if any(vdDims ~= [1 3]) % 3 element row vector
    error(...
        'CalculateGLRLM_ValidateOffsetVector:InvalidDimensions',...
        'The offset vector must be a 1x3 row vector.');
end

if any(abs(vi32OffsetVector) ~= 1 & vi32OffsetVector ~= 0)
    error(...
        'CalculateGLRLM_ValidateOffsetVector:InvalidValue',...
        'The offset vector may only contain values of 0, 1, or -1.');
end

end
