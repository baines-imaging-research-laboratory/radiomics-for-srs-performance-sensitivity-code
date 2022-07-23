classdef BinaryClassificationSampleLabelsRecordForModel < SampleLabelsRecordForModel
    %
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: July 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (SetAccess = immutable, GetAccess = public)
        iPositiveLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0)
        iNegativeLabel (1,1) {ValidationUtils.MustBeIntegerClass} = int8(0)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = BinaryClassificationSampleLabelsRecordForModel(oBinaryClassificationSampleLabels)
            %obj = BinaryClassificationSampleLabelsRecordForModel(oBinaryClassificationSampleLabels)
            %
            % SYNTAX:
            %  obj = BinaryClassificationSampleLabelsRecordForModel(oBinaryClassificationSampleLabels)
            %
            % DESCRIPTION:
            %  Constructor for BinaryClassificationSampleLabelsRecordForModel
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                        
            arguments
                oBinaryClassificationSampleLabels (:,1) BinaryClassificationSampleLabels
            end
            
            % super-class constructor
            obj@SampleLabelsRecordForModel(oBinaryClassificationSampleLabels);
            
            % set properities
            obj.iPositiveLabel = oBinaryClassificationSampleLabels.GetPositiveLabel();
            obj.iNegativeLabel = oBinaryClassificationSampleLabels.GetNegativeLabel();
        end   
        
        function MustBeValidSampleLabelsRecordForGuess(obj, oRecordFromModelTraining)
            %MustBeValidSampleLabelsRecordForGuess(obj, oRecordFromModelTraining)
            %
            % SYNTAX:
            %  MustBeValidSampleLabelsRecordForGuess(obj, oRecordFromModelTraining)
            %
            % DESCRIPTION:
            %  Validates that obj, the sample labels record from the data set
            %  being used for Guess, is valid to use with a model that used
            %  the sample labels represented by oRecordFromModelTraining during
            %  training
            %
            % INPUT ARGUMENTS:
            %  obj: 
            %   SampleLabelsRecordForModel from the labelled data set
            %   which is being used for MachineLearningModel.Guess()
            %  oRecordFromModelTraining:
            %   SampleLabelsRecordForModel from a data set used
            %   during the training/HPO of the model on which .Guess() is
            %   being performed
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                obj (1,1) BinaryClassificationSampleLabelsRecordForModel
                oRecordFromModelTraining (1,1) SampleLabelsRecordForModel
            end
            
            % super-class calls
            MustBeValidSampleLabelsRecordForGuess@SampleLabelsRecordForModel(obj, oRecordFromModelTraining);
            
            % local checks
            if obj.iPositiveLabel ~= oRecordFromModelTraining.iPositiveLabel
                error(...
                    'BinaryClassificationSampleLabelsRecordForModel:MustBeValidDataSetRecordForGuess:PositiveLabelDefinitionMismatch',...
                    ['The model was trained using a data set with sample labels with a positive label definition of "', num2str(obj.iPositiveLabel), '" where .Guess() is being called with a data set with sample labels with a positive label definition of "', num2str(oRecordFromModelTraining.iPositiveLabel), '". The sample labels used for .Train() and .Guess() must have the same positive label definition.']);
            end
            
            if obj.iNegativeLabel ~= oRecordFromModelTraining.iNegativeLabel
                error(...
                    'BinaryClassificationSampleLabelsRecordForModel:MustBeValidDataSetRecordForGuess:NegativeLabelDefinitionMismatch',...
                    ['The model was trained using a data set with sample labels with a negative label definition of "', num2str(obj.iNegativeLabel), '" where .Guess() is being called with a data set with sample labels with a negative label definition of "', num2str(oRecordFromModelTraining.iNegativeLabel), '". The sample labels used for .Train() and .Guess() must have the same negative label definition.']);
            end
        end 
        
        function MustBeValidSampleLabelsRecordForValidation(obj, oRecordFromModelTraining)
            %MustBeValidSampleLabelsRecordForValidation(obj, oRecordFromModelTraining)
            %
            % SYNTAX:
            %  MustBeValidSampleLabelsRecordForValidation(obj, oRecordFromModelTraining)
            %
            % DESCRIPTION:
            %  Validates that obj, the sample labels record from the data set
            %  being used for validation, is valid to use with a model that used
            %  the sample labels represented by oRecordFromModelTraining during
            %  training
            %
            % INPUT ARGUMENTS:
            %  obj: 
            %   SampleLabelsRecordForModel from the labelled data set
            %   which is being used for validation
            %  oRecordFromModelTraining:
            %   SampleLabelsRecordForModel from a data set used
            %   during the training/HPO of the model on which validation is
            %   being performed
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            arguments
                obj (1,1) BinaryClassificationSampleLabelsRecordForModel
                oRecordFromModelTraining (1,1) SampleLabelsRecordForModel
            end
            
            % super-class calls
            MustBeValidSampleLabelsRecordForValidation@SampleLabelsRecordForModel(obj, oRecordFromModelTraining);
            
            % local checks
            if obj.iPositiveLabel ~= oRecordFromModelTraining.iPositiveLabel
                error(...
                    'BinaryClassificationSampleLabelsRecordForModel:MustBeValidDataSetRecordForValidation:PositiveLabelDefinitionMismatch',...
                    ['The model was trained using a data set with sample labels with a positive label definition of "', num2str(obj.iPositiveLabel), '" where validation is being called with a data set with sample labels with a positive label definition of "', num2str(oRecordFromModelTraining.iPositiveLabel), '". The sample labels used for training and validation must have the same positive label definition.']);
            end
            
            if obj.iNegativeLabel ~= oRecordFromModelTraining.iNegativeLabel
                error(...
                    'BinaryClassificationSampleLabelsRecordForModel:MustBeValidDataSetRecordForGuess:NegativeLabelDefinitionMismatch',...
                    ['The model was trained using a data set with sample labels with a negative label definition of "', num2str(obj.iNegativeLabel), '" where validation is being called with a data set with sample labels with a negative label definition of "', num2str(oRecordFromModelTraining.iNegativeLabel), '". The sample labels used for training and validation must have the same negative label definition.']);
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

