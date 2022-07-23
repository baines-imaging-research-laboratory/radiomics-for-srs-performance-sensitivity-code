classdef MatrixCache < matlab.mixin.Copyable
    %MatrixCache
    %
    % ????
    
    % Primary Author: David DeVries
    % Created: Apr 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        m2dSparseMatrix % holds the actual matrix values. Will only be copied when "copy" is called on it
        
        c1c1vdDimensionSelectionRecords = {}
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        dCacheSize_Gb
        dNumValuesAllocatedInCache
        
        hGetValuesFromMaskFunction
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = MatrixCache(vdDims, dCacheSize_Gb, hGetValuesFromMaskFunction)
            %obj = MatrixCache(vdDims)
            %
            % SYNTAX:
            %  obj = MatrixCache(vdDims)
            %
            % DESCRIPTION:
            %  
            %
            % INPUT ARGUMENTS:
            %  vdDims: Dimensions of cache
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            obj.dNumValuesAllocatedInCache = MatrixCache.CalculateNumberOfValuesInCacheForSize(vdDims(2), dCacheSize_Gb);
            
            obj.m2dSparseMatrix = spalloc(vdDims(1), vdDims(2), obj.dNumValuesAllocatedInCache);
            obj.dCacheSize_Gb = dCacheSize_Gb;
            
            obj.hGetValuesFromMaskFunction = hGetValuesFromMaskFunction;
        end
        
        % >>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function varargout = size(obj, varargin)
            %varargout = size(obj, varargin)
            %
            % SYNTAX:
            %  varargout = size(obj, varargin) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "size" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  varargin: Refer to Matlab syntax
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = size(obj.m2dSparseMatrix, varargin{:});
        end
        
        function varargout = length(obj)
            %varargout = length(obj)
            %
            % SYNTAX:
            %  varargout = length(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "length" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = length(obj.m2dSparseMatrix);
        end
        
        function varargout = numel(obj)
            %varargout = numel(obj)
            %
            % SYNTAX:
            %  varargout = numel(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "numel" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = numel(obj.m2dSparseMatrix);
        end
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "disp" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            dNumUsed = nnz(obj.m2dSparseMatrix);
            dNumAvailable = obj.dNumValuesAllocatedInCache;
            
            vdDims = size(obj.m2dSparseMatrix);
            
            disp(['MatrixCache: ', num2str(vdDims(1)), '×', num2str(vdDims(2)) ...
            ' (Usage: ', num2str(dNumUsed) '/', num2str(dNumAvailable), ' [', num2str(100*dNumUsed/dNumAvailable), '%])']);
        end
        
        function m2dSelectedValues = GetSelection(obj, vdRowSelection, vdColSelection)
            %m2dSelectedValues = GetSelection(obj, vdRowSelection, vdColSelection)
            %
            % SYNTAX:
            %  m2dSelectedValues = GetSelection(obj, vdRowSelection, vdColSelection)
            %
            % DESCRIPTION:
            %  
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  vdRowSelection:
            %  vdColSelection:
            %
            % OUTPUTS ARGUMENTS:
            %  m2dSelectedValues:
            
            m2dSelectedValues = obj.m2dSparseMatrix(vdRowSelection, vdColSelection);
            
            if nnz(m2dSelectedValues) ~= length(vdRowSelection)*length(vdColSelection) % not all the values are in the cache
                obj.Add(vdRowSelection, vdColSelection);
                
                m2dSelectedValues = obj.m2dSparseMatrix(vdRowSelection, vdColSelection);
            end
            
            m2dSelectedValues = full(m2dSelectedValues);
            m2dSelectedValues(isnan(m2dSelectedValues)) = 0;
        end
        
        function Add(obj, vdRowSelection, vdColSelection)
            %Add(obj, vdRowSelection, vdColSelection)
            %
            % SYNTAX:
            %  Add(obj, vdRowSelection, vdColSelection)
            %
            % DESCRIPTION:
            %  
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  vdRowSelection:
            %  vdColSelection:
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            dNumValuesInRequest = length(vdRowSelection)*length(vdColSelection);
            
            if dNumValuesInRequest > obj.dNumValuesAllocatedInCache
                error(...
                    'MatrixCache:Add:OversizedRequest',...
                    ['The requested selection to load contains ', num2str(dNumValuesInRequest), ' values, whereas the cache can only contain ', num2str(obj.dNumValuesAllocatedInCache), ' values.']);
            end            
            
            m2bValuesInCache = obj.GetValuesInCacheMask();
            
            vdDims = size(obj.m2dSparseMatrix);
            
            m2bValuesRequired = sparse([],[],false,vdDims(1),vdDims(2),dNumValuesInRequest);
            m2bValuesRequired(vdRowSelection, vdColSelection) = true;
            
            m2bValuesRequired(m2bValuesInCache) = false;
            
            dNumValuesToAdd = nnz(m2bValuesRequired);
            
            while dNumValuesToAdd > obj.dNumValuesAllocatedInCache - nnz(obj.m2dSparseMatrix)
                clear('m2bValuesInCache');
                clear('m2bValuesRequired');
                
                obj.PopCacheEntry();
                
                m2bValuesInCache = obj.GetValuesInCacheMask();
                
                m2bValuesRequired = sparse([],[],false,obj.vdDims(1),obj.vdDims(2),dNumValuesInRequest);
                m2bValuesRequired(vdRowSelection, vdColSelection) = true;
                
                m2bValuesRequired(m2bValuesInCache) = false;
                
                dNumValuesToAdd = nnz(m2bValuesRequired);
            end
            
            if nnz(m2bValuesRequired) ~= 0
                m2dLoadedValues = obj.hGetValuesFromMaskFunction(m2bValuesRequired);
                
                m2dLoadedValues(m2dLoadedValues == 0) = NaN;
                
                obj.m2dSparseMatrix(m2bValuesRequired) = m2dLoadedValues;
            end
            
            % record what was required 
            c1vdDimensionSelectionRecord = {vdRowSelection, vdColSelection};
            
            obj.c1c1vdDimensionSelectionRecords{length(obj.c1c1vdDimensionSelectionRecords)+1} = c1vdDimensionSelectionRecord;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function [vbRowsInCache, vbColsInCache, dNumValuesToAdd] = CheckForExistingValues(obj, vdRowSelection, vdColSelection)
            vbRowsInCache = false(size(vdRowSelection));
            vbColsInCache = false(size(vdColSelection));
            
            dNumCacheEntries = length(obj.c1c1vdDimensionSelectionRecords);
            
            for dEntryIndex=1:dNumCacheEntries
                c1vdDimensionSelectionRecord = obj.c1c1vdDimensionSelectionRecords{dEntryIndex};
                
                vdRecordRows = c1vdDimensionSelectionRecord{1};
                vdRecordCols = c1vdDimensionSelectionRecord{2};
                
                if all(vdRowSelection == vdRecordRows) % all the rows are the same, we can remove some columns
                    [~,vdColIndicesInCache] = intersect(vdColSelection, vdRecordCols, 'stable');
                    
                    vbColsInCache(vdColIndicesInCache) = true;
                elseif all(vdColSelection == vdRecordCols) % all the cols are the same, we can remove some rows
                    [~,vdRowIndicesInCache] = intersect(vdRowSelection, vdRecordRows, 'stable');
                    
                    vbRowsInCache(vdRowIndicesInCache) = true;
                end
            end
        end
        
        function m2bValuesInCache = GetValuesInCacheMask(obj)
            
            % find worst-case scenario of how many values the mask will
            % have (e.g. no cache entries overlapped)
            dNumberOfNonZeros = 0;
            
            for dEntryIndex=1:length(obj.c1c1vdDimensionSelectionRecords)
                c1vdDimensionSelectionRecord = obj.c1c1vdDimensionSelectionRecords{dEntryIndex};
                
                vdRecordRows = c1vdDimensionSelectionRecord{1};
                vdRecordCols = c1vdDimensionSelectionRecord{2};
                
                dNumberOfNonZeros = dNumberOfNonZeros + length(vdRecordRows) * length(vdRecordCols);
            end
            
            
            % pre-allocate
            vdDims = size(obj.m2dSparseMatrix);
            m2bValuesInCache = sparse([],[],false,vdDims(1),vdDims(2),dNumberOfNonZeros);
            
            % set entry positions to true
            for dEntryIndex=1:length(obj.c1c1vdDimensionSelectionRecords)
                c1vdDimensionSelectionRecord = obj.c1c1vdDimensionSelectionRecords{dEntryIndex};
                
                vdRecordRows = c1vdDimensionSelectionRecord{1};
                vdRecordCols = c1vdDimensionSelectionRecord{2};
                
                m2bValuesInCache(vdRecordRows, vdRecordCols) = true;
            end
        end
        
        function PopCacheEntry(obj)
            dNumCacheEntries = length(obj.c1c1vdDimensionSelectionRecords);
            
            if dNumCacheEntries > 0
                c1vdDimensionSelectionEntry = obj.c1c1vdDimensionSelectionRecords{1};
                
                vdEntryRows = c1vdDimensionSelectionEntry{1};
                vdEntryCols = c1vdDimensionSelectionEntry{2};
                
                m2bValuesToRemove = sparse([],[],false,obj.vdDims(1),obj.vdDims(2),length(vdEntryRows)*length(vdEntryCols));
                                
                m2bValuesToRemove(vdEntryRows,vdEntryCols) = true;
                
                for dEntryIndex=2:dNumCacheEntries
                    c1vdDimensionSelectionEntry = obj.c1c1vdDimensionSelectionRecords{dEntryIndex};
                    
                    vdEntryRows = c1vdDimensionSelectionEntry{1};
                    vdEntryCols = c1vdDimensionSelectionEntry{2};
                    
                    m2bValuesToRemove(vdEntryRows, vdEntryCols) = false;
                end
                
                obj.m2dSparseMatrix(m2bValuesToRemove) = false; % remove values from cache
                obj.c1c1vdDimensionSelectionRecords{1} = []; % pop
            end
        end
    end
    
    methods (Access = private, Static = true)
        
        function dNumOfValuesInCache = CalculateNumberOfValuesInCacheForSize(dNumCols, dSizeOfCache_Gb)
            dSizeOfCache_B = dSizeOfCache_Gb .* 1E9;
            
            dBaseSize_B = 32; % 32 bytes for a 1x1 sparse matrix with 1 non-zero value
            
            dSizePerColumn_B = 8; % 8 bytes per column
            dSizePerValue_B = 16; % 16 bytes per value added
            
            dNumOfValuesInCache = floor( (dSizeOfCache_B - dBaseSize_B - (dNumCols * dSizePerColumn_B)) ./ dSizePerValue_B );
        end
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

