classdef (Abstract) SampleLabelsRecordForModel
    %
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: July 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
                       
    properties (SetAccess = immutable, GetAccess = public)
        chSampleLabelsClass (1,:) char
        sLabelsSource (1,1) string
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = SampleLabelsRecordForModel(oSampleLabels)
            %obj = SampleLabelsRecordForModel(oSampleLabels)
            %
            % SYNTAX:
            %  obj = SampleLabelsRecordForModel(oSampleLabels)
            %
            % DESCRIPTION:
            %  Constructor for SampleLabelsRecordForModel
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            arguments
                oSampleLabels (:,1) SampleLabels
            end
                      
            obj.chSampleLabelsClass = class(oSampleLabels);
            obj.sLabelsSource = oSampleLabels.GetLabelsSource();
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
                obj (1,1) SampleLabelsRecordForModel
                oRecordFromModelTraining (1,1) SampleLabelsRecordForModel
            end
            
            % super-class calls
            % none
            
            % local checks
            if ~strcmp(obj.chSampleLabelsClass, oRecordFromModelTraining.chSampleLabelsClass)
                error(...
                    'SampleLabelsRecordForModel:MustBeValidDataSetRecordForGuess:SampleLabelsClassMismatch',...
                    ['The model was trained using a data set with sample labels of type "', obj.chSampleLabelsClass, '" where .Guess() is being called with a data set with sample labels of type "', oRecordFromModelTraining.chSampleLabelsClass, '". The sample labels classes used for .Train() and .Guess() must be the same.']);
            end
            
            if ~strcmp(obj.sLabelsSource, oRecordFromModelTraining.sLabelsSource)
                error(...
                    'SampleLabelsRecordForModel:MustBeValidDataSetRecordForGuess:LabelSourceMismatch',...
                    ['The model was trained using a data set with a sample labels source of "', char(obj.sLabelsSource), ", where .Guess() is being clalled with a data set with sample labels with a source of "', char(oRecordFromModelTraining.sLabelsSource), '". The label sources must be the same.']);
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
                obj (1,1) SampleLabelsRecordForModel
                oRecordFromModelTraining (1,1) SampleLabelsRecordForModel
            end
            
            % super-class calls
            % none
            
            % local checks
            if ~strcmp(obj.chSampleLabelsClass, oRecordFromModelTraining.chSampleLabelsClass)
                error(...
                    'SampleLabelsRecordForModel:MustBeValidDataSetRecordForValidation:SampleLabelsClassMismatch',...
                    ['The model was trained using a data set with sample labels of type "', obj.chSampleLabelsClass, '" where validation is being called with a data set with sample labels of type "', oRecordFromModelTraining.chSampleLabelsClass, '". The sample labels classes used for training and validation must be the same.']);
            end
            
            if ~strcmp(obj.sLabelsSource, oRecordFromModelTraining.sLabelsSource)
                error(...
                    'SampleLabelsRecordForModel:MustBeValidDataSetRecordForValidation:LabelSourceMismatch',...
                    ['The model was trained using a data set with a sample labels source of "', char(obj.sLabelsSource), ", where validation is being clalled with a data set with sample labels with a source of "', char(oRecordFromModelTraining.sLabelsSource), '". The label sources must be the same.']);
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

