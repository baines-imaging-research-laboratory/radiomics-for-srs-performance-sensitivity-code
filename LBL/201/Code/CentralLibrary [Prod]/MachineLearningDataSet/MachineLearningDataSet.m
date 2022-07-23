classdef (Abstract) MachineLearningDataSet
    %MachineLearningDataSet
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)   
        chUuid (1,36) char
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
        
        oSampleIds = GetSampleIds(obj)
        
        dNumberOfSamples = GetNumberOfSamples(obj)
        
        objLabelled = Label(obj, oSampleLabels) % this may not need to be defined here as an abstract class. This could be removed if a inheriting base class really can't 
        
        oRecord = GetRecordForModel(obj)
    end
    
    methods (Access = public, Static = false)
        
        function obj = MachineLearningDataSet()
            %obj = MachineLearningDataSet()
            %
            % SYNTAX:
            %  obj = MachineLearningDataSet()
            %
            % DESCRIPTION:
            %  Constructor for MachineLearningDataSet
            %
            % INPUT ARGUMENTS:
            %  None
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            obj.chUuid = JavaUtils.CreateUUID();
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
    end
    
    
    methods (Access = public, Static = true)       
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract)
        sStr = GetMultiModalityDataSetDispSummaryString(obj)
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

