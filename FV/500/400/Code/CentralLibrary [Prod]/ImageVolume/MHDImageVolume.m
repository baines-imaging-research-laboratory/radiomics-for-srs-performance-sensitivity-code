classdef MHDImageVolume < ImageVolume
    %MHDImageVolume
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        chMhdFilePath = []
        chRawFilePath = []
        
        stFileMetadata = []
    end    
    
    properties (Constant = true, GetAccess = {?MHDLabelMapRegionsOfInterest})
        chMhdFileExt = '.mhd'
        chRawFileExt = '.raw'
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = MHDImageVolume(chMhdFilePathOrName, varargin)
            %obj = MHDImageVolume(chFilePath)
            %obj = MHDImageVolume(chFilePath, oRegionsOfInterest)
            %
            % SYNTAX:
            %  obj = MHDImageVolume(sFeatureSource, chFilePath, oRegionsOfInterest, sUserDefinedIdTag)
            %  obj = MATLABImageVolume(__, __, __, __, vdDisplayMinMax)
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
            
            chMhdFilePath = FileIOUtils.GetAbsolutePathForExistingFiles(chMhdFilePathOrName);
            
            % Checks that the file exists
            if isempty(chMhdFilePath)
                error("MHDImageVolume:FileNotFound",...
                    "File not found." + newline + "Path: " +...
                    StringUtils.MakePathStringValidForPrinting(string(chMhdFilePathOrName)));
            end

            stFileMetaData = mha_read_header(chMhdFilePath);
            
            % Check that the raw file exists in the same directory, as the reader requires it
            chRawFilePath = fullfile(fileparts(chMhdFilePath), stFileMetaData.DataFile);
            if exist(chRawFilePath,'file') ~= 2
                error("MHDImageVolume:Constrcutor",...
                    "Raw file is not in the same directory as the .mhd image.")
            end
            
            oImageVolumeGeometry = MHDImageVolume.GetImageVolumeGeometryFromFileMetaData(stFileMetaData);
                          
            if ~isempty(varargin)
                oRegionsOfInterest = varargin{1};
                
                c1xSuperArgs = {oImageVolumeGeometry, oRegionsOfInterest};
            else
                c1xSuperArgs = {oImageVolumeGeometry};
            end
            
            % super-class constructor
            obj@ImageVolume(c1xSuperArgs{:});            
            
            % set class properities
            obj.chMhdFilePath = chMhdFilePath;
            obj.chRawFilePath = chRawFilePath;
            
            obj.stFileMetadata = stFileMetaData;
        end
        
        function chFilePath = GetOriginalFilePath(obj)
            chFilePath = obj.chMhdFilePath;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@ImageVolume(obj);
            
            % local call
            % no deep copies required
        end
        
        function m3xImageData = LoadOriginalImageData(obj)
            m3xImageData = mha_read_volume(obj.stFileMetadata);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?MHDLabelMapRegionsOfInterest}, Static = true)
        
        function oImageVolumeGeometry = GetImageVolumeGeometryFromFileMetaData(stFileMetaData)
            
            vdVolumeDimensions = double(stFileMetaData.Dimensions);
            vdVoxelDimensions_mm = double(stFileMetaData.PixelDimensions);
            
            vdFirstVoxelPosition_mm = double(stFileMetaData.Offset);
            vdFirstVoxelPosition_mm(1:2) = -vdFirstVoxelPosition_mm(1:2);
            
            vdRowAxisUnitVector = stFileMetaData.TransformMatrix(1:3);
            vdRowAxisUnitVector(1:2) = -vdRowAxisUnitVector(1:2);
                        
            vdColAxisUnitVector = stFileMetaData.TransformMatrix(4:6);
            vdColAxisUnitVector(1:2) = -vdColAxisUnitVector(1:2);
            
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


