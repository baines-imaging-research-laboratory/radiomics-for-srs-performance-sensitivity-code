classdef DicomRTDoseVolume < ImageVolume
    %DicomRTDoseVolume
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Jan 30, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        chFilePath = []
        stFileMetadata = []
    end    
    
    properties (Constant = true, GetAccess = private) 
        dSliceSpacingDifferenceErrorLimit_mm = 0.01
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = DicomRTDoseVolume(chFilePath)
            %obj = DicomRTDoseVolume(chFilePath)
            %
            % SYNTAX:
            %  obj = DicomRTDoseVolume(chFilePath)
            %
            % DESCRIPTION:
            %  Constructor for DicomRTDoseVolume
            %
            % INPUT ARGUMENTS:
            %  chFilePath: File path to a Dicom RT Dose file.
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            
            stFileMetadata = dicominfo(chFilePath);
            
            oImageVolumeGeometry = DicomRTDoseVolume.GetImageVolumeGeometryFromFileMetaData(stFileMetadata);
                        
            % super-class constructor
            obj@ImageVolume(oImageVolumeGeometry);            
            
            % set class properities
            obj.chFilePath = chFilePath;
            obj.stFileMetadata = stFileMetadata;
        end
        
        function stFileMetadata = GetFileMetadata(obj)
            % TODO
            
            stFileMetadata = obj.stFileMetadata;
        end        
        
        function chFilePath = GetOriginalFilePath(obj)
            % TODO
            
            chFilePath = obj.chFilePath;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@ImageVolume(obj);
        end
        
        function m3xImageData = LoadOriginalImageData(obj)
            % TODO
            m3xImageData = double(squeeze(dicomread(obj.chFilePath))) * obj.stFileMetadata.DoseGridScaling;
            m3xImageData = flip(m3xImageData,3);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function oImageVolumeGeometry = GetImageVolumeGeometryFromFileMetaData(stFileMetaData)
            % TODO
            
            [vdRowAxisUnitVector, vdColAxisUnitVector, vdFirstVoxelPosition_mm, vdVolumeDimensions, vdVoxelDimensions_mm] = ...
                DicomImageVolume.GetImageVolumeGeometryPortionsFromFileMetadata(stFileMetaData);
            
            vdSlicePositions_mm = stFileMetaData.GridFrameOffsetVector;
            
            vdSliceSpacings_mm = vdSlicePositions_mm(2:end) - vdSlicePositions_mm(1:end-1);
            
            if max(vdSliceSpacings_mm) - min(vdSliceSpacings_mm) > DicomRTDoseVolume.dSliceSpacingDifferenceErrorLimit_mm
                error(...
                    'DicomRTDoseVolume:GetImageVolumeGeometryFromFileMetaData:NonEqualSliceSpacings',...
                    'The slices within the dose volume were not found to be equally spaced.');
            end
            
            if any(vdSliceSpacings_mm < 0)
                error(...
                    'DicomRTDoseVolume:GetImageVolumeGeometryFromFileMetaData:ReverseSliceSpacing',...
                    'The slices within the dose volume were found to not be increasing in value.');
            end
            
            dSliceSpacing_mm = mean(vdSliceSpacings_mm);
            
            vdVolumeDimensions(3) = length(vdSlicePositions_mm);
            vdVoxelDimensions_mm(3) = dSliceSpacing_mm;
            
            vdFirstVoxelPosition_mm = vdFirstVoxelPosition_mm - max(vdSlicePositions_mm)*cross(vdRowAxisUnitVector, vdColAxisUnitVector);
            
            oImageVolumeGeometry = ImageVolumeGeometry(...
                vdVolumeDimensions,...
                vdRowAxisUnitVector, vdColAxisUnitVector,...
                vdVoxelDimensions_mm, vdFirstVoxelPosition_mm);
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


