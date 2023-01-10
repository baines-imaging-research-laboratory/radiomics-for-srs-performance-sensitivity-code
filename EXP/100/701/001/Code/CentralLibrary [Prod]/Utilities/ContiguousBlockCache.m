classdef ContiguousBlockCache < matlab.mixin.Copyable
    %MatrixCache
    %
    % ????
    
    % Primary Author: David DeVries
    % Created: Apr 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        vdCacheEntriesRowStarts = []
        vdCacheEntriesRowEnds = []
        
        vdCacheEntriesColStarts = []
        vdCacheEntriesColEnds = []
        
        c1m2dContiguousBlocks = {}
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        oMatFile
        chMatFileMatrixVarName
        vdDims
        
        dCacheSize_Gb
        dNumValuesAllocatedInCache
        
        dMemorySpikeLimit_Gb
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = ContiguousBlockCache(oMatFileObject, chMatFileMatrixVarName, dCacheSize_Gb, dMemorySpikeLimit_Gb)
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
            
            
            % set access to .mat file on disk
            obj.oMatFile = oMatFileObject;
            obj.chMatFileMatrixVarName = chMatFileMatrixVarName;
            obj.vdDims = size(obj.oMatFile, obj.chMatFileMatrixVarName);
            
            % set cache memory limits
            obj.dNumValuesAllocatedInCache = floor(dCacheSize_Gb * 1E9 ./ 8);
            
            obj.dCacheSize_Gb = dCacheSize_Gb;
            obj.dMemorySpikeLimit_Gb = dMemorySpikeLimit_Gb;            
        end
        
        % >>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function vdDims = size(obj)
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
            
            vdDims = obj.vdDims;
        end
        
        function dNumel = numel(obj)
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
            
            dNumel = prod(obj.vdDims);
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
            
            disp(['MatrixCache: ', num2str(obj.vdDims(1)), '×', num2str(obj.vdDims(2))]);
        end
        
        function varargout = GetSelection(obj, vdRowSelection, vdColSelection, varargin)
            %varargout = GetSelection(obj, vdRowSelection, vdColSelection, varargin)
            %
            % SYNTAX:
            %  m2dSelectedValues = obj.GetSelection(vdRowSelection, vdColSelection)
            %  [m2dSelectedValuesInBlocks, vdRowIndexMapping, vdColIndexMapping] = obj.GetSelection(vdRowSelection, vdColSelection, 'ReturnIndexMappings', bReturnIndexMappings)
            %
            % DESCRIPTION:
            %  Passes the "disp" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            
            [vdBlockRowStarts, vdBlockRowEnds, vdBlockColStarts, vdBlockColEnds, vdRowSortIndices, vdColSortIndices, vdRowIndicesToDuplicate] = ...
                ContiguousBlockCache.GroupSelectionsInBlocks(vdRowSelection, vdColSelection);
            
            m2dSelectedValues = zeros(length(vdRowSelection), length(vdColSelection));
            
            dNumRowBlocks = length(vdBlockRowStarts);
            dNumColBlocks = length(vdBlockColStarts);
            
            vdUnloadedBlocksRowStarts = [];
            vdUnloadedBlocksRowEnds = [];
            
            vdUnloadedBlocksColStarts = [];
            vdUnloadedBlocksColEnds = [];
            
            vdUnloadedBlocksOriginInSelectedValuesRowIndices = [];
            vdUnloadedBlocksOriginInSelectedValuesColIndices = [];
            
            dBlockOriginInSelectedValuesRowIndex = 1;
            dBlockOriginInSelectedValuesColIndex = 1;
            
            % load up from cache as much as possible
            for dRowBlockIndex=1:dNumRowBlocks
                dBlockRowStart = vdBlockRowStarts(dRowBlockIndex);
                dBlockRowEnd = vdBlockRowEnds(dRowBlockIndex);
                
                for dColBlockIndex=1:dNumColBlocks
                    dBlockColStart = vdBlockColStarts(dColBlockIndex);
                    dBlockColEnd = vdBlockColEnds(dColBlockIndex);
                    
                   [m2dSelectedValues,... 
                       vdUnloadedBlocksOriginInSelectedValuesRowIndicesForBlock, vdUnloadedBlocksOriginInSelectedValuesColIndicesForBlock,...
                       vdUnloadedBlocksRowStartsForBlock, vdUnloadedBlocksRowEndsForBlock,...
                       vdUnloadedBlocksColStartsForBlock, vdUnloadedBlocksColEndsForBlock] ...
                        = obj.GetContiguousBlockFromCache(...
                        m2dSelectedValues,...
                        dBlockOriginInSelectedValuesRowIndex, dBlockOriginInSelectedValuesColIndex,...
                        dBlockRowStart, dBlockRowEnd,...
                        dBlockColStart, dBlockColEnd);
                    
                    vdUnloadedBlocksOriginInSelectedValuesRowIndices = [vdUnloadedBlocksOriginInSelectedValuesRowIndices, vdUnloadedBlocksOriginInSelectedValuesRowIndicesForBlock];
                    vdUnloadedBlocksOriginInSelectedValuesColIndices = [vdUnloadedBlocksOriginInSelectedValuesColIndices, vdUnloadedBlocksOriginInSelectedValuesColIndicesForBlock];
                    
                    vdUnloadedBlocksRowStarts = [vdUnloadedBlocksRowStarts, vdUnloadedBlocksRowStartsForBlock];
                    vdUnloadedBlocksRowEnds = [vdUnloadedBlocksRowEnds, vdUnloadedBlocksRowEndsForBlock];
                    
                    vdUnloadedBlocksColStarts = [vdUnloadedBlocksColStarts, vdUnloadedBlocksColStartsForBlock];
                    vdUnloadedBlocksColEnds = [vdUnloadedBlocksColEnds, vdUnloadedBlocksColEndsForBlock];
                    
                    dBlockOriginInSelectedValuesColIndex = dBlockOriginInSelectedValuesColIndex + (dBlockColEnd - dBlockColStart) + 1;
                end
                
                dBlockOriginInSelectedValuesRowIndex = dBlockOriginInSelectedValuesRowIndex + (dBlockRowEnd - dBlockRowStart) + 1;
                dBlockOriginInSelectedValuesColIndex = 1;
            end
            
            % get the unloaded blocks from the data source
            disp(['Num Disk Hits: ', num2str(length(vdUnloadedBlocksRowStarts))]);
            
            for dUnloadedBlockIndex=1:length(vdUnloadedBlocksRowStarts)
                m2dSelectedValues = obj.GetContiguousBlockFromDataSource(...
                    m2dSelectedValues,...
                    vdUnloadedBlocksOriginInSelectedValuesRowIndices(dUnloadedBlockIndex), vdUnloadedBlocksOriginInSelectedValuesColIndices(dUnloadedBlockIndex),...
                    vdUnloadedBlocksRowStarts(dUnloadedBlockIndex), vdUnloadedBlocksRowEnds(dUnloadedBlockIndex),...                    
                    vdUnloadedBlocksColStarts(dUnloadedBlockIndex), vdUnloadedBlocksColEnds(dUnloadedBlockIndex));
            end
            
            % cache the current blocks, popping of the oldest cache values
            % as needed
            obj.AddBlocksToCache(m2dSelectedValues, vdBlockRowStarts, vdBlockRowEnds, vdBlockColStarts, vdBlockColEnds);
            
            % add in duplicate rows
            dNumDuplicateRows = length(vdRowIndicesToDuplicate);
            m2dSelectedValues(end - dNumDuplicateRows + 1 : end, :) = m2dSelectedValues(vdRowIndicesToDuplicate, :);
            
            % rearrange rows/cols out of blocks into requested selection
            % order or return as is and provide row/col mappings
            bReturnIndexMappings = false;
            
            if length(varargin) == 2 && strcmp(varargin{1}, 'ReturnIndexMappings')
                bReturnIndexMappings = varargin{2};
            end
            
            if bReturnIndexMappings
                varargout = {m2dSelectedValues, vdRowSortIndices, vdColSortIndices};
            else
                % rearrange the values matrix to match the order in which the
                % rows/cols were request
                m2dSelectedValues = MemoryEfficiencyUtils.ReindexRowsInPlace(m2dSelectedValues, vdRowSortIndices);
                m2dSelectedValues = MemoryEfficiencyUtils.ReindexColumnsInPlace(m2dSelectedValues, vdColSortIndices);
                
                varargout = {m2dSelectedValues};
            end
        end
        
        function Clear(obj)
            obj.vdCacheEntriesRowStarts = [];
            obj.vdCacheEntriesRowEnds = [];
            
            obj.vdCacheEntriesColStarts = [];
            obj.vdCacheEntriesColEnds = [];
            
            obj.c1m2dContiguousBlocks = {};
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
        
        function [m2dSelectedValues, vdAllUnloadedBlocksOriginInValuesRowIndices, vdAllUnloadedBlocksOriginInValuesColIndices, vdAllUnloadedBlocksRowStarts, vdAllUnloadedBlocksRowEnds, vdAllUnloadedBlocksColStarts, vdAllUnloadedBlocksColEnds] = GetContiguousBlockFromCache(obj, m2dSelectedValues, dBlockOriginInValuesRowIndex, dBlockOriginInValuesColIndex, dBlockRowStart, dBlockRowEnd, dBlockColStart, dBlockColEnd)
            
            dMaxBlockInCacheIndex = obj.GetHighestIntersectingBlockFromCacheIndex(dBlockRowStart, dBlockRowEnd, dBlockColStart, dBlockColEnd);
            
            if ~isempty(dMaxBlockInCacheIndex)
                [dRowIntersectionStart, dRowIntersectionEnd] = ...
                    ContiguousBlockCache.CalculateIntersection(...
                    dBlockRowStart, dBlockRowEnd,...
                    obj.vdCacheEntriesRowStarts(dMaxBlockInCacheIndex), obj.vdCacheEntriesRowEnds(dMaxBlockInCacheIndex));
                
                [dColIntersectionStart, dColIntersectionEnd] = ...
                    ContiguousBlockCache.CalculateIntersection(...
                    dBlockColStart, dBlockColEnd,...
                    obj.vdCacheEntriesColStarts(dMaxBlockInCacheIndex), obj.vdCacheEntriesColEnds(dMaxBlockInCacheIndex));
                
                % load in values from cache entry
                m2dSelectedValues = MemoryEfficiencyUtils.AssignSubMatrix(...
                    m2dSelectedValues,...
                    dBlockOriginInValuesRowIndex + (dRowIntersectionStart - dBlockRowStart) : dBlockOriginInValuesRowIndex + (dRowIntersectionEnd-dBlockRowStart),...
                    dBlockOriginInValuesColIndex + (dColIntersectionStart - dBlockColStart) : dBlockOriginInValuesColIndex + (dColIntersectionEnd - dBlockColStart),...
                    obj.c1m2dContiguousBlocks{dMaxBlockInCacheIndex},...
                    (dRowIntersectionStart:dRowIntersectionEnd) - obj.vdCacheEntriesRowStarts(dMaxBlockInCacheIndex) + 1,...
                    (dColIntersectionStart:dColIntersectionEnd) - obj.vdCacheEntriesColStarts(dMaxBlockInCacheIndex) + 1,...
                    obj.dMemorySpikeLimit_Gb);
                
                % create sub-blocks of parts of the block that were
                % unloaded
                
                % Requested Block:
                %
                % +-----------------------+
                % |      Top Block        |
                % |                       | 
                % +------+--------+-------+
                % |Left  | Loaded | Right |
                % |Block | Cached | Block |
                % |      | Block  |       |
                % +------+--------+-------+
                % |    Bottom Block       |
                % |                       |
                % +-----------------------+
                
                vdUnloadedBlocksOriginInValuesRowIndices = [];
                vdUnloadedBlocksOriginInValuesColIndices = [];
                
                vdUnloadedBlocksRowStarts = [];
                vdUnloadedBlocksRowEnds = [];
                
                vdUnloadedBlocksColStarts = [];
                vdUnloadedBlocksColEnds = [];
                
                
                if dRowIntersectionStart > dBlockRowStart % top block required
                    vdUnloadedBlocksOriginInValuesRowIndices = [vdUnloadedBlocksOriginInValuesRowIndices, dBlockOriginInValuesRowIndex];
                    vdUnloadedBlocksOriginInValuesColIndices = [vdUnloadedBlocksOriginInValuesColIndices, dBlockOriginInValuesColIndex];
                    
                    vdUnloadedBlocksRowStarts = [vdUnloadedBlocksRowStarts, dBlockRowStart];
                    vdUnloadedBlocksRowEnds = [vdUnloadedBlocksRowEnds, dRowIntersectionStart - 1];
                    
                    vdUnloadedBlocksColStarts = [vdUnloadedBlocksColStarts, dBlockColStart];
                    vdUnloadedBlocksColEnds = [vdUnloadedBlocksColEnds, dBlockColEnd];
                end
                                
                if dRowIntersectionEnd < dBlockRowEnd % bottom block required
                    vdUnloadedBlocksOriginInValuesRowIndices = [vdUnloadedBlocksOriginInValuesRowIndices, dBlockOriginInValuesRowIndex + (dRowIntersectionEnd - dBlockRowStart) + 1];
                    vdUnloadedBlocksOriginInValuesColIndices = [vdUnloadedBlocksOriginInValuesColIndices, dBlockOriginInValuesColIndex];
                    
                    vdUnloadedBlocksRowStarts = [vdUnloadedBlocksRowStarts, dRowIntersectionEnd + 1];
                    vdUnloadedBlocksRowEnds = [vdUnloadedBlocksRowEnds, dBlockRowEnd];
                    
                    vdUnloadedBlocksColStarts = [vdUnloadedBlocksColStarts, dBlockColStart];
                    vdUnloadedBlocksColEnds = [vdUnloadedBlocksColEnds, dBlockColEnd];
                end
                                                
                if dColIntersectionStart > dBlockColStart % left block required
                    vdUnloadedBlocksOriginInValuesRowIndices = [vdUnloadedBlocksOriginInValuesRowIndices, dBlockOriginInValuesRowIndex + (dRowIntersectionStart - dBlockRowStart)];
                    vdUnloadedBlocksOriginInValuesColIndices = [vdUnloadedBlocksOriginInValuesColIndices, dBlockOriginInValuesColIndex];
                    
                    vdUnloadedBlocksRowStarts = [vdUnloadedBlocksRowStarts, dRowIntersectionStart];
                    vdUnloadedBlocksRowEnds = [vdUnloadedBlocksRowEnds, dRowIntersectionEnd];
                    
                    vdUnloadedBlocksColStarts = [vdUnloadedBlocksColStarts, dBlockColStart];
                    vdUnloadedBlocksColEnds = [vdUnloadedBlocksColEnds, dColIntersectionStart - 1];
                end
                                                
                if dColIntersectionEnd < dBlockColEnd % right block required
                    vdUnloadedBlocksOriginInValuesRowIndices = [vdUnloadedBlocksOriginInValuesRowIndices, dBlockOriginInValuesRowIndex + (dRowIntersectionStart - dBlockRowStart)];
                    vdUnloadedBlocksOriginInValuesColIndices = [vdUnloadedBlocksOriginInValuesColIndices, dBlockOriginInValuesColIndex + (dColIntersectionEnd - dBlockColStart) + 1];
                    
                    vdUnloadedBlocksRowStarts = [vdUnloadedBlocksRowStarts, dRowIntersectionStart];
                    vdUnloadedBlocksRowEnds = [vdUnloadedBlocksRowEnds, dRowIntersectionEnd];
                    
                    vdUnloadedBlocksColStarts = [vdUnloadedBlocksColStarts, dColIntersectionEnd + 1];
                    vdUnloadedBlocksColEnds = [vdUnloadedBlocksColEnds, dBlockColEnd];
                end
                
                % attempt to load all or parts of these blocks from the
                % cache
                
                vdAllUnloadedBlocksOriginInValuesRowIndices = [];
                vdAllUnloadedBlocksOriginInValuesColIndices = [];
                
                vdAllUnloadedBlocksRowStarts = [];
                vdAllUnloadedBlocksRowEnds = [];
                
                vdAllUnloadedBlocksColStarts = [];
                vdAllUnloadedBlocksColEnds = [];
                
                for dUnloadedBlockIndex=1:length(vdUnloadedBlocksRowStarts)
                    [m2dSelectedValues,...
                        vdBlockOriginInValuesRowIndicesForUnloadedBlock, vdBlockOriginInValuesInsertColIndicesForUnloadedBlock,...
                        vdRowStartsForUnloadedBlock, vdRowEndsForUnloadedBlock,...
                        vdColStartsForUnloadedBlock, vdColEndsForUnloadedBlock] =...
                        obj.GetContiguousBlockFromCache(...
                        m2dSelectedValues,...
                        vdUnloadedBlocksOriginInValuesRowIndices(dUnloadedBlockIndex), vdUnloadedBlocksOriginInValuesColIndices(dUnloadedBlockIndex),...
                        vdUnloadedBlocksRowStarts(dUnloadedBlockIndex), vdUnloadedBlocksRowEnds(dUnloadedBlockIndex),...
                        vdUnloadedBlocksColStarts(dUnloadedBlockIndex), vdUnloadedBlocksColEnds(dUnloadedBlockIndex));
                    
                    vdAllUnloadedBlocksOriginInValuesRowIndices = [vdAllUnloadedBlocksOriginInValuesRowIndices, vdBlockOriginInValuesRowIndicesForUnloadedBlock];
                    vdAllUnloadedBlocksOriginInValuesColIndices = [vdAllUnloadedBlocksOriginInValuesColIndices, vdBlockOriginInValuesInsertColIndicesForUnloadedBlock];
                    
                    vdAllUnloadedBlocksRowStarts = [vdAllUnloadedBlocksRowStarts, vdRowStartsForUnloadedBlock];
                    vdAllUnloadedBlocksRowEnds = [vdAllUnloadedBlocksRowEnds, vdRowEndsForUnloadedBlock];
                    
                    vdAllUnloadedBlocksColStarts = [vdAllUnloadedBlocksColStarts, vdColStartsForUnloadedBlock];
                    vdAllUnloadedBlocksColEnds = [vdAllUnloadedBlocksColEnds, vdColEndsForUnloadedBlock];
                end
            else
                vdAllUnloadedBlocksOriginInValuesRowIndices = dBlockOriginInValuesRowIndex;
                vdAllUnloadedBlocksOriginInValuesColIndices = dBlockOriginInValuesColIndex;
                
                vdAllUnloadedBlocksRowStarts = dBlockRowStart;
                vdAllUnloadedBlocksRowEnds = dBlockRowEnd;
                
                vdAllUnloadedBlocksColStarts = dBlockColStart;
                vdAllUnloadedBlocksColEnds = dBlockColEnd;
            end
        end
        
        function m2dSelectedValues = GetContiguousBlockFromDataSource(obj, m2dSelectedValues, dBlockOriginInValuesRowIndex, dBlockOriginInValuesColIndex, dBlockRowStart, dBlockRowEnd, dBlockColStart, dBlockColEnd)
            %m2dSelectedValues = obj.hContiguousBlockDataSource(m2dSelectedValues, dBlockOriginInValuesRowIndex, dBlockOriginInValuesColIndex, dBlockRowStart, dBlockRowEnd, dBlockColStart, dBlockColEnd); 
            %m2dSelectedValues = obj.hContiguousBlockDataSource.GetAndSetNonDuplicatedUnstandardizedFeaturesContiguousBlock(m2dSelectedValues, dBlockOriginInValuesRowIndex, dBlockOriginInValuesColIndex, dBlockRowStart, dBlockRowEnd, dBlockColStart, dBlockColEnd); 
            
            dRowLength = dBlockRowEnd - dBlockRowStart + 1;
            dColLength = dBlockColEnd - dBlockColStart + 1;
            
            m2dSelectedValues(dBlockOriginInValuesRowIndex : dBlockOriginInValuesRowIndex+dRowLength-1, dBlockOriginInValuesColIndex : dBlockOriginInValuesColIndex+dColLength-1)...
                = obj.oMatFile.(obj.chMatFileMatrixVarName)...
                (dBlockRowStart:dBlockRowEnd, dBlockColStart:dBlockColEnd);
        end
        
        function AddBlocksToCache(obj, m2dValues, vdBlockRowStarts, vdBlockRowEnds, vdBlockColStarts, vdBlockColEnds)
            dNumValuesToAdd = numel(m2dValues);
            
            dMaxNumValues = obj.dNumValuesAllocatedInCache;
            
            if dNumValuesToAdd > dMaxNumValues
                % to large to cache, so dump the cache
                
                obj.vdCacheEntriesRowStarts = [];
                obj.vdCacheEntriesRowEnds = [];
                
                obj.vdCacheEntriesColStarts = [];
                obj.vdCacheEntriesColEnds = [];
                
                obj.c1m2dContiguousBlocks = {};
            else            
                dNumValuesUsed = obj.GetNumValuesInCache;
                
                dNumValuesToPop = (dNumValuesToAdd + dNumValuesUsed) - dMaxNumValues;
                                
                dCacheEntryIndex = 0;
                
                while dNumValuesToPop > 0                    
                    dCacheEntryIndex = dCacheEntryIndex + 1;
                    
                    dNumValuesToPop = dNumValuesToPop - ...
                        (obj.vdCacheEntriesRowEnds(dCacheEntryIndex) - obj.vdCacheEntriesRowStarts(dCacheEntryIndex)) * (obj.vdCacheEntriesColEnds(dCacheEntryIndex) - obj.vdCacheEntriesColStarts(dCacheEntryIndex));                    
                end
                
                obj.PopNumEntriesOffCache(dCacheEntryIndex);
                obj.PushEntriesOntoCache(m2dValues, vdBlockRowStarts, vdBlockRowEnds, vdBlockColStarts, vdBlockColEnds);
            end
        end
        
        function dNumValuesInCache = GetNumValuesInCache(obj)
            vdRowLengths = obj.vdCacheEntriesRowEnds - obj.vdCacheEntriesRowStarts + 1;
            vdColLengths = obj.vdCacheEntriesColEnds - obj.vdCacheEntriesColStarts + 1;
            
            dNumValuesInCache = sum(vdRowLengths .* vdColLengths);
        end
        
        function PopNumEntriesOffCache(obj, dNumEntriesToPop)
            obj.vdCacheEntriesRowStarts = obj.vdCacheEntriesRowStarts(dNumEntriesToPop+1 : end);
            obj.vdCacheEntriesRowEnds = obj.vdCacheEntriesRowEnds(dNumEntriesToPop+1 : end);
            
            obj.vdCacheEntriesColStarts = obj.vdCacheEntriesColStarts(dNumEntriesToPop+1 : end);
            obj.vdCacheEntriesColEnds = obj.vdCacheEntriesColEnds(dNumEntriesToPop+1 : end);
            
            obj.c1m2dContiguousBlocks = obj.c1m2dContiguousBlocks(dNumEntriesToPop+1 : end);
        end
        
        function PushEntriesOntoCache(obj, m2dValues, vdBlockRowStarts, vdBlockRowEnds, vdBlockColStarts, vdBlockColEnds)
            dNumRowBlocksToAdd = length(vdBlockRowStarts);
            dNumColBlocksToAdd = length(vdBlockColStarts);
            
            vdCacheEntriesRowStartsToAdd = zeros(1,dNumRowBlocksToAdd*dNumColBlocksToAdd);
            vdCacheEntriesRowEndsToAdd = zeros(1,dNumRowBlocksToAdd*dNumColBlocksToAdd);
            
            vdCacheEntriesColStartsToAdd = zeros(1,dNumRowBlocksToAdd*dNumColBlocksToAdd);
            vdCacheEntriesColEndsToAdd = zeros(1,dNumRowBlocksToAdd*dNumColBlocksToAdd);
            
            c1m2dBlockValuesToAdd = cell(1,dNumRowBlocksToAdd*dNumColBlocksToAdd);
            
            dRowIndexCounter = 1;
            dColIndexCounter = 1;
            
            dBlockCounter = 1;
            
            for dRowBlockIndex=1:dNumRowBlocksToAdd
                dRowBlockLength = vdBlockRowEnds(dRowBlockIndex) - vdBlockRowStarts(dRowBlockIndex) + 1;
                
                for dColBlockIndex=1:dNumColBlocksToAdd
                    dColBlockLength = vdBlockColEnds(dColBlockIndex) - vdBlockColStarts(dColBlockIndex) + 1;
                    
                    c1m2dBlockValuesToAdd{dBlockCounter} = m2dValues(...
                        dRowIndexCounter:dRowIndexCounter + dRowBlockLength - 1,...
                        dColIndexCounter:dColIndexCounter + dColBlockLength - 1);
                    
                    vdCacheEntriesRowStartsToAdd(dBlockCounter) = vdBlockRowStarts(dRowBlockIndex);
                    vdCacheEntriesRowEndsToAdd(dBlockCounter) = vdBlockRowEnds(dRowBlockIndex);
                    
                    vdCacheEntriesColStartsToAdd(dBlockCounter) = vdBlockColStarts(dColBlockIndex);
                    vdCacheEntriesColEndsToAdd(dBlockCounter) = vdBlockColEnds(dColBlockIndex);
                    
                    dColIndexCounter = dColIndexCounter + dColBlockLength;
                    dBlockCounter = dBlockCounter + 1;
                end
                
                dColIndexCounter = 1;
                dRowIndexCounter = dRowIndexCounter + dRowBlockLength;
            end
            
            obj.c1m2dContiguousBlocks = [obj.c1m2dContiguousBlocks, c1m2dBlockValuesToAdd];
            
            obj.vdCacheEntriesRowStarts = [obj.vdCacheEntriesRowStarts, vdCacheEntriesRowStartsToAdd];
            obj.vdCacheEntriesRowEnds = [obj.vdCacheEntriesRowEnds, vdCacheEntriesRowEndsToAdd];
            
            obj.vdCacheEntriesColStarts = [obj.vdCacheEntriesColStarts, vdCacheEntriesColStartsToAdd];
            obj.vdCacheEntriesColEnds = [obj.vdCacheEntriesColEnds, vdCacheEntriesColEndsToAdd];
        end
        
        function dHighestIntersectionIndex = GetHighestIntersectingBlockFromCacheIndex(obj, dBlockRowStart, dBlockRowEnd, dBlockColStart, dBlockColEnd)
            
            dRowIntersectionStart = max(dBlockRowStart, obj.vdCacheEntriesRowStarts);
            dRowIntersectionEnd = min(dBlockRowEnd, obj.vdCacheEntriesRowEnds);
            
            dRowIntersectionLength = dRowIntersectionEnd - dRowIntersectionStart + 1;
            dRowIntersectionLength = max(dRowIntersectionLength,0);
                        
            dColIntersectionStart = max(dBlockColStart, obj.vdCacheEntriesColStarts);
            dColIntersectionEnd = min(dBlockColEnd, obj.vdCacheEntriesColEnds);
            
            dColIntersectionLength = dColIntersectionEnd - dColIntersectionStart + 1;
            dColIntersectionLength = max(dColIntersectionLength,0);
            
            dIntersectionAreas = dRowIntersectionLength.*dColIntersectionLength;
            
            [~,dHighestIntersectionIndex] = max(dIntersectionAreas);
            
            if dIntersectionAreas(dHighestIntersectionIndex) == 0
                dHighestIntersectionIndex = []; % no intersections
            end
        end
    end
    
    methods (Access = private, Static = true)
        
        function [vdBlockRowStarts, vdBlockRowEnds, vdBlockColStarts, vdBlockColEnds, vdRowSortIndices, vdColSortIndices, vdRowIndicesToDuplicate] = GroupSelectionsInBlocks(vdRowSelection, vdColSelection)
            % sort rows and find duplicates
            [vdSortedRowSelection,vdRowUniqueIndices, vdRowSortIndices] = unique(vdRowSelection);
            vdDuplicateRowIndices = setdiff(1:length(vdRowSelection), vdRowUniqueIndices);
            vdRowIndicesToDuplicate = vdRowSortIndices(vdDuplicateRowIndices);
            
            dNumDuplicates = length(vdDuplicateRowIndices);
            dNumRowsIncludingDuplicates = length(vdRowSelection);
            
            % all the duplicates will be stored in the last rows
            vdRowSortIndices(vdDuplicateRowIndices) = dNumRowsIncludingDuplicates - dNumDuplicates + 1 : dNumRowsIncludingDuplicates; 
            vdRowSortIndices = vdRowSortIndices'; % want it as a row vector 
            
            % sort the columns (no duplicates in these
            [vdSortedColSelection, vdColSortIndices] = sort(vdColSelection, 'ascend');
                        
            % transforms increment by 1 runs into runs of the same number
            vdRowSelectionRuns = vdSortedRowSelection - (1:length(vdSortedRowSelection));
            vdColSelectionRuns = vdSortedColSelection - (1:length(vdSortedColSelection));
            
            [~,vdBlockRowStartIndices] = unique(vdRowSelectionRuns, 'stable');
            [~,vdBlockColStartIndices] = unique(vdColSelectionRuns, 'stable');
            
            vdBlockRowStarts = vdSortedRowSelection(vdBlockRowStartIndices);
            vdBlockColStarts = vdSortedColSelection(vdBlockColStartIndices);
            
            vdBlockRowEnds = [vdSortedRowSelection(vdBlockRowStartIndices(2:end)-1), vdSortedRowSelection(end)];
            vdBlockColEnds = [vdSortedColSelection(vdBlockColStartIndices(2:end)-1), vdSortedColSelection(end)];
        end
        
        function dBlockInCacheRatio = GetRatioOfBlockWithinAnotherBlock(dBlock1RowStart, dBlock1RowEnd, dBlock1ColStart, dBlock1ColEnd, dBlock2RowStart, dBlock2RowEnd, dBlock2ColStart, dBlock2ColEnd)
            dRowIntersectionLength = ContiguousBlockCache.CalculateIntersectionLength(dBlock1RowStart, dBlock1RowEnd, dBlock2RowStart, dBlock2RowEnd);
            dColIntersectionLength = ContiguousBlockCache.CalculateIntersectionLength(dBlock1ColStart, dBlock1ColEnd, dBlock2ColStart, dBlock2ColEnd);
            
            dBlock1RowLength = dBlock1RowEnd - dBlock1RowStart + 1;
            dBlock1ColLength = dBlock1ColEnd - dBlock1ColStart + 1;
            
            dBlockInCacheRatio = (dRowIntersectionLength * dColIntersectionLength) / (dBlock1RowLength * dBlock1ColLength);
        end
        
        function dIntersectionLength = CalculateIntersectionLength(dBlock1Start, dBlock1End, dBlock2Start, dBlock2End)
            [dIntersectionStart, dIntersectionEnd] = ContiguousBlockCache.CalculateIntersection(dBlock1Start, dBlock1End, dBlock2Start, dBlock2End);
            
            if isempty(dIntersectionStart)
                dIntersectionLength = 0;
            else
                dIntersectionLength = dIntersectionEnd - dIntersectionStart + 1;
            end
        end
        
        function [dIntersectionStart, dIntersectionEnd] = CalculateIntersection(dBlock1Start, dBlock1End, dBlock2Start, dBlock2End)
            if dBlock2Start > dBlock1End || dBlock1Start > dBlock2End
                dIntersectionStart = [];
                dIntersectionEnd = [];
            else
                dIntersectionStart = max(dBlock1Start, dBlock2Start);
                dIntersectionEnd = min(dBlock1End, dBlock2End);
            end
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

