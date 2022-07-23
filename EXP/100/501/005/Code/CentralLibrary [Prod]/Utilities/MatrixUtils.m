classdef (Abstract) MatrixUtils
    %MatrixUtils
    %
    % Provides useful functions for working with matrices
    
    % Primary Author: David DeVries
    % Created: June 5, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function mDxCroppedMatrix = CropMatrixByCentreAndDimensions(mDxMatrix, vdCropCentreVoxelIndices, vdCropDimensions)
            %mDxCroppedMatrix = CropMatrixByCentreAndDimensions(mDxMatrix, vdCropCentreVoxelIndices, vdCropDimensions)
            %
            % SYNTAX:
            %  mDxCroppedMatrix = CropMatrixByCentreAndDimensions(mDxMatrix, vdCropCentreVoxelIndices, vdCropDimensions)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  mDxMatrix:
            %  vdCropCentreVoxelIndices: 
            %  vdCropDimensions:
            %
            % OUTPUTS ARGUMENTS:
            %  mDxCroppedMatrix:

            arguments
                mDxMatrix
                vdCropCentreVoxelIndices (1,:) double {mustBeFinite}
                vdCropDimensions (1,:) double {mustBeInteger, mustBePositive}
            end
            
            varargout = MatrixUtils.GetCropBoundsByCentreAndDimensions(vdCropCentreVoxelIndices, vdCropDimensions);
            
            dNumDims = length(varargout);
            
            c1xVarargin = cell(1,dNumDims);
            
            for dDim=1:dNumDims
                c1xVarargin{dDim} = varargout{dDim}(1) : varargout{dDim}(2);
            end
            
            mDxCroppedMatrix = mDxMatrix(c1xVarargin{:});
        end
        
        function mDxCroppedMatrix = CropMatrixByTopLeftAndDimensions(mDxMatrix, vdCropTopLeftVoxelIndices, vdCropDimensions)
            %mDxCroppedMatrix = CropMatrixByTopLeftAndDimensions(mDxMatrix, vdCropTopLeftVoxelIndices, vdCropDimensions)
            %
            % SYNTAX:
            %  mDxCroppedMatrix = CropMatrixByTopLeftAndDimensions(mDxMatrix, vdCropTopLeftVoxelIndices, vdCropDimensions)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  mDxMatrix:
            %  vdCropCentreVoxelIndices: 
            %  vdCropDimensions:
            %
            % OUTPUTS ARGUMENTS:
            %  mDxCroppedMatrix:

            arguments
                mDxMatrix
                vdCropTopLeftVoxelIndices (1,:) double {mustBeInteger, mustBePositive}
                vdCropDimensions (1,:) double {mustBeInteger, mustBePositive}
            end
            
            vdDims = size(mDxMatrix);
            
            if length(vdDims) ~= length(vdCropTopLeftVoxelIndices) || length(vdDims) ~= length(vdCropDimensions)
                error(...
                    'MatrixUtils:CropMatrixByTopLeftAndDimensions:InvalidDimensionsLength',...
                    'The number of matrix dimensions must equal those of the crop parameters.');
            end
            
            vdCropStartIndices = vdCropTopLeftVoxelIndices;
            vdCropEndIndices = vdCropTopLeftVoxelIndices + vdCropDimensions - 1;
            
            if any(vdCropEndIndices > vdDims)
                error(...
                    'MatrixUtils:CropMatrixByTopLeftAndDimensions:InvalidCropDimensions',...
                    'The crop extends beyond the dimensions of the matrix.');
            end
            
            c1xVarargin = cell(1, length(vdDims));
            
            for dDimIndex=1:length(vdDims)
                c1xVarargin{dDimIndex} = vdCropStartIndices(dDimIndex) : vdCropEndIndices(dDimIndex);
            end
            
            mDxCroppedMatrix = mDxMatrix(c1xVarargin{:});
        end
        
        function varargout = GetCropBoundsByCentreAndDimensions(vdCropCentreVoxelIndices, vdCropDimensions)
            %varargout = GetCropBoundsByCentreAndDimensions(vdCropCentreVoxelIndices, vdCropDimensions)
            %
            % SYNTAX:
            %  varargout = GetCropBoundsByCentreAndDimensions(vdCropCentreVoxelIndices, vdCropDimensions)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  vdCropCentreVoxelIndices: 
            %  vdCropDimensions:
            %
            % OUTPUTS ARGUMENTS:
            %  varargout:

            arguments
                vdCropCentreVoxelIndices (1,:) double {mustBeFinite}
                vdCropDimensions (1,:) double {mustBeInteger, mustBePositive}
            end
            
            dNumDims = length(vdCropCentreVoxelIndices);
            
            varargout = cell(1, dNumDims);
            
            for dDim = 1:dNumDims
                dHalfWidth = vdCropDimensions(dDim)/2;
                
                if rem(vdCropDimensions(dDim),2) == 0 % even
                    dCentre = round(vdCropCentreVoxelIndices(dDim));
                else % odd
                    dCentre = round(vdCropCentreVoxelIndices(dDim) - 0.5) + 0.5;
                end
                    
                varargout{dDim} = [(dCentre - dHalfWidth), (dCentre + dHalfWidth - 1)];
            end
            
            if nargout == 1 && dNumDims ~= 1 % if user only requests one output and there's multiple dimensions, all the selections are given in single cell array
                varargout = {varargout};
            end
        end
        
        function [vdIndexingVector, vbOriginalIndexRetained] = ApplySelectionToIndexMappingVectorWithMappingRemoval(vdIndexingVector, vdSelection)
            %[vdIndexingVector, vbOriginalIndexRetained] = ApplySelectionToIndexMappingVectorWithMappingRemoval(vdIndexingVector, vdSelection)
            %
            % SYNTAX:
            %  [vdIndexingVector, vbOriginalIndexRetained] = ApplySelectionToIndexMappingVectorWithMappingRemoval(vdIndexingVector, vdSelection)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  vdIndexingVector: 
            %  vdSelection:
            %
            % OUTPUTS ARGUMENTS:
            %  vdIndexingVector:
            %  vbOriginalIndexRetained:

            vdSelectedIndexingVector = vdIndexingVector(vdSelection);
            
            vdUniqueIndices = unique(vdSelectedIndexingVector);
            
            dMaxCurrentIndex = max(vdIndexingVector);
            
            vdPerIndexShift = zeros(1,dMaxCurrentIndex);
            vbOriginalIndexRetained = true(1,dMaxCurrentIndex);
            
            for dIndex = 1:dMaxCurrentIndex
                if isempty(find(vdUniqueIndices, dIndex)) % this index was completely removed through the selection
                    vdPerIndexShift(dIndex:end) = vdPerIndexShift(dIndex:end) - 1;
                    vbOriginalIndexRetained(dIndex) = false;
                end
            end
            
            for dIndex = 1:dMaxCurrentIndex
                vdSelectedIndexingVector(vdSelectedIndexingVector == dIndex) = dIndex + vdPerIndexShift(dIndex);
            end
        end
        
        function [vdIndexingVector, vxVectorOfObjects] = RemoveDuplicatedIndicesInVectorOfObjectsAndUpdateIndexingVector(vdIndexingVector, vxVectorOfObjects)
            %[vdIndexingVector, vxVectorOfObjects] = RemoveDuplicatedIndicesInVectorOfObjectsAndUpdateIndexingVector(vdIndexingVector, vxVectorOfObjects)
            %
            % SYNTAX:
            %  [vdIndexingVector, vxVectorOfObjects] = RemoveDuplicatedIndicesInVectorOfObjectsAndUpdateIndexingVector(vdIndexingVector, vxVectorOfObjects)
            %
            % DESCRIPTION:
            %  ???
            %
            % INPUT ARGUMENTS:
            %  vdIndexingVector: 
            %  vxVectorOfObjects:
            %
            % OUTPUTS ARGUMENTS:
            %  vdIndexingVector:
            %  vxVectorOfObjects:

            for dObjectIndex = 2:length(vxVectorOfObjects)
                oCurrentObject = vxVectorOfObjects(dObjectIndex);
                
                % check if already in it
                dMatchIndex = 0;
                
                for dSearchIndex = 1:dObjectIndex-1
                    if vxVectorOfObjects(dSearchIndex) == oCurrentObject
                        dMatchIndex = dSearchIndex;
                        break;
                    end
                end
                
                % deal with match, otherwise no changes to make
                if dMatchIndex ~= 0
                    vxVectorOfObjects = [vxVectorOfObjects(1:(dObjectIndex-1)) vxVectorOfObjects((dObjectIndex+1):end)]; % remove duplicate object
                    vdIndexingVector(vdIndexingVector == dObjectIndex) = dMatchIndex; % set indices that point to removed object to the matching one
                    vdIndexingVector(vdIndexingVector > dObjectIndex) = vdIndexingVector(vdIndexingVector > dObjectIndex) - 1; % bump all the other indices above the ones just changed down one
                end
            end
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
    
    methods (Access = private) % None
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

