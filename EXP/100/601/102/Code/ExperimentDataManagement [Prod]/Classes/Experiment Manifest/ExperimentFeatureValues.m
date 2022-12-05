classdef ExperimentFeatureValues
    %ExperimentFeatureValues
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        sPathToFileLocation (1,1) string
    end
    
    properties (Constant = true, GetAccess = private)        
        chMatFileVarName = 'oExperimentFeatureValues'
        chCentralLibraryMatFileVarName = 'oFeatureValues'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExperimentFeatureValues(sIdTag)
            arguments
                sIdTag (1,1) string
            end
            
            obj.sIdTag = sIdTag;
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function oFeatureValues = GetFeatureValues(obj)
            oFeatureValues = FileIOUtils.LoadMatFile(fullfile(obj.sPathToFileLocation, obj.sIdTag + " [CentralLibrary].mat"), ExperimentFeatureValues.chCentralLibraryMatFileVarName);
        end
        
        function SaveFeatureValuesAsMat(obj, oFeatureValues, chPath)
            arguments
                obj (1,1) ExperimentFeatureValues
                oFeatureValues (:,:) FeatureValues
                chPath (1,:) char = Experiment.GetResultsDirectory()
            end
            
            FileIOUtils.SaveMatFile(fullfile(chPath, obj.sIdTag + " [CentralLibrary].mat"), ExperimentFeatureValues.chCentralLibraryMatFileVarName, oFeatureValues);            
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) ExperimentFeatureValues
                chFilePath (1,:) char = fullfile(Experiment.GetResultsDirectory(), obj.GetIdTag()+".mat")
            end
            
            FileIOUtils.SaveMatFile(chFilePath, ExperimentFeatureValues.chMatFileVarName, obj);
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ExperimentFeatureValues.chMatFileVarName);
            obj.sPathToFileLocation = string(FileIOUtils.SeparateFilePathAndFilename(chFilePath));
        end
        
        function chVarName = GetCentralLibraryMatFileVarName()
            chVarName = ExperimentFeatureValues.chCentralLibraryMatFileVarName;
        end
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

