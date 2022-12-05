classdef (Abstract) MachineLearningModel
    %MachineLearningModel
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 12, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = private, GetAccess = public)        
        chUuid (1,36) char 
        dtCreationTimestamp (1,1) datetime
        
        voDataSetRecordsForHyperParameterOptimization (1,:) MachineLearningDataSetRecordForModel = ImageCollectionRecordForModel.empty(1,0)
        voDataSetRecordsForTraining (1,:) MachineLearningDataSetRecordForModel = ImageCollectionRecordForModel.empty(1,0)      
        voDataSetRecordsForValidation (1,:) MachineLearningDataSetRecordForModel = ImageCollectionRecordForModel.empty(1,0)
        
        bDoesValidationInformTraining (1,1) logical = false
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = MachineLearningModel()
            %obj = MachineLearningModel()
            %
            % SYNTAX:
            %  obj = MachineLearningModel()
            %
            % DESCRIPTION:
            %  Constructor for MachineLearningModel
            %
            % INPUT ARGUMENTS:
            %  oModel: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            obj.chUuid = JavaUtils.CreateUUID();
            obj.dtCreationTimestamp = datetime();
        end    
        
        function chUuid = GetUuid(obj)
            %chUuid = GetUuid(obj)
            %
            % SYNTAX:
            %  chUuid = obj.GetUuid()
            %
            % DESCRIPTION:
            %  Returns the model's UUID which is set at cosntruction/major
            %  updates
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  chUuid: Unique identifier for the classifier 
            
            chUuid = obj.chUuid;
        end 
        
        function dtCreationTimestamp = GetCreationTimestamp(obj)
            %dtCreationTimestamp = GetCreationTimestamp(obj)
            %
            % SYNTAX:
            %  dtCreationTimestamp = obj.GetCreationTimestamp()
            %
            % DESCRIPTION:
            %  Returns the model's dtCreationTimestamp which is set at cosntruction/major
            %  updates
            %
            % INPUT ARGUMENTS:
            %  obj: Classifier object
            %
            % OUTPUTS ARGUMENTS:
            %  dtCreationTimestamp: datetime object
            
            dtCreationTimestamp = obj.dtCreationTimestamp;
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
        
        function obj = ModelChanged(obj)
            % since the model's different, switch up the UUID and creation
            % timestamp
            obj.chUuid = JavaUtils.CreateUUID();
            obj.dtCreationTimestamp = datetime();
        end
        
        function obj = AddDataSetToHyperParameterOptimizationRecord(obj, oMachineLearningDataSet)
            arguments
                obj (1,1) MachineLearningModel
                oMachineLearningDataSet (:,:) MachineLearningDataSet
            end
            
            oRecord = oMachineLearningDataSet.GetRecordForModel();
            
            if isempty(obj.voDataSetRecordsForHyperParameterOptimization)
                obj.voDataSetRecordsForHyperParameterOptimization = oRecord;
            else
                obj.voDataSetRecordsForHyperParameterOptimization = [obj.voDataSetRecordsForHyperParameterOptimization, oRecord];
            end
            
            obj = obj.ModelChanged();
        end
        
        function obj = AddDataSetToTrainingRecord(obj, oMachineLearningDataSet)
            arguments
                obj (1,1) MachineLearningModel
                oMachineLearningDataSet (:,:) MachineLearningDataSet
            end
            
            oRecord = oMachineLearningDataSet.GetRecordForModel();
            
            if isempty(obj.voDataSetRecordsForTraining)
                obj.voDataSetRecordsForTraining = oRecord;
            else
                obj.voDataSetRecordsForTraining = [obj.voDataSetRecordsForTraining, oRecord];
            end
            
            obj = obj.ModelChanged();
        end
        
        function obj = AddDataSetToValidationRecord(obj, oMachineLearningDataSet)
            arguments
                obj (1,1) MachineLearningModel
                oMachineLearningDataSet (:,:) MachineLearningDataSet
            end
            
            oRecord = oMachineLearningDataSet.GetRecordForModel();
            
            if isempty(obj.voDataSetRecordsForValidation)
                obj.voDataSetRecordsForValidation = oRecord;
            else
                obj.voDataSetRecordsForValidation = [obj.voDataSetRecordsForValidation, oRecord];
            end
            
            obj = obj.ModelChanged();
        end
        
        function obj = ClearValidationDataSetRecord(obj)
            obj.voDataSetRecordsForValidation = ImageCollectionRecordForModel.empty(1,0);
        end
        
        function MustBeValidDataSetForGuess(obj, oMachineLearningDataSetForGuess)
            arguments
                obj (1,1) MachineLearningModel
                oMachineLearningDataSetForGuess (:,:) MachineLearningDataSet
            end
            
            oDataSetRecordForGuess = oMachineLearningDataSetForGuess.GetRecordForModel();
            
            for dRecordIndex=1:length(obj.voDataSetRecordsForHyperParameterOptimization)
                oDataSetRecordForGuess.MustBeValidDataSetRecordForGuess(obj.voDataSetRecordsForHyperParameterOptimization(dRecordIndex));
            end
                
            for dRecordIndex=1:length(obj.voDataSetRecordsForTraining)
                oDataSetRecordForGuess.MustBeValidDataSetRecordForGuess(obj.voDataSetRecordsForTraining(dRecordIndex));
            end
            
            if obj.bDoesValidationInformTraining
                for dRecordIndex=1:length(obj.voDataSetRecordsForValidation)
                    oDataSetRecordForGuess.MustBeValidDataSetRecordForGuess(obj.voDataSetRecordsForValidation(dRecordIndex));
                end
            end
        end
        
        function MustBeValidDataSetForTrain(obj, oMachineLearningDataSetForTrain)
            arguments
                obj (1,1) MachineLearningModel
                oMachineLearningDataSetForTrain (:,:) MachineLearningDataSet
            end
            
            oDataSetRecordForTrain = oMachineLearningDataSetForTrain.GetRecordForModel();
            
            for dRecordIndex=1:length(obj.voDataSetRecordsForHyperParameterOptimization)
                oDataSetRecordForTrain.MustBeValidDataSetRecordForTrain(obj.voDataSetRecordsForHyperParameterOptimization(dRecordIndex));
            end
        end
        
        function MustBeValidDataSetForValidation(obj, oMachineLearningDataSetForValidation)
            arguments
                obj (1,1) MachineLearningModel
                oMachineLearningDataSetForValidation (:,:) MachineLearningDataSet
            end
            
            oDataSetRecordForValidation = oMachineLearningDataSetForValidation.GetRecordForModel();
            
            for dRecordIndex=1:length(obj.voDataSetRecordsForHyperParameterOptimization)
                oDataSetRecordForValidation.MustBeValidDataSetRecordForValidation(obj.voDataSetRecordsForHyperParameterOptimization(dRecordIndex));
            end
            
            for dRecordIndex=1:length(obj.voDataSetRecordsForTraining)
                oDataSetRecordForValidation.MustBeValidDataSetRecordForValidation(obj.voDataSetRecordsForTraining(dRecordIndex));
            end
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
        
        function MustNotContainDuplicatedSamples(obj)
            if obj.GetSampleIds().ContainsDuplicatedSamples()
                error(...
                    'LabelledImageCollection:MustNotContainDuplicatedSamples:Invalid',...
                    'The LabelledImageCollection object must not contain duplicated samples.');
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

