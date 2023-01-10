classdef ImageVolumeViewRecord
    %ImageVolumeViewRecord
    %
    % This class object holds all the information in order to restore a
    % three-view (sagittal, coronal, axial) plane viewer to the a given
    % state. It holds the current slice index for each plane, the 2D FOV
    % for each plane, and the window/level for grayscale display
    
    % Primary Author: David DeVries
    % Created: Oct 25, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        vdAnatomicalPlaneIndices        
        voAnatomicalPlaneFieldsOfView2D    
        
        vdImageDataDisplayThreshold % e.g. grayscale min and max
    end    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ImageVolumeViewRecord(vdAnatomicalPlaneIndices, voAnatomicalPlaneFieldsOfView2D, vdImageDataDisplayThreshold)
            % obj = ImageVolumeViewRecord(vdAnatomicalPlaneIndices, voAnatomicalPlaneFieldsOfView2D, vdImageDataDisplayThreshold)
            arguments
               vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
               voAnatomicalPlaneFieldsOfView2D (1,3) ImageVolumeFieldOfView2D
               vdImageDataDisplayThreshold (1,2) double {ValidationUtils.MustBeIncreasing(vdImageDataDisplayThreshold)}
            end
            
            obj.vdAnatomicalPlaneIndices = vdAnatomicalPlaneIndices;
            obj.voAnatomicalPlaneFieldsOfView2D = voAnatomicalPlaneFieldsOfView2D;
            obj.vdImageDataDisplayThreshold = vdImageDataDisplayThreshold;
        end       
        
        function vdAnatomicalPlaneIndices = GetAnatomicalPlaneIndices(obj)
            vdAnatomicalPlaneIndices = obj.vdAnatomicalPlaneIndices;
        end
        
        function voAnatomicalPlaneFieldsOfView2D = GetAnatomicalPlaneFieldsOfView2D(obj)
            voAnatomicalPlaneFieldsOfView2D = obj.voAnatomicalPlaneFieldsOfView2D;
        end
        
        function vdImageDataDisplayThreshold = GetImageDataDisplayThreshold(obj)
            vdImageDataDisplayThreshold = obj.vdImageDataDisplayThreshold;
        end

        function obj = SetImageDataDisplayThreshold(obj, vdImageDataDisplayThreshold)
            arguments
                obj
                vdImageDataDisplayThreshold (1,2) double {ValidationUtils.MustBeIncreasing(vdImageDataDisplayThreshold)}
            end
            
            obj.vdImageDataDisplayThreshold = vdImageDataDisplayThreshold;
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