classdef ExperimentHyperParameters
    %ExperimentHyperParameters
    %
    % TODO
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        vsHyperParameterFilePaths (:,1) string
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oHyperParameters'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExperimentHyperParameters(sIdTag, vsHyperParametersReadPaths, sHyperParametersWritePath)
            arguments
                sIdTag (1,1) string
                vsHyperParametersReadPaths (1,:) string
                sHyperParametersWritePath (1,1) string
            end
            
            obj.sIdTag = sIdTag;
            
            dNumPaths = length(vsHyperParametersReadPaths);
            
            vsHyperParameterFilePaths = strings(dNumPaths,1);
            
            for dPathIndex=1:dNumPaths
                [~,chFileName] = FileIOUtils.SeperateFilePathAndFilename(vsHyperParametersReadPaths(dPathIndex));
                sWritePath = fullfile(sHyperParametersWritePath, chFileName);
                
                copyfile(...
                    vsHyperParametersReadPaths(dPathIndex),...
                    sWritePath);
                vsHyperParameterFilePaths(dPathIndex) = sWritePath;
            end
            
            obj.vsHyperParameterFilePaths = vsHyperParameterFilePaths;            
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) ExperimentHyperParameters
                chFilePath (1,:) char = fullfile(Experiment.GetResultsDirectory(), obj.GetIdTag() + ".mat")
            end
            
            FileIOUtils.SaveMatFile(chFilePath, ExperimentHyperParameters.chMatFileVarName, obj);
        end
        
        function sPath = GetFilePath(obj, sFileNameToSelect)
            arguments
                obj (1,1) ExperimentHyperParameters
                sFileNameToSelect (1,1) string
            end
            
            dNumPaths = length(obj.vsHyperParameterFilePaths);
            vbIsMatch = false(dNumPaths,1);
            
            for dPathIndex=1:dNumPaths
                sFilePath = obj.vsHyperParameterFilePaths(dPathIndex);
                
                [~, chFileName] = FileIOUtils.SeperateFilePathAndFilename(sFilePath);
                sFileName = string(chFileName);
                
                if sFileName == sFileNameToSelect
                    vbIsMatch(dPathIndex) = true;
                end
            end
            
            if sum(vbIsMatch) ~= 1
                error(...
                    'ExperimentHyperParameters:GetFilePath:NoSingleMatch',...
                    'A single match for the filename was not found.');
            end
            
            sPath = obj.vsHyperParameterFilePaths(vbIsMatch);
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ExperimentHyperParameters.chMatFileVarName);
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

