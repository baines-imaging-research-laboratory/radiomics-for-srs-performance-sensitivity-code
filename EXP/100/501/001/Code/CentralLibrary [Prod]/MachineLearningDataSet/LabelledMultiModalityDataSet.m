classdef LabelledMultiModalityDataSet < LabelledMachineLearningDataSet & MultiModalityDataSet
    %LabelledMultiModalityDataSet
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 16, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        oSampleLabels (:,1) SampleLabels = BinaryClassificationSampleLabels(int8(1),int8(1),int8(0))
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
            
    methods (Access = public, Static = false)
        
        function obj = LabelledMultiModalityDataSet(sDataSetName, varargin)
            %obj = LabelledMultiModalityDataSet(sDataSetName, varargin)
            %
            % SYNTAX:
            %  obj = LabelledMultiModalityDataSet(sDataSetName, oLabelledMachineLearningDataSet1, oLabelledMachineLearningDataSet2, oLabelledMachineLearningDataSet3,...)
            %
            % DESCRIPTION:
            %  Constructor for LabelledMultiModalityDataSet
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                sDataSetName (1,1) string
            end
            arguments (Repeating)
                varargin
            end
            
            % parse data sets
            c1oLabelledMachineLearningDataSets = varargin;
            dNumDataSets = length(c1oLabelledMachineLearningDataSets);
            
            if dNumDataSets == 0
                error(...
                    'LabelledMultiModalityDataSet:Constructor:InvalidNumberOfDataSets',...
                    'At least 1 MachineLearningDataSet must be provided at construction.');
            end
            
            % validate all data sets have same SampleIds
            oMasterDataSet = c1oLabelledMachineLearningDataSets{1};
            ValidationUtils.MustBeA(oMasterDataSet, 'LabelledMachineLearningDataSet');
            
            oMasterSampleLabels = oMasterDataSet.GetSampleLabels();
            
            for dDataSetIndex=2:dNumDataSets
                oDataSet = c1oLabelledMachineLearningDataSets{dDataSetIndex};
                
                ValidationUtils.MustBeA(oDataSet, 'LabelledMachineLearningDataSet');
                MustBeEqual(oMasterSampleLabels, oDataSet.GetSampleLabels());
            end
            
            % super-class constructor
            obj@LabelledMachineLearningDataSet();
            obj@MultiModalityDataSet(sDataSetName, c1oLabelledMachineLearningDataSets{:});
            
            % set properities
            obj.oSampleLabels = oMasterSampleLabels;
        end
        
        function disp(obj)
            % display sample IDs
            obj.GetSampleIds().PrintHeaders();
            obj.GetSampleLabels().PrintHeaders();
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                obj.GetSampleLabels().PrintRowForSample(dSampleIndex);
                
                fprintf(newline);
            end     
            
            obj.GetSampleIds().PrintFooter();
            fprintf(newline);
            
            % print summary of contained data sets
            obj.PrintContainedDataSets();
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function oSampleLabels = GetSampleLabels(obj)
            %oSampleLabels = GetSampleLabels(obj)
            %
            % SYNTAX:
            %  oSampleLabels = obj.GetSampleLabels()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: LabelledMultiModalityDataSet object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleLabels = obj.oSampleLabels;
        end
    end
    
    
    methods (Access = public, Static = true)       
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

