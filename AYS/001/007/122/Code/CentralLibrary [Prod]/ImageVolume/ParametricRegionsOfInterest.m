classdef ParametricRegionsOfInterest < RegionsOfInterest
    %RegionsOfInterest
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public, Abstract = false)
        vdStartingBlockOriginMostCornerCoords = []
        vdBlockDimensions = []
        vdBlockOffset = []
        vdNumberOfBlocksPerDimension = []
        vdImageDimensions = []
        
        iGroupId = []
        iStartingSubGroupId = []
        sUserDefinedSampleStringPrefix = ""
        
        m2dBlockDisplayBounds
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
           
    methods (Access = public)
        
        function obj = ParametricRegionsOfInterest(vdStartingBlockCoords, vdBlockDimensions, vdNumberOfBlocksPerDimension, vdImageDimensions, iGroupId, iSubGroupIdStart, sUserDefinedSampleStringPrefix)
            %obj = ImageVolume(m3xImageData)
            %
            % SYNTAX:
            %  obj = LabelmapRegionsOfInterest(vdStartingBlockCoords, vdBlockDimensions, vdNumberBlocks, vdImageDimensions, iGroupId, iSubGroupIdStart, sUserDefinedSampleStringPrefix)
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %         long wrap it with tabs to align the second line, and
            %         then the third line will automatically be in line
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            dNumLabelMaps = prod(vdNumberOfBlocksPerDimension);
            
            % super-class call
            obj@RegionsOfInterest(dNumLabelMaps);
            
            
            % set properities
            obj.vdStartingBlockOriginMostCornerCoords = vdStartingBlockCoords;
            obj.vdBlockDimensions = vdBlockDimensions;
            obj.vdNumberOfBlocksPerDimension = vdNumberOfBlocksPerDimension;
            obj.vdImageDimensions = vdImageDimensions;
            
            obj.iGroupId = iGroupId;
            obj.iStartingSubGroupId = iSubGroupIdStart;
            obj.sUserDefinedSampleStringPrefix = sUserDefinedSampleStringPrefix;
        end      
        
        function [mNbLabelMap, iGroupId, iSubGroupId, sUserDefinedSampleString] = GetCurrentRegionOfInterestMask(obj)
            
            iGroupId = obj.viGroupIds(obj.dCurrentRegionOfInterestIndex);
            iSubGroupId = obj.viSubGroupIds(obj.dCurrentRegionOfInterestIndex);
            sUserDefinedSampleString = obj.vsUserDefinedSampleStrings(obj.dCurrentRegionOfInterestIndex);
            
            mNbLabelMap = logical(bitget(obj.mNiLabelMaps, obj.dCurrentRegionOfInterestIndex));            
        end
        
        function dNumRegionsOfInterest = GetNumberOfRegionsOfInterest(obj)
            dNumRegionsOfInterest = prod(obj.vdNumberBlocks);
        end
        
        function vdDims = GetRegionOfInterestDimensions(obj)
            vdDims = obj.vdImageDimensions;
        end
        
        function viGroupIds = GetGroupIds(obj)
            viGroupIds = repmat(obj.iGroupId, obj.GetNumberOfRegionsOfInterest(), 1);
        end
        
        function viSubGroupIds = GetSubGroupIds(obj)
            viSubGroupIds = transpose(obj.iStartingSubGroupId : 1 : obj.iStartingSubGroupId + obj.GetNumberOfRegionsOfInterest() - 1);
        end
        
        function vsUserDefinedSampleStrings = GetUserDefinedSampleStrings(obj)
            vsUserDefinedSampleStrings = strcat(obj.sUserDefinedSampleStringPrefix, strtrim(string(num2str(obj.GetGroupIds()))), "-", strtrim(string(num2str(obj.GetSubGroupIds()))));
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
        
        function [m3iRegionOfInterestBinnedImage, m3bRegionOfInterestBinnedImageMask] = ComputeCachedRegionOfInterestBinnedImageAndMask(obj, m3xImageData, oFeatureExtractorParameters)
            dRequiredCacheSize_Gb = prod(obj.vdBlockDimensions) .* (3) ./ 1E9; % 3 bytes for the uint32 image, no mask stored
            
            if dRequiredCacheSize_Gb > oFeatureExtractorParameters.GetMaxMemoryUsage_Gb()
                error('Must dedicate enough memory for at least one block to fit into memory');
            else
                dFirstBinEdge = oFeatureExtractorParameters.GetGLCMFirstBinEdge();
                dBinSize = oFeatureExtractorParameters.GetGLCMBinSize();
                
                [vdRowBounds, vdColBounds, vdSliceBounds] = obj.GetCurrentRegionOfInterestCoordinateBounds();
                                
                m3iRegionOfInterestBinnedImage = uint32( (m3xImageData(vdRowBounds(1):vdRowBounds(2), vdColBounds(1):vdColBounds(2), vdSliceBounds(1):vdSliceBounds(2)) - dFirstBinEdge + 1) ./ dBinSize );
                                
                m3bRegionOfInterestBinnedImageMask = []; % empty mask means all values in image are "true"                
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function [vdRowBounds, vdColBounds, vdSliceBounds] = GetCurrentRegionOfInterestCoordinateBounds(obj)
            vdNumberOfBlocksPerDimension = obj.vdNumberOfBlocksPerDimension;
            dCurrentRegionOfInterestIndex = obj.dCurrentRegionOfInterestIndex;
            
            vdBlockDimensions = obj.vdBlockDimensions;
            vdStartingBlockCoords = obj.vdStartingBlockOriginMostCornerCoords;
            
            [dBoxRowIndex, dBoxColIndex, dBoxSliceIndex] = ind2sub(vdNumberOfBlocksPerDimension, dCurrentRegionOfInterestIndex);
            
            vdRowBounds = [...
                vdStartingBlockCoords(1) + (dBoxRowIndex - 1)*vdBlockDimensions(1),...
                vdStartingBlockCoords(1) + dBoxRowIndex*vdBlockDimensions(1) - 1];
            
            vdColBounds = [...
                vdStartingBlockCoords(2) + (dBoxColIndex - 1)*vdBlockDimensions(2),...
                vdStartingBlockCoords(2) + dBoxColIndex*vdBlockDimensions(2) - 1];
            
            vdSliceBounds = [...
                vdStartingBlockCoords(2) + (dBoxSliceIndex - 1)*vdBlockDimensions(3),...
                vdStartingBlockCoords(2) + dBoxSliceIndex*vdBlockDimensions(3) - 1];
        end
    end
    
    
    methods (Access = private, Static = true) % None
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

