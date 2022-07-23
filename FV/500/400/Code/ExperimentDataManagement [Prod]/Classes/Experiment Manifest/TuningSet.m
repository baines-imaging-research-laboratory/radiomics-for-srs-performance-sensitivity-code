classdef TuningSet
    %TuningSet
    %
    % Provides a selection from a DBG & LBL combination that is "the tuning
    % set"
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        sIdTag (1,1) string
        
        sLabelIdTag (1,1) string
        
        vbSampleIsInTuningSet (:,1) logical
    end
    
    properties (Constant = true, GetAccess = private)
        chMatFileVarName = 'oTuningSet'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = TuningSet(sIdTag, oLabels, vbSampleIsInTuningSet)
            arguments
                sIdTag (1,1) string
                oLabels (1,1) Labels
                vbSampleIsInTuningSet(:,1) logical
            end
            
            obj.sIdTag = sIdTag;
            obj.sLabelIdTag = oLabels.GetIdTag();
            
            obj.vbSampleIsInTuningSet = vbSampleIsInTuningSet;
        end
        
        function sIdTag = GetIdTag(obj)
            sIdTag = obj.sIdTag;
        end
        
        function Save(obj, chFilePath)
            arguments
                obj (1,1) TuningSet
                chFilePath (1,:) char = fullfile(Experiment.GetResultsDirectory(), [char(obj.GetIdTag()), '.mat'])
            end
            
            FileIOUtils.SaveMatFile(chFilePath, TuningSet.chMatFileVarName, obj);
        end
        
        function vbSampleIsInTuningSet = GetSampleIsInTuningSet(obj)
            vbSampleIsInTuningSet = obj.vbSampleIsInTuningSet;
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function obj = Load(chFilePath)
            arguments
                chFilePath (1,:) char
            end
            
            obj = FileIOUtils.LoadMatFile(chFilePath, TuningSet.chMatFileVarName);
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

