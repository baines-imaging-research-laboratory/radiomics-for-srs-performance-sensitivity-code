classdef ExperimentFeatureSelector
    %ExperimentFeatureSelector
    %
    % TODO
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        fnFeatureSelectorConstructor function_handle
        sParameterFilePath string
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oFeatureSelector'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = ExperimentFeatureSelector(sIdTag, fnFeatureSelectorConstructor, sParameterFilePath)
            arguments
                sIdTag (1,1) string
                fnFeatureSelectorConstructor (1,1) function_handle
                sParameterFilePath (1,1) string
            end
            
            obj.sIdTag = sIdTag;
            obj.fnFeatureSelectorConstructor = fnFeatureSelectorConstructor;
            
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
                obj (1,1) ExperimentFeatureSelector
                sFilePath (1,1) string = Experiment.GetResultsDirectory()
            end
            
            FileIOUtils.SaveMatFile(...
                fullfile(sFilePath, obj.sIdTag),...
                ExperimentFeatureSelector.chMatFileVarName, obj);
        end
        
        function oFeatureSelector = CreateFeatureSelector(obj, varargin)
            
            sParameterFilePath = obj.sParameterFilePath;
            
            if ~isfile(sParameterFilePath)
                sParameterFilePath = strrep(obj.sParameterFilePath, "E:", "D:");
            end            
            
            if isequal(obj.fnFeatureSelectorConstructor, @ForwardWrapperFeatureSelector) || isequal(obj.fnFeatureSelectorConstructor, @BackwardWrapperFeatureSelector)
                oFeatureSelector = obj.fnFeatureSelectorConstructor(sParameterFilePath, varargin{1}.GetObjectiveFunction());
            elseif isequal(obj.fnFeatureSelectorConstructor, @CorrelationFilterFeatureSelector)
                oFeatureSelector = obj.fnFeatureSelectorConstructor(sParameterFilePath);
            elseif isequal(obj.fnFeatureSelectorConstructor, @MATLABfscmrmr)
                oFeatureSelector = obj.fnFeatureSelectorConstructor(sParameterFilePath);
            else
                error('Unrecognized FS Constructor');
            end
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, ExperimentFeatureSelector.chMatFileVarName);
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

