classdef (Abstract) FirstOrderFeature < Feature
    %Image
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (Constant = true, GetAccess = public)
        chFeaturePrefix = 'F01'
        
        bIsValidFor2DImageVolumes = true
        bIsValidFor3DImageVolumes = true
    end    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = public, Static = true)
        
        function voFeatures = GetAllFeatures2D()
            voFeatures = FirstOrderFeature.GetAllFeatures();
        end
        
        function voFeatures = GetAllFeatures3D()
            voFeatures = FirstOrderFeature.GetAllFeatures();
        end
        
        function voFeatures = GetAllFeatures()
            chPath = mfilename('fullpath');
            [chPath,~] = FileIOUtils.SeparateFilePathAndFilename(chPath);
            
            voFeatures = Feature.CreateFeatureListFromDirectory(...
                chPath, FirstOrderFeature.chFeaturePrefix, F010001_Mean);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Static = false)
        function vsFeatureNames = GetFeatureNamesForFeatureExtraction(obj,oFeatureExtractorParameters)
            vsFeatureNames = obj.sFeatureName;
        end
        
        function ValidateFeatureExtractorParametersForImageVolume(obj, oImage, oFeatureExtractorParameters)
            % No validation
        end
    end
    
    methods (Access = protected, Static = true)
        
        function dNumValues = PreComputeNumberOfFeatures(oFeatureExtractorParameters)
            % First order features will always output exactly one value
            dNumValues = 1;
        end
    end

    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************

    methods (Access = private, Static = true)
    end
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)  
                
        function dValue = ExtractFeature_ForUnitTest(obj, oImageVolumeHandler, oFeatureExtractorParameters)           
            dValue = obj.ExtractFeature(oImageVolumeHandler, oFeatureExtractorParameters);
        end       
    
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

