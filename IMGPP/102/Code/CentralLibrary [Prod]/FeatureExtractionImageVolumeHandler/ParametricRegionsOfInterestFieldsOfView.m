classdef ParametricRegionsOfInterestFieldsOfView < RegionsOfInterestFieldsOfView
    %ParametricRegionsOfInterestFieldsOfView
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: Oct 13, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dSagittalSliceIndexWithinBlock
        dCoronalSliceIndexWithinBlock
        dAxialSliceIndexWithinBlock
        
        vdGrayscaleThresholdMinMax
        ePreferred2DDisplayImagingPlaneType
    end
    
    
    properties (SetAccess = immutable, GetAccess = public)
       
    end
    
    
    properties (Constant = true, GetAccess = public)
        
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ParametricRegionsOfInterestFieldsOfView(oRASImageVolume, NameValueArgs)
            arguments
                oRASImageVolume (1,1) ImageVolume {ImageVolume.MustHaveRegionsOfInterestOfClass(oRASImageVolume, 'ParametricRegionsOfInterest'), GeometricalImagingObject.MustBeRAS(oRASImageVolume)}
                NameValueArgs.Is2D (1,1) logical = false
                NameValueArgs.PreferredImagingPlaneType (1,1) eImagingPlaneType = ImagePlaneTypes.Axial
                NameValueArgs.SagittalSliceIndex (1,1) double {mustBePositive, mustBeInteger}
                NameValueArgs.CoronalSliceIndex (1,1) double {mustBePositive, mustBeInteger}
                NameValueArgs.AxialSliceIndex (1,1) double {mustBePositive, mustBeInteger}
            end
            
            obj.vdGrayscaleThresholdMinMax = oRASImageVolume.GetDefaultImageDisplayBounds();
            
            if NameValueArgs.Is2D
                obj.dSagittalSliceIndexWithinBlock = [];
                obj.dCoronalSliceIndexWithinBlock = [];
                obj.dAxialSliceIndexWithinBlock = 1;
        
                obj.ePreferred2DDisplayImagingPlaneType = ImagingPlaneTypes.Axial;
            else
                oRASRois = oRASImageVolume.GetRegionsOfInterest();
                vdBlockDimensions = oRASRois.GetBlockDimensions();
                     
                % set sagittal slice index
                if ~isfield(NameValueArgs, 'SagittalSliceIndex')
                    obj.dSagittalSliceIndexWithinBlock = ceil(vdBlockDimensions(1)/2);
                else
                    if NameValueArgs.SagittalSliceIndex > vdBlockDimensions(1)
                        error(...
                            'ParametricRegionsOfInterest:Constructor:InvalidCustomSagittalSliceIndex',...
                            ['The sagittal slice index cannot exceed the sagittal block dimensions (', num2str(vdBlockDimensions(1)), ').']);
                    else
                        obj.dSagittalSliceIndexWithinBlock = NameValueArgs.SagittalSliceIndex;
                    end                        
                end
                   
                % set coronal slice index
                if ~isfield(NameValueArgs, 'CoronalSliceIndex')
                    obj.dCoronalSliceIndexWithinBlock = ceil(vdBlockDimensions(2)/2);
                else
                    if NameValueArgs.CoronalSliceIndex > vdBlockDimensions(2)
                        error(...
                            'ParametricRegionsOfInterest:Constructor:InvalidCustomCoronalSliceIndex',...
                            ['The coronal slice index cannot exceed the coronal block dimensions (', num2str(vdBlockDimensions(2)), ').']);
                    else
                        obj.dCoronalSliceIndexWithinBlock = NameValueArgs.CoronalSliceIndex;
                    end                        
                end
                   
                % set axial slice index
                if ~isfield(NameValueArgs, 'AxialSliceIndex')
                    obj.daxialSliceIndexWithinBlock = ceil(vdBlockDimensions(3)/2);
                else
                    if NameValueArgs.AxialSliceIndex > vdBlockDimensions(3)
                        error(...
                            'ParametricRegionsOfInterest:Constructor:InvalidCustomAxialSliceIndex',...
                            ['The axial slice index cannot exceed the axial block dimensions (', num2str(vdBlockDimensions(3)), ').']);
                    else
                        obj.dAxialSliceIndexWithinBlock = NameValueArgs.AxialSliceIndex;
                    end                        
                end
                
                % set preferred imaging plane type to display
                obj.ePreferred2DDisplayImagingPlaneType = NameValueArgs.PreferredImagingPlaneType;
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