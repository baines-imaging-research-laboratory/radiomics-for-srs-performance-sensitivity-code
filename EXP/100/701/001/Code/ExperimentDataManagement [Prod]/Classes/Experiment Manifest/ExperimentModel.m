classdef ExperimentModel
    %ExperimentModel
    %
    % TODO
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        fnModelConstructor function_handle
        sParameterFilePath string
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oExperimentModel'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExperimentModel(sIdTag, fnModelConstructor, sParameterFilePath)
            arguments
                sIdTag (1,1) string
                fnModelConstructor (1,1) function_handle
                sParameterFilePath (1,1) string
            end
            
            obj.sIdTag = sIdTag;
            obj.fnModelConstructor = fnModelConstructor;
            
            [~,sFilename] = FileIOUtils.SeparateFilePathAndFilename(sParameterFilePath);
            
            sWritePath = fullfile(Experiment.GetResultsDirectory(), sFilename);
            
            copyfile(sParameterFilePath, sWritePath);
            
            obj.sParameterFilePath = sWritePath;
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function Save(obj, sFilePath)
            arguments
                obj (1,1) ExperimentModel
                sFilePath (1,1) string = Experiment.GetResultsDirectory()
            end
            
            FileIOUtils.SaveMatFile(...
                fullfile(sFilePath, obj.sIdTag),...
                ExperimentModel.chMatFileVarName, obj);
        end
        
        function oModel = CreateModel(obj, varargin)
            arguments
                obj (1,1) ExperimentModel
            end
            arguments (Repeating)
                varargin
            end
            
            sPath = obj.sParameterFilePath;
            
            if ~isfile(sPath)
                sPath = strrep(obj.sParameterFilePath, "E:", "D:");
            end
            
            oModel = obj.fnModelConstructor(sPath, varargin{:});
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ExperimentModel.chMatFileVarName);
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

