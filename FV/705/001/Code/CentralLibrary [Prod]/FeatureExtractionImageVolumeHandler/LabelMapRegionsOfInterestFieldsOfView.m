classdef LabelMapRegionsOfInterestFieldsOfView < RegionsOfInterestFieldsOfView
    %LabelMapRegionsOfInterestFieldsOfView
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Oct 13, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voFieldsOfView3D
        oRASImageVolume
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
        vdRegionOfInterestNumbers
    end
    
    
    properties (Constant = true, GetAccess = public)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = LabelMapRegionsOfInterestFieldsOfView(oRASImageVolume, vdRegionOfInterestNumbers)
            arguments
                oRASImageVolume (1,1) ImageVolume {MustHaveRegionsOfInterestOfClass(oRASImageVolume, 'LabelMapRegionsOfInterest'),  MustBeRAS(oRASImageVolume)}
                vdRegionOfInterestNumbers (1,:) double {MustBeValidRegionOfInterestNumbers(oRASImageVolume, vdRegionOfInterestNumbers)}                
            end
            
            % super-class call
            dNumRois = length(vdRegionOfInterestNumbers);
            obj@RegionsOfInterestFieldsOfView(dNumRois);
            
            % set properities
            obj.vdRegionOfInterestNumbers = vdRegionOfInterestNumbers;            
            
            voFieldsOfView3D = LabelMapRegionOfInterestFieldsOfView3D.empty(1,0);
            
            for dRoiIndex=1:dNumRois
                voFieldsOfView3D(dRoiIndex) = LabelMapRegionOfInterestFieldsOfView3D(oRASImageVolume, vdRegionOfInterestNumbers(dRoiIndex), 'RAS', oRASImageVolume);
            end
            
            obj.voFieldsOfView3D = voFieldsOfView3D;
            obj.oRASImageVolume = oRASImageVolume;
        end
        
        function MustBeValidExtractionIndex(obj, dExtractionIndex)
            arguments
                obj
                dExtractionIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if dExtractionIndex > length(obj.vdRegionOfInterestNumbers)
                error(...
                    'LabelMapRegionsOfInterestFieldsOfView:MustBeValidExtractionIndex:Invalid',...
                    'The extraction index must be less than or equal to the number of region of interest numbers.');
            end
        end
        
        function oFieldOfView3D = GetFieldOfViewByExtractionIndex(obj, dExtractionIndex)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFieldsOfView
                dExtractionIndex (1,1) double {MustBeValidExtractionIndex(obj, dExtractionIndex)}
            end
               
            oFieldOfView3D = obj.voFieldsOfView3D(dExtractionIndex);
        end
        
        function SetFieldOfViewByExtractionIndex(obj, dExtractionIndex, oFieldOfView3D)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFieldsOfView
                dExtractionIndex (1,1) double {MustBeValidExtractionIndex(obj, dExtractionIndex)}
                oFieldOfView3D (1,1) ImageVolumeViewRecord
            end
               
            if isa(oFieldOfView3D, 'LabelMapRegionOfInterestFieldsOfView3D')
                obj.voFieldsOfView3D(dExtractionIndex) = oFieldOfView3D;
            else
                obj.voFieldsOfView3D(dExtractionIndex) = LabelMapRegionOfInterestFieldsOfView3D(...
                    oFieldOfView3D,...
                    obj.voFieldsOfView3D(dExtractionIndex).GetPreferred2DDisplayImagingPlaneType());
            end
        end
               
        function RenderFieldOfViewOnAxesByExtractionIndex(obj, oImagingPlaneAxes, dExtractionIndex, NameValueArgs)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                dExtractionIndex (1,1) double {MustBeValidExtractionIndex(obj, dExtractionIndex)}
                NameValueArgs.ForceImagingPlaneType ImagingPlaneTypes {ValidationUtils.MustBeEmptyOrScalar}
                NameValueArgs.ShowAllRegionsOfInterest (1,1) logical = true
                NameValueArgs.LineWidth (1,1) double {mustBePositive} = 1
                NameValueArgs.RegionOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector}
                NameValueArgs.OtherRegionsOfInterestColour (1,3) double {ValidationUtils.MustBeValidRgbVector}
            end
        	
            % set varargin for next call
            varargin = {...
                'ShowAllRegionsOfInterest', NameValueArgs.ShowAllRegionsOfInterest,...
                'LineWidth', NameValueArgs.LineWidth};                
            
            if isfield(NameValueArgs, 'ForceImagingPlaneType')
                varargin = [varargin, {'ForceImagingPlaneType', NameValueArgs.ForceImagingPlaneType}];
            end
            
            if isfield(NameValueArgs, 'RegionOfInterestColour')
                varargin = [varargin, {'RegionOfInterestColour', NameValueArgs.RegionOfInterestColour}];
            end
            
            if isfield(NameValueArgs, 'OtherRegionsOfInterestColour')
                varargin = [varargin, {'OtherRegionsOfInterestColour', NameValueArgs.OtherRegionsOfInterestColour}];
            end
            
            % call the Field of View's render call
            obj.voFieldsOfView3D(dExtractionIndex).RenderFieldOfViewOnAxesByRegionOfInterestNumber(...
                obj.oRASImageVolume, obj.vdRegionOfInterestNumbers(dExtractionIndex),...
                oImagingPlaneAxes,...
                varargin{:});
        end
        
        function SetImageDataDisplayThresholdForAllRepresentativeFieldsOfView(obj, vdDisplayThreshold)
            for dFovIndex=1:length(obj.voFieldsOfView3D)
                obj.voFieldsOfView3D(dFovIndex) = obj.voFieldsOfView3D(dFovIndex).SetImageDataDisplayThreshold(vdDisplayThreshold);
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
           
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