classdef CustomIntensityTransform < IndependentImagingObjectTransform
    %CustomIntensityTransform
    %
    % Todo
    
    % Primary Author: David DeVries
    % Created: Dec 28, 2021
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        fnImageDataTransform function_handle
    end    
        
       
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = public) % None
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject})
        
        function obj = CustomIntensityTransform(oImageVolume, fnImageDataTransform)
            arguments
                oImageVolume (1,1) ImageVolume
                fnImageDataTransform function_handle
            end
                        
            obj@IndependentImagingObjectTransform(oImageVolume.GetImageVolumeGeometry(), oImageVolume.GetImageVolumeGeometry()); % no change in geometry
            
            % validate that the function call would work
            m3iTestInput = uint8(randi(10,3,4,5));
            
            try
                m3iTestOutput = fnImageDataTransform(m3iTestInput);
            catch e
                error(...
                    'CustomIntensityTransform:Constructor:FunctionError',...
                    'The provided function handle did not successfully complete when provided with a 3D numerical matrix.');
            end                    
            
            vdSizeInput = size(m3iTestInput);
            vdSizeOutput = size(m3iTestOutput);
            
            if length(vdSizeInput) ~= length(vdSizeOutput) || any(vdSizeInput ~= vdSizeOutput) || ~strcmp(class(m3iTestOutput), class(m3iTestInput))
                error(...
                    'CustomIntensityTransform:Constructor:InvalidFunctionOutput',...
                    'The provided function handle did not provide an output with the same dimension and data type as the input.');
            end
            
            % local call
            obj.fnImageDataTransform = fnImageDataTransform;
        end
        
        function Apply(obj, oImageVolume)
            oImageVolume.ApplyImagingObjectIntensityTransform(obj.fnImageDataTransform(oImageVolume.GetCurrentImageDataForTransform()));
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

