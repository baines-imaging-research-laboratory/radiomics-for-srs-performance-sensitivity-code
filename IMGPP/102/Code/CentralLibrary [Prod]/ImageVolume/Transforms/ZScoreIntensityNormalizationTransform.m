classdef ZScoreIntensityNormalizationTransform < IndependentImagingObjectTransform
    %ZScoreIntensityNormalizationTransform
    %
    % Todo
    
    % Primary Author: David DeVries
    % Created: Dec 6, 2021
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = immutable, GetAccess = public)
        dRegionOfInterestNumber
        dNumberOfStandardDeviations
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
        
        function obj = ZScoreIntensityNormalizationTransform(oImageVolume, dNumberOfStandardDeviations, dRegionOfInterestNumber)
            arguments
                oImageVolume (1,1) ImageVolume
                dNumberOfStandardDeviations (1,1) double {mustBeFinite, mustBePositive}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(oImageVolume, dRegionOfInterestNumber)}
            end
                        
            obj@IndependentImagingObjectTransform(oImageVolume.GetImageVolumeGeometry(), oImageVolume.GetImageVolumeGeometry()); % no change in geometry
            
            % local call
            obj.dNumberOfStandardDeviations = dNumberOfStandardDeviations;
            obj.dRegionOfInterestNumber = dRegionOfInterestNumber;
        end
        
        function Apply(obj, oImageVolume)
            m3xCurrentImageData = double(oImageVolume.GetCurrentImageDataForTransform());
            m3bMask = oImageVolume.GetRegionsOfInterest().GetMaskByRegionOfInterestNumber(obj.dRegionOfInterestNumber);
            
            dMean = mean(m3xCurrentImageData(m3bMask));
            dStDev = std(m3xCurrentImageData(m3bMask));
            
            m3xCurrentImageData = (m3xCurrentImageData - dMean) ./ (obj.dNumberOfStandardDeviations * dStDev);            
            m3xCurrentImageData = int16(m3xCurrentImageData * (2^15)); % puts -n*sigma at 2^15 and +n*sigma at 2^15
                        
            oImageVolume.ApplyImagingObjectIntensityTransform(m3xCurrentImageData);
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

