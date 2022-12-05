classdef ExperimentHyperParameterOptimizer
    %ExperimentHyperParameterOptimizer
    %
    % TODO
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        fnHyperParameterOptimizerConstructor function_handle
        sParameterFilePath string
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oHyperParameterOptimizer'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExperimentHyperParameterOptimizer(sIdTag, fnHyperParameterOptimizerConstructor, sParameterFilePath)
            arguments
                sIdTag (1,1) string
                fnHyperParameterOptimizerConstructor (1,1) function_handle
                sParameterFilePath (1,1) string
            end
            
            obj.sIdTag = sIdTag;
            obj.fnHyperParameterOptimizerConstructor = fnHyperParameterOptimizerConstructor;
            
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
                obj (1,1) ExperimentHyperParameterOptimizer
                sFilePath (1,1) string = Experiment.GetResultsDirectory()
            end
            
            FileIOUtils.SaveMatFile(...
                fullfile(sFilePath, obj.sIdTag),...
                ExperimentHyperParameterOptimizer.chMatFileVarName, obj);
        end
        
        function oHyperParameterOptimizer = CreateHyperParameterOptimizer(obj, varargin)
            arguments
                obj (1,1) ExperimentHyperParameterOptimizer
            end
            arguments (Repeating)
                varargin
            end
            
            sParameterFilePath = obj.sParameterFilePath;
            
            if ~isfile(sParameterFilePath)
                sParameterFilePath = strrep(obj.sParameterFilePath, "E:", "D:");
            end
            
            if isequal(obj.fnHyperParameterOptimizerConstructor, @MATLABBayesianHyperParameterOptimizer)
                oOFN = varargin{1};
                oTuningSet = varargin{2};
                
                if length(varargin) > 2
                    c1xVarargin = varargin(3:end);
                else
                    c1xVarargin = {};
                end
                
                oHyperParameterOptimizer = obj.fnHyperParameterOptimizerConstructor(sParameterFilePath, oOFN.GetObjectiveFunction(), oTuningSet, c1xVarargin{:});
            elseif isequal(obj.fnHyperParameterOptimizerConstructor, @MATLABMachineLearningHyperParameterOptimizer)
                oTuningSet = varargin{1};
                
                if length(varargin) > 1
                    c1xVarargin = varargin(2:end);
                else
                    c1xVarargin = {};
                end
                
                oHyperParameterOptimizer = obj.fnHyperParameterOptimizerConstructor(sParameterFilePath, oTuningSet, c1xVarargin{:});
            else
                error(...
                    'ExperimentHyperParameterOptimizer:CreateHyperParameterOptimizer:InvalidConstructorFunction',...
                    'The constructor is not supported.');
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ExperimentHyperParameterOptimizer.chMatFileVarName);
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

