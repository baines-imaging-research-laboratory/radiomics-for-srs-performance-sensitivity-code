classdef (Abstract) LabelledMachineLearningDataSet < MachineLearningDataSet
    %LabelledMachineLearningDataSet
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)  
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
        
        oSamplelabels = GetSampleLabels(obj)
    end
    
    methods (Access = public, Static = false)
        
        function obj = LabelledMachineLearningDataSet()
            %obj = LabelledMachineLearningDataSet()
            %
            % SYNTAX:
            %  obj = LabelledMachineLearningDataSet()
            %
            % DESCRIPTION:
            %  Constructor for LabelledMachineLearningDataSet
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % super-class constructor
            obj@MachineLearningDataSet;
        end  
    end
    
    
    methods (Access = public, Static = true)     
        
        function MustBeValidTrainingAndTestingDataSets(oTrainingDataSet, oTestingDataSet)
            arguments
                oTrainingDataSet (:,:) LabelledMachineLearningDataSet
                oTestingDataSet (:,:) LabelledMachineLearningDataSet {MustNotContainDuplicatedSamples(oTestingDataSet)}
            end
            
            viTrainingGroupIds = oTrainingDataSet.GetSampleIds().GetUniqueGroupIds();
            viTestingGroupIds = oTestingDataSet.GetSampleIds().GetUniqueGroupIds();
            
            if ~isempty(intersect(viTrainingGroupIds, viTestingGroupIds))
                error(...
                    'LabelledMachineLearningDataSet:MustBeValidTrainingAndTestingDataSets:GroupIdOverlap',...
                    'The same Group IDs cannot be present in both the training and testing sets.');
            end
            
            warning('It''d probably be a good idea to check that the features/images are from the same source');
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
    end
    
    
    methods (Access = protected, Static = false)  
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false)  
    end
    
    
    methods (Access = private, Static = true) 
        
        
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

