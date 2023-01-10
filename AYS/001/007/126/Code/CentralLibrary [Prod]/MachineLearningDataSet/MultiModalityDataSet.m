classdef MultiModalityDataSet < MachineLearningDataSet & MatrixContainer
    %MultiModalityDataSet
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 16, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)
        sDataSetName (1,1) string
        c1oMachineLearningDatasets (1,:) cell = {}
        oSampleIds (:,1) SampleIds
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
            
    methods (Access = public, Static = false)
        
        function obj = MultiModalityDataSet(sDataSetName, varargin)
            %obj = MultiModalityDataSet(sDataSetName, varargin)
            %
            % SYNTAX:
            %  obj = MultiModalityDataSet(sDataSetName, oMachineLearningDataSet1, oMachineLearningDataSet2, oMachineLearningDataSet3,...)
            %
            % DESCRIPTION:
            %  Constructor for MultiModalityDataSet
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
            c1oMachineLearningDataSets = varargin;
            dNumDataSets = length(c1oMachineLearningDataSets);
            
            if dNumDataSets == 0
                error(...
                    'MultiModalityDataSet:Constructor:InvalidNumberOfDataSets',...
                    'At least 1 MachineLearningDataSet must be provided at construction.');
            end
            
            % validate all data sets have same SampleIds
            oMasterDataSet = c1oMachineLearningDataSets{1};
            ValidationUtils.MustBeA(oMasterDataSet, 'MachineLearningDataSet');
            
            oMasterSampleIds = oMasterDataSet.GetSampleIds();
            
            for dDataSetIndex=2:dNumDataSets
                oDataSet = c1oMachineLearningDataSets{dDataSetIndex};
                
                ValidationUtils.MustBeA(oDataSet, 'MachineLearningDataSet');
                MustBeEqual(oMasterSampleIds, oDataSet.GetSampleIds());
            end
            
            % super-class constructor
            obj@MachineLearningDataSet();
            obj@MatrixContainer(oMasterSampleIds);
            
            % set properities
            obj.sDataSetName = sDataSetName;
            obj.c1oMachineLearningDatasets = c1oMachineLearningDataSets;
            obj.oSampleIds = oMasterSampleIds;
        end
        
        function disp(obj)
            % display sample IDs
            obj.GetSampleIds().PrintHeaders();
            fprintf(newline);
            
            % Print row by row
            for dSampleIndex=1:obj.GetNumberOfSamples()
                obj.GetSampleIds().PrintRowForSample(dSampleIndex);
                
                fprintf(newline);
            end     
            
            obj.GetSampleIds().PrintFooter();
            fprintf(newline);
            
            % print summary of contained data sets
            obj.PrintContainedDataSets();
        end
        
        function newObj = Label(obj, oSampleLabels)
            error('Under Construction');
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function oSampleIds = GetSampleIds(obj)
            %oSampleIds = GetSampleIds(obj)
            %
            % SYNTAX:
            %  oSampleIds = obj.GetSampleIds()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: MultiModalityDataSet object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            oSampleIds = obj.oSampleIds;
        end
        
        function dNumSamples = GetNumberOfSamples(obj)
            %dNumSamples = GetNumberOfSamples(obj)
            %
            % SYNTAX:
            %  dNumSamples = obj.GetNumberOfSamples()
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  obj: MultiModalityDataSet object
            %
            % OUTPUTS ARGUMENTS:
            %  TODO
            
            dNumSamples = obj.oSampleIds.GetNumberOfSamples();
        end
        
        function dNumDataSets = GetNumberOfContainedDataSets(obj)
            dNumDataSets = 0;
            
            for dDataSetIndex=1:length(obj.c1oMachineLearningDatasets)
                if isa(obj.c1oMachineLearningDatasets{dDataSetIndex}, 'MultiModalityDataSet')
                    dNumDataSets = dNumDataSets + obj.c1oMachineLearningDatasets{dDataSetIndex}.GetNumberOfContainedDataSets();
                else
                    dNumDataSets = dNumDataSets + 1;
                end
            end
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
                
        function newObj = CopyContainedMatrices(obj, newObj)
            %newObj = CopyContainedMatrices(obj, newObj)
            %
            % SYNTAX:
            %  newObj = CopyContainedMatrices(obj, newObj)
            %
            % DESCRIPTION:
            %  Copies any matrix contained in "obj" over to "newObj". If the
            %  contained matrices are handle objects they should be FULLY
            %  COPIED
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  newObj: Copied class object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copied class object
            
            newObj = obj;
        end
        
        function sStr = GetMultiModalityDataSetDispSummaryString(obj)
            error(...
                'MultiModalityDataSet:GetMultiModalityDataSetDispSummaryString:Invalid',...
                'A summary string should never be requested for this class type');
        end
        
        function PrintContainedDataSets(obj)            
            fprintf('Multi-Modality Data Set: %s', obj.sDataSetName);
            fprintf(newline);
            fprintf('Contained Data Sets:');
            fprintf(newline);
            
            dNumDataSets = obj.GetNumberOfContainedDataSets();
            dNumPadDigits = length(num2str(dNumDataSets));
            
            obj.PrintMultiModalityDataSetSummaries(1, dNumPadDigits);            
        end
    end
    
    
    methods (Access = protected, Static = true)      
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Abstract)
    end
    
    
    methods (Access = private, Static = false) 
        
        function dFullyNestedDataSetIndex = PrintMultiModalityDataSetSummaries(obj, dFullyNestedDataSetIndex, dNumPadDigits)
            
            for dDataSetIndex=1:length(obj.c1oMachineLearningDatasets)
                oDataSet = obj.c1oMachineLearningDatasets{dDataSetIndex};
                
                if isa(oDataSet, 'MultiModalityDataSet')
                    dFullyNestedDataSetIndex = oDataSet.PrintMultiModalityDataSetSummaries(dFullyNestedDataSetIndex, dNumPadDigits);
                else                    
                    fprintf(' %s - %s (%s)',...
                        StringUtils.num2str_PadWithZeros(dFullyNestedDataSetIndex,dNumPadDigits),...
                        class(oDataSet),...
                        oDataSet.GetMultiModalityDataSetDispSummaryString());
                    fprintf(newline);
                    
                    dFullyNestedDataSetIndex = dFullyNestedDataSetIndex + 1;
                end
            end
        end
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

