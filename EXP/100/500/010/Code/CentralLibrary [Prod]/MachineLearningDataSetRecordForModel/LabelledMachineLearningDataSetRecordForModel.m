classdef (Abstract) LabelledMachineLearningDataSetRecordForModel < MachineLearningDataSetRecordForModel
    %
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: July 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (SetAccess = immutable, GetAccess = public)
        oSampleLabelsRecord SampleLabelsRecordForModel {ValidationUtils.MustBeEmptyOrScalar(oSampleLabelsRecord)} = BinaryClassificationSampleLabelsRecordForModel.empty
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = LabelledMachineLearningDataSetRecordForModel(oLabelledMachineLearningDataSet)
            %obj = LabelledMachineLearningDataSetRecordForModel(oLabelledMachineLearningDataSet)
            %
            % SYNTAX:
            %  obj = LabelledMachineLearningDataSetRecordForModel(oLabelledMachineLearningDataSet)
            %
            % DESCRIPTION:
            %  Constructor for LabelledMachineLearningDataSetRecordForModel
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                
            arguments
                oLabelledMachineLearningDataSet (:,:) LabelledMachineLearningDataSet
            end
            
            % super-class constructor
            obj@MachineLearningDataSetRecordForModel(oLabelledMachineLearningDataSet);
            
            % set properities
            obj.oSampleLabelsRecord = oLabelledMachineLearningDataSet.GetSampleLabels().GetRecordForModel();
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
                obj (1,1) LabelledImageCollectionRecordForModel
                oRecordFromModelTraining (1,1) LabelledMachineLearningDataSetRecordForModel
            end
            
            % super-class calls
            MustBeValidDataSetRecordForGuess@MachineLearningDataSetRecordForModel(obj, oRecordFromModelTraining);
            
            % local checks
            obj.oSampleLabelsRecord.MustBeValidSampleLabelsRecordForGuess(oRecordFromModelTraining.oSampleLabelsRecord);
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
            %  validation
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
                obj (1,1) LabelledImageCollectionRecordForModel
                oRecordFromModelTraining (1,1) LabelledMachineLearningDataSetRecordForModel
            end
            
            % super-class calls
            MustBeValidDataSetRecordForValidation@MachineLearningDataSetRecordForModel(obj, oRecordFromModelTraining);
            
            % local checks
            obj.oSampleLabelsRecord.MustBeValidSampleLabelsRecordForValidation(oRecordFromModelTraining.oSampleLabelsRecord);
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

