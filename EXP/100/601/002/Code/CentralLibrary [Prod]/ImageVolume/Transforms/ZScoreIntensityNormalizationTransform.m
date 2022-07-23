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
        dRegionOfInterestNumber double {ValidationUtils.MustBeEmptyOrScalar} = []
        
        dNumberOfStandardDeviations (1,1) double
        
        dCustomMean double {ValidationUtils.MustBeEmptyOrScalar} = []
        dCustomStandardDeviation double {ValidationUtils.MustBeEmptyOrScalar} = []
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
        
        function obj = ZScoreIntensityNormalizationTransform(oImageVolume, dNumberOfStandardDeviations, NameValueArgs)
            arguments
                oImageVolume (1,1) ImageVolume
                dNumberOfStandardDeviations (1,1) double {mustBeFinite, mustBePositive}
                NameValueArgs.RegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(oImageVolume, NameValueArgs.RegionOfInterestNumber)}
                NameValueArgs.CustomMean (1,1) double {mustBeFinite}
                NameValueArgs.CustomStandardDeviation (1,1) double {mustBeFinite, mustBePositive}
            end
                        
            obj@IndependentImagingObjectTransform(oImageVolume.GetImageVolumeGeometry(), oImageVolume.GetImageVolumeGeometry()); % no change in geometry
            
            % validate that user specified either 1) ROI Number; or 2) mean
            % and st dev
            if isfield(NameValueArgs, 'RegionOfInterestNumber')
                if isfield(NameValueArgs, 'CustomMean') || isfield(NameValueArgs, 'CustomStandardDeviation')
                    error(...
                        'ZScoreIntensityNormalizationTransform:Constructor:InvalidInputCombination',...
                        'Either the ROI number for which the mean and st dev is calculated for, or a custom mean and standard deviation should be given.');
                end
                
                obj.dRegionOfInterestNumber = NameValueArgs.RegionOfInterestNumber;
            else
                if ~isfield(NameValueArgs, 'CustomMean') || ~isfield(NameValueArgs, 'CustomStandardDeviation')
                    error(...
                        'ZScoreIntensityNormalizationTransform:Constructor:MeanAndStandardDeviationNotGiven',...
                        'A custom mean and standard deviation must be given if no ROI number is specified.');
                end
                
                obj.dCustomMean = NameValueArgs.CustomMean;
                obj.dCustomStandardDeviation = NameValueArgs.CustomStandardDeviation;
            end
            
            % set number of st devs
            obj.dNumberOfStandardDeviations = dNumberOfStandardDeviations;            
        end
        
        function Apply(obj, oImageVolume)
            m3xCurrentImageData = double(oImageVolume.GetCurrentImageDataForTransform());
            
            if ~isempty(obj.dRegionOfInterestNumber)
                m3bMask = oImageVolume.GetRegionsOfInterest().GetMaskByRegionOfInterestNumber(obj.dRegionOfInterestNumber);
                
                dMean = mean(m3xCurrentImageData(m3bMask));
                dStDev = std(m3xCurrentImageData(m3bMask));
            else
                dMean = obj.dCustomMean;
                dStDev = obj.dCustomStandardDeviation;
            end
            
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

