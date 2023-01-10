classdef (Abstract) MachineLearningDataSetRecordForModel
    %
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: July 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (SetAccess = immutable, GetAccess = public)
        chMachineLearningDataSetClass (1,:) char
        
        chUuid (1,36) char
        
        oSampleIds (:,1) SampleIds
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = MachineLearningDataSetRecordForModel(oMachineLearningDataSet)
            %obj = MachineLearningDataSetRecordForModel(oMachineLearningDataSet)
            %
            % SYNTAX:
            %  obj = MachineLearningDataSetRecordForModel(oMachineLearningDataSet)
            %
            % DESCRIPTION:
            %  Constructor for MachineLearningDataSetRecordForModel
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                       
            arguments
                oMachineLearningDataSet (:,:) MachineLearningDataSet
            end
            
            % set properities
            obj.chMachineLearningDataSetClass = class(oMachineLearningDataSet);
            obj.chUuid = oMachineLearningDataSet.GetUuid();
            obj.oSampleIds = oMachineLearningDataSet.GetSampleIds();
        end  
        
        function MustBeValidDataSetRecordForGuess(obj, oRecordFromModelTraining)
            %MustBeValidDataSetRecordForGuess(obj, oRecordFromModelTraining)
            %
            % SYNTAX:
            %  MustBeValidDataSetRecordForGuess(obj, oRecordFromModelTraining)
            %
            % DESCRIPTION:
            %  Validates that obj, the data set record from the data set
            %  being used for Guess, is valid to use with a model that used
            %  the data set represented by oRecordFromModelTraining during
            %  training
            %
            % INPUT ARGUMENTS:
            %  obj: 
            %   MachineLearningDataSetRecordForModel for the data set
            %   which is being used for MachineLearningModel.Guess()
            %  oRecordFromModelTraining:
            %   MachineLearningDataSetRecordForModel for a data set used
            %   during the training/HPO of the model on which .Guess() is
            %   being performed
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                obj (1,1) MachineLearningDataSetRecordForModel
                oRecordFromModelTraining (1,1) MachineLearningDataSetRecordForModel
            end
            
            % super-class calls
            % none
            
            % local checks
            if ~strcmp(obj.chMachineLearningDataSetClass, oRecordFromModelTraining.chMachineLearningDataSetClass)
                error(...
                    'MachineLearningDataSetRecordForModel:MustBeValidDataSetRecordForGuess:DataSetClassMismatch',...
                    ['The model was trained using a data set of type "', obj.chMachineLearningDataSetClass, '" where .Guess() is being called with a data set of type "', oRecordFromModelTraining.chMachineLearningDataSetClass, '". The data set classes used for .Train() and .Guess() must be the same.']);
            end
            
            if strcmp(obj.chUuid, oRecordFromModelTraining.chUuid)
                error(...
                    'MachineLearningDataSetRecordForModel:MustBeValidDataSetRecordForGuess:DataSetUuidMatch',...
                    'The UUIDs of the data sets used from .Train() and .Guess() are identical, and are therefore the identical data set. It is scientifically invalid to guess with the same data set used for train.');
            end
            
            if SampleIds.DoSampleIdsHaveOverlappingGroupIds(obj.oSampleIds, oRecordFromModelTraining.oSampleIds)
                error(...
                    'ImageCollectionRecordForModel:MustBeValidDataSetRecordForGuess:SampleGroupIdOverlap',...
                    'The model was trained using an data set that has overlapping sample Group IDs with the data set being used to guess with. This is scientifically invalid as then the training data may be correlated with the testing data.');
            end
            
            if obj.oSampleIds.ContainsDuplicatedSamples()
                error(...
                    'ImageCollectionRecordForModel:MustBeValidDataSetRecordForGuess:ContainsDuplicatedSamples',...
                    'The data set being used for .Guess() contains duplicated samples. While duplicated samples may be used during training or hyperparameter optimization, it is scientifically invalid to duplicate samples during testing.');
            end
        end
        
        function MustBeValidDataSetRecordForValidation(obj, oRecordFromModelTraining)
            %MustBeValidDataSetRecordForValidation(obj, oRecordFromModelTraining)
            %
            % SYNTAX:
            %  MustBeValidDataSetRecordForValidation(obj, oRecordFromModelTraining)
            %
            % DESCRIPTION:
            %  Validates that obj, the data set record from the data set
            %  being used for validation, is valid to use with a model that used
            %  the data set represented by oRecordFromModelTraining during
            %  training
            %
            % INPUT ARGUMENTS:
            %  obj: 
            %   MachineLearningDataSetRecordForModel for the data set
            %   which is being used for validation
            %  oRecordFromModelTraining:
            %   MachineLearningDataSetRecordForModel for a data set used
            %   during the training/HPO of the model on which validation is
            %   being performed
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                obj (1,1) MachineLearningDataSetRecordForModel
                oRecordFromModelTraining (1,1) MachineLearningDataSetRecordForModel
            end
            
            % super-class calls
            % none
            
            % local checks
            if ~strcmp(obj.chMachineLearningDataSetClass, oRecordFromModelTraining.chMachineLearningDataSetClass)
                error(...
                    'MachineLearningDataSetRecordForModel:MustBeValidDataSetRecordForValidation:DataSetClassMismatch',...
                    ['The model was trained using a data set of type "', obj.chMachineLearningDataSetClass, '" where validation is being done with a data set of type "', oRecordFromModelTraining.chMachineLearningDataSetClass, '". The data set classes used for training and validation must be the same.']);
            end
            
            if strcmp(obj.chUuid, oRecordFromModelTraining.chUuid)
                error(...
                    'MachineLearningDataSetRecordForModel:MustBeValidDataSetRecordForValidation:DataSetUuidMatch',...
                    'The UUIDs of the data sets used for training and validation are identical, and are therefore the identical data set. It is scientifically invalid to validate with the same data set used for train.');
            end
            
            if SampleIds.DoSampleIdsHaveOverlappingGroupIds(obj.oSampleIds, oRecordFromModelTraining.oSampleIds)
                error(...
                    'ImageCollectionRecordForModel:MustBeValidDataSetRecordForValidation:SampleGroupIdOverlap',...
                    'The model was trained using an data set that has overlapping sample Group IDs with the data set being used to validate with. This is scientifically invalid as then the training data may be correlated with the validation data.');
            end
            
            if obj.oSampleIds.ContainsDuplicatedSamples()
                error(...
                    'ImageCollectionRecordForModel:MustBeValidDataSetRecordForGuess:ContainsDuplicatedSamples',...
                    'The data set being used for validation contains duplicated samples. While duplicated samples may be used during training or hyperparameter optimization, it is scientifically invalid to duplicate samples during validation.');
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

