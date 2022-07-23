classdef NIfTILabelMapRegionsOfInterest < LabelMapRegionsOfInterest
    %RegionsOfInterest
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public)
        viMaskVoxelValues = []
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        chFilePath = []
        stFileMetadata = []
        m2dRegionOfInterestDefaultRenderColours_rgb = []
    end    
    
    properties (Constant = true, GetAccess = private)
        m2dItkSnapRenderColours = [... % based off of ITK-Snap's default label colourings
            1 0 0;
            0 1 0;
            0 0 1;
            1 1 0;
            0 1 1;
            1 0 1]
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
           
    methods (Access = public)
        
        function obj = NIfTILabelMapRegionsOfInterest(chFilePath, NameValueArgs)
            %obj = NIfTILabelMapRegionsOfInterest(chFilePath, NameValueArgs)
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
                
            arguments
                chFilePath (1,:) char
                NameValueArgs.SliceThickness_mm (1,1) double {mustBePositive, mustBeFinite}
            end
            
            % read in dimensions, num. ROIs from file
            stFileMetadata = niftiinfo(chFilePath);
            
            c1xVarargin = namedargs2cell(NameValueArgs);
            
            oOnDiskImageVolumeGeometry = NIfTIImageVolume.GetImageVolumeGeometryFromFileMetaData(stFileMetadata, c1xVarargin{:});
            
            m3xRoiData = niftiread(chFilePath);
            
            vdRoiNumbers = unique(m3xRoiData(:));
            
            if vdRoiNumbers(1) == 0 % get rid of zero index (the "clear" label)
                vdRoiNumbers = vdRoiNumbers(2:end);
            end
            
            dNumberOfRois = length(vdRoiNumbers);
                        
            m2dRenderColours = zeros(dNumberOfRois,3);
            
            dNumDefaultColourChoices = size(NIfTILabelMapRegionsOfInterest.m2dItkSnapRenderColours,1);
            
            for dRoiIndex=1:dNumberOfRois
                m2dRenderColours(dRoiIndex,:) = NIfTILabelMapRegionsOfInterest.m2dItkSnapRenderColours(mod(vdRoiNumbers(dRoiIndex)-1,dNumDefaultColourChoices)+1,:);
            end
            
            clear('m3xRoiData');     
            
            % super-class constructor
            obj@LabelMapRegionsOfInterest(oOnDiskImageVolumeGeometry, dNumberOfRois);            
            
            % set properities
            obj.chFilePath = chFilePath;
            obj.stFileMetadata = stFileMetadata;            
            obj.m2dRegionOfInterestDefaultRenderColours_rgb = m2dRenderColours;
            obj.viMaskVoxelValues = vdRoiNumbers;
        end  
        
        function m2dColours_rgb = GetDefaultRenderColours_rgb(obj)
            m2dColours_rgb = obj.m2dRegionOfInterestDefaultRenderColours_rgb;
        end
        
        function vdColour_rgb = GetDefaultRenderColourByRegionOfInterestNumber_rgb(obj, dRegionOfInterestNumber)
            vdColour_rgb = obj.m2dRegionOfInterestDefaultRenderColours_rgb(dRegionOfInterestNumber,:);
        end
        
        function oRenderer = GetRenderer(obj)
            objRAS = copy(obj);
            objRAS.ReassignFirstVoxelToAlignWithRASCoordinateSystem();
            
            oRenderer = LabelMapRegionsOfInterestRenderer(obj, objRAS);
        end
                
        function vdRoiLabelMapNumbers = GetRegionsOfInterestLabelMapNumbers(obj)
            vdRoiLabelMapNumbers = double(obj.viMaskVoxelValues)';
        end
        
        function chFilePath = GetOriginalFilePath(obj)            
            chFilePath = obj.chFilePath;
        end                
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function m3uiLabelMaps = LoadLabelMapsFromDisk(obj)
            m3iLabelMaps = niftiread(obj.chFilePath);
            
            if NIfTIImageVolume.GetQFactorFromFileMetadata(obj.stFileMetadata) == -1
                m3iLabelMaps = permute(m3iLabelMaps, [2,1,3]);
            end
            
            GeometricalImagingObject.MustBeValidVolumeData(m3iLabelMaps, obj.GetOnDiskImageVolumeGeometry());
            
            % the format we'll assume that is on disk (e.g. what ITK-Snap
            % outputs) is that it a matrix on integers. Every index with a
            % "1" belongs to ROI 1, every index with a "2" belongs to ROI 2
            % and so on. This means that a voxel cannot belong to two ROIs.
            % This is a problem, as other ROI types do allow this. We'll
            % convert this to the format that LabelMapRegionsOfInterest
            % wants: a uint matrix, where the bit positions represent
            % the on/off for ROIs
            
            m3uiLabelMaps = zeros(size(m3iLabelMaps), obj.GetLabelMapUintType(obj.GetNumberOfRegionsOfInterest()));
            viLabelMapNumbers = obj.viMaskVoxelValues;
            
            for dLabelMapIndex=1:length(viLabelMapNumbers)
                m3uiLabelMaps = bitset(m3uiLabelMaps, dLabelMapIndex, m3iLabelMaps == viLabelMapNumbers(dLabelMapIndex));
            end
        end
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@LabelMapRegionsOfInterest(obj);
            
            % local call
            % no deep copies required
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
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


