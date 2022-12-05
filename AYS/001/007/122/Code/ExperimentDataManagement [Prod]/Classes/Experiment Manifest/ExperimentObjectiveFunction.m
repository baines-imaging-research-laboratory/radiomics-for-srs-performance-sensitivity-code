classdef ExperimentObjectiveFunction
    %ExperimentObjectiveFunction
    %
    % TODO
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        oObjectiveFunction MachineLearningObjectiveFunction {ValidationUtils.MustBeEmptyOrScalar} = KFoldCrossValidationObjectiveFunction.empty
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oObjectiveFunction'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExperimentObjectiveFunction(sIdTag, oObjectiveFunction)
            arguments
                sIdTag (1,1) string
                oObjectiveFunction (1,1) MachineLearningObjectiveFunction {ValidationUtils.MustBeEmptyOrScalar}
            end
            
            obj.sIdTag = sIdTag;
            obj.oObjectiveFunction = oObjectiveFunction;           
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function Save(obj, sFilePath)
            arguments
                obj (1,1) ExperimentObjectiveFunction
                sFilePath (1,1) string = Experiment.GetResultsDirectory()
            end
            
            FileIOUtils.SaveMatFile(...
                fullfile(sFilePath, obj.sIdTag),...
                ExperimentObjectiveFunction.chMatFileVarName, obj);
        end
        
        function oObjectiveFunction = GetObjectiveFunction(obj)
            oObjectiveFunction = obj.oObjectiveFunction;
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ExperimentObjectiveFunction.chMatFileVarName);
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

