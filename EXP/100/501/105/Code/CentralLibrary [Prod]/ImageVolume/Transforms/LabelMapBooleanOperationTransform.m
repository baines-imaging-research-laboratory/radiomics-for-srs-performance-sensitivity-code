classdef LabelMapBooleanOperationTransform < DependentImagingObjectTransform
    %LabelMapBooleanOperationTransform
    %
    % This applies a boolean operation between the ROI masks of a
    % RegionsOfInterest object and a "second input" RegionsOfInterest
    % object. This transform class is a DependentImagingObjectTransform
    % because the "second input" RegionsOfInterest is required to compute
    % the transform.
    
    % Primary Author: David DeVries
    % Created: Feb 27, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)        
        vdRegionOfInterestNumbers (1,:) double % which ROIs to apply the transform to
        
        fnBooleanOperation function_handle {ValidationUtils.MustBeEmptyOrScalar(fnBooleanOperation)}
        
        chRegionsOfInterestSecondInputOriginalFilePath (1,:) char
        chRegionsOfInterestSecondInputMatFilePath (1,:) char
            
        vdRegionOfInterestNumbersSecondInput (1,:) double
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
        
        function ApplyWithDependentInputs(obj, oLabelMapRegionsOfInterest, oRegionsOfInterestSecondInput)
            oLabelMapRegionsOfInterest.ApplyBooleanOperation(...
                obj.vdRegionOfInterestNumbers,...
                obj.fnBooleanOperation,...           
                oRegionsOfInterestSecondInput,...
                obj.vdRegionOfInterestNumbersSecondInput);
        end
    end
    

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?ImagingObjectTransform, ?GeometricalImagingObject})
        
        function obj = LabelMapBooleanOperationTransform(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers, fnBooleanOperation, oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput)
            % obj = LabelMapBooleanOperationTransform(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers, fnBooleanOperation, oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput)
            % 
            % SYNTAX:
            %  obj =
            %  LabelMapBooleanOperationTransform(oCurrentLabelMapRegionsOfInterest, vdRegionOfInterestNumbers, fnBooleanOperation, oRegionsOfInterestSecondInput, vdRegionOfInterestNumbersSecondInput)
                        
            oCurrentImageVolumeGeometry = oCurrentLabelMapRegionsOfInterest.GetImageVolumeGeometry();
            
            % Super-class constructor
            obj@DependentImagingObjectTransform(oCurrentImageVolumeGeometry, oCurrentImageVolumeGeometry, oRegionsOfInterestSecondInput); % image volume geometry will not be changed; the "second input" ROIs object is passes to super-class constructor as it will handle temporarily storing it
                      
            % validate that the function call would work
            m3bTestFirstInput = logical(randi(2,3,4,5)-1);
            m3bTestSecondInput = logical(randi(2,3,4,5)-1);
            
            try
                m3bTestOutput = fnBooleanOperation(m3bTestFirstInput, m3bTestSecondInput);
            catch e
                error(...
                    'LabelMapBooleanOperationTransform:Constructor:FunctionError',...
                    'The provided function handle did not successfully complete when provided two boolean matrices of the same dimension were passed.');
            end                    
            
            vdSizeInput = size(m3bTestFirstInput);
            vdSizeOutput = size(m3bTestOutput);
            
            if length(vdSizeInput) ~= length(vdSizeOutput) || any(vdSizeInput ~= vdSizeOutput) || ~islogical(m3bTestOutput)
                error(...
                    'LabelMapBooleanOperationTransform:Constructor:InvalidFunctionOutput',...
                    'The provided function handle did not provide a logical output as the same dimensions as the inputs.');
            end
            
            % Set properities
            obj.vdRegionOfInterestNumbers = vdRegionOfInterestNumbers;
            obj.fnBooleanOperation = fnBooleanOperation;
            
            % don't store the whole regions of interest object, since it's
            % far too large. Just store the paths to it as reference.
            obj.chRegionsOfInterestSecondInputOriginalFilePath = oRegionsOfInterestSecondInput.GetOriginalFilePath();
            obj.chRegionsOfInterestSecondInputMatFilePath = oRegionsOfInterestSecondInput.GetMatFilePath();
            
            % we can store the "second input" ROI numbers, are relatively
            % small
            obj.vdRegionOfInterestNumbersSecondInput = vdRegionOfInterestNumbersSecondInput;
        end
    end
    
    
    methods (Access = private, Static = true)
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

