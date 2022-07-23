classdef (Abstract) MemoryEfficiencyUtils
    %MemoryEfficiencyUtils
    %   This utility package contains function that mimick Matlab
    %   functions, though perform the functions in a more memory efficient
    %   manner.
    %   *NOTE* All additions should be added as Static Methods.
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Access = private, Constant = true)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Static = true)
        
        function m2xArray = ReindexRowsInPlace(m2xArray, m1dRowIndices)
            % m2xArray = ReindexRowsInPlace(m2xArray, m1dRowIndices)
            
            % Written by: David DeVries
            % Created: Feb 2, 2019
            % Modified: -
            
            % performs the Matlab functionality m = m(i,:) for i being a reindexing of
            % m, but performs it in place with limited memory overhead. The only
            % addition memory used is a boolean flag matrix taking up as many bits as
            % rows in the array. Run-time is approximately twice that of Matlab's m =
            % m(i,:)
            
            % INPUTS:
            % - m2Array: Two-dimensional matrix or cell array of any data type
            % - m1dRowIndices: A Nx1 column vector where N equals the number of rows in
            % m2Array. Must consist of the indices 1 to N, with each index occuring
            % ONCE AND ONLY ONCE, but in any order
            
            % OUTPUTS:
            % - m2Array: The same two-dimensional matrix as inputted (not copied in
            % memory) with it's rows reindexed as per m1dRowIndices
                        
            % find array dimensions
            m1dDims = size(m2xArray);
            
            dNumRows = m1dDims(1);
            dNumCols = m1dDims(2);
            
            % check that array and indices are consistent in size
            if dNumRows ~= length(m1dRowIndices)
                error('ReindexRowsInPlace:DimensionMismatch','Length of indices does not match number of rows in array');
            end
            
            % allocate boolean flags that will be first to check that each index is
            % present within indices (can't have duplicated indices)
            bFlags = false(dNumRows,1);
            
            % loop through m1dRowIndices
            for dIndex=1:dNumRows
                dIndexFromRowIndices = m1dRowIndices(dIndex);
                
                if dIndexFromRowIndices < 1 || dIndexFromRowIndices > dNumRows
                    % through error if index is out of bounds
                    error('ReindexRowsInPlace:InvalidIndex','Row indices must between 1 and the number of rows in array');
                else
                    % set flag if index found
                    bFlags(dIndexFromRowIndices) = true;
                end
            end
            
            % check that all flags have been flipped (all indices must be present
            if ~all(bFlags)
                error('ReindexRowsInPlace:NonUniqueIndices','Non-unique indices within row indices');
            end
            
            % initialize indices and temporary variables
            
            % index of which row of the array we're currently switching
            dIndex = 1;
            
            % temporary rows to hold rows when switching them out
            m1TempRow = zeros(1, dNumCols);
            
            % reset boolean flags to false if an index is incorrect
            
            bFlags(:) = m1dRowIndices == (1:dNumRows)';
            
            % pre-allocate
            dTempIndex = 0;
            
            
            % loop through row indices until all indices have been switched
            while dIndex <= dNumRows
                if bFlags(dIndex) % if the index has already been switched:
                    dIndex = dIndex + 1; % move onto next index
                else
                    % index to switch current index into
                    dTempIndex = m1dRowIndices(dIndex);
                    
                    % perform row switch
                    if ~bFlags(dTempIndex)
                        m1TempRow(:) = m2xArray(dIndex,:);
                        m2xArray(dIndex,:) = m2xArray(dTempIndex,:);
                        m2xArray(dTempIndex,:) = m1TempRow;
                    end
                    
                    % updates flags and indices
                    bFlags(dIndex) = true;
                    dIndex = dTempIndex;
                end
            end
        end
        
        function m2xArray = ReindexColumnsInPlace(m2xArray, m1dColIndices)
            % m2xArray = ReindexColumnsInPlace(m2xArray, m1dColIndices)
            %
            % SYNTAX:
            %  m2xArray = ReindexColumnsInPlace(m2xArray, m1dColIndices)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUTS:
            %  m2xArray:
            %  m1dColIndices: 
            
            % OUTPUTS:
            %  m2xArray:
                        
            % find array dimensions
            m1dDims = size(m2xArray);
            
            dNumRows = m1dDims(1);
            dNumCols = m1dDims(2);
            
            % check that array and indices are consistent in size
            if dNumCols ~= length(m1dColIndices)
                error('ReindexRowsInPlace:DimensionMismatch','Length of indices does not match number of rows in array');
            end
            
            % allocate boolean flags that will be first to check that each index is
            % present within indices (can't have duplicated indices)
            bFlags = false(dNumCols,1);
            
            % loop through m1dRowIndices
            for dIndex=1:dNumCols
                dIndexFromColIndices = m1dColIndices(dIndex);
                
                if dIndexFromColIndices < 1 || dIndexFromColIndices > dNumCols
                    % through error if index is out of bounds
                    error('ReindexRowsInPlace:InvalidIndex','Row indices must between 1 and the number of rows in array');
                else
                    % set flag if index found
                    bFlags(dIndexFromColIndices) = true;
                end
            end
            
            % check that all flags have been flipped (all indices must be present
            if ~all(bFlags)
                error('ReindexRowsInPlace:NonUniqueIndices','Non-unique indices within row indices');
            end
            
            % initialize indices and temporary variables
            
            % index of which row of the array we're currently switching
            dIndex = 1;
            
            % temporary rows to hold rows when switching them out
            m1TempCol = zeros(dNumRows, 1);
            
            % reset boolean flags to false if an index is incorrect
            
            bFlags(:) = m1dColIndices == 1:dNumCols;
            
            % pre-allocate
            dTempIndex = 0;
            
            
            % loop through row indices until all indices have been switched
            while dIndex <= dNumCols
                if bFlags(dIndex) % if the index has already been switched:
                    dIndex = dIndex + 1; % move onto next index
                else
                    % index to switch current index into
                    dTempIndex = m1dColIndices(dIndex);
                    
                    % perform row switch
                    if ~bFlags(dTempIndex)
                        m1TempCol(:) = m2xArray(:, dIndex);
                        m2xArray(:,dIndex) = m2xArray(:,dTempIndex);
                        m2xArray(:,dTempIndex) = m1TempCol;
                    end
                    
                    % updates flags and indices
                    bFlags(dIndex) = true;
                    dIndex = dTempIndex;
                end
            end
        end
        
        function m2xToMatrix = AssignSubMatrix(m2xToMatrix, vdToMatrixRowSelection, vdToMatrixColSelection, m2xFromMatrix, vdFromMatrixRowSelection, vdFromMatrixColSelection, dMaxMemorySpike_Gb)
            % m2xToMatrix = AssignSubMatrix(m2xToMatrix, vdToMatrixRowSelection, vdToMatrixColSelection, m2xFromMatrix, vdFromMatrixRowSelection, vdFromMatrixColSelection, dMaxMemorySpike_Gb)
            %
            % SYNTAX:
            %  m2xToMatrix = AssignSubMatrix(m2xToMatrix, vdToMatrixRowSelection, vdToMatrixColSelection, m2xFromMatrix, vdFromMatrixRowSelection, vdFromMatrixColSelection, dMaxMemorySpike_Gb)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUTS:
            %  m2xToMatrix:
            %  vdToMatrixRowSelection: 
            %  vdToMatrixColSelection:
            %  m2xFromMatrix:
            %  vdFromMatrixRowSelection:
            %  vdFromMatrixColSelection:
            %  dMaxMemorySpike_Gb:
            
            % OUTPUTS:
            %  m2xToMatrix:
                        
            dNumElementsPerRow = length(vdToMatrixColSelection);
            dNumRowsToTransfer = length(vdToMatrixRowSelection);
            
            xElement = m2xToMatrix(1);
            stElementMetadata = whos('xElement');
            dElementSize_B = stElementMetadata.bytes;
            
            dRowSize_B = dElementSize_B * dNumElementsPerRow;
            
            dNumRowsPerTransfer = floor(dMaxMemorySpike_Gb*1E9 / dRowSize_B);
            
            if dNumRowsPerTransfer == 0
                error(...
                    'MemoryEfficiencyUtils:AssignSubMatrix:InvalidMemorySpikeLimit',...
                    'To transfer efficiently, at least one row must be passed at a time, but the size of one row for the given selection is larger than the allowable memory spike.');
            else
                dTransferRowStart = 1;
                
                while dTransferRowStart <= dNumRowsToTransfer
                    dTransferRowEnd = dTransferRowStart + dNumRowsPerTransfer - 1;
                    
                    dTransferRowEnd = min(dTransferRowEnd, dNumRowsToTransfer);
                    
                    m2xToMatrix(...
                        vdToMatrixRowSelection(dTransferRowStart:dTransferRowEnd),...
                        vdToMatrixColSelection(:)) = ....
                        m2xFromMatrix(...
                        vdFromMatrixRowSelection(dTransferRowStart:dTransferRowEnd),...
                        vdFromMatrixColSelection(:));
                    
                    dTransferRowStart = dTransferRowEnd+1;
                end
            end
        end
        
        function mNxToMatrix = AssignContiguousBlock(mNxToMatrix, mNxFromMatrix, vdToLinearIndexRange, vdFromLinearIndexRange)
            % mNxToMatrix = AssignContiguousBlock(mNxToMatrix, mNxFromMatrix, vdToLinearIndexRange, vdFromLinearIndexRange)
            %
            % SYNTAX:
            %  mNxToMatrix = AssignContiguousBlock(mNxToMatrix, mNxFromMatrix, vdToLinearIndexRange, vdFromLinearIndexRange)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUTS:
            %  mNxToMatrix:
            %  mNxFromMatrix: 
            %  vdToLinearIndexRange:
            %  vdFromLinearIndexRange:
            
            % OUTPUTS:
            %  mNxToMatrix:
                        
            if vdToLinearIndexRange(2) - vdToLinearIndexRange(1) ~= vdFromLinearIndexRange(2) - vdFromLinearIndexRange(1)
                error(...
                    'MemoryEfficiencyUtils:AssignContiguousBlock:DimMismatch',...
                    'Assignment from and to ranges must be equal.');
            end
            
            dFromIndex = vdFromLinearIndexRange(1);
            
            for dToIndex = vdToLinearIndexRange(1): vdToLinearIndexRange(2)
                mNxToMatrix(dToIndex) = mNxFromMatrix(dFromIndex);
                
                dFromIndex = dFromIndex + 1;
            end
        end
    end
    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    
    methods (Access = private, Static = true)
        
    end
end

