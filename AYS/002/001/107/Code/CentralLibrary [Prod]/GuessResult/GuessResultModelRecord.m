classdef GuessResultModelRecord
    %GuessResultModelRecord
    %
    % TODO
    
    % Primary Author: David DeVries
    % Created: June 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
            
    properties (SetAccess = immutable, GetAccess = public)        
        chModelUuid (1,36) char
        dtModelCreationTimestamp (1,1) datetime
        
        dtCreationTimestamp (1,1) datetime
    end
                
    properties (Access = private, Constant = true)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Abstract)
    end
    
    methods (Access = public, Static = false)
        
        function obj = GuessResultModelRecord(oModel)
            %obj = GuessResultModelRecord(oModel)
            %
            % SYNTAX:
            %  obj = GuessResultModelRecord(oModel)
            %
            % DESCRIPTION:
            %  Constructor for GuessResultModelRecord
            %
            % INPUT ARGUMENTS:
            %  oModel: TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
           
            arguments
                oModel (1,1) MachineLearningModel
            end
            
            obj.chModelUuid = oModel.GetUuid();
            obj.dtModelCreationTimestamp = oModel.GetCreationTimestamp();
            
            obj.dtCreationTimestamp = datetime();
        end  
        
        function chModelUuid = GetModelUuid(obj)
            %chModelUuid = GetModelUuid(obj)
            %
            % SYNTAX:
            %  chModelUuid = obj.GetModelUuid()
            %
            % DESCRIPTION:
            %  Returns the model's UUID
            %
            % INPUT ARGUMENTS:
            %  obj: GuessResultModelRecord object
            %
            % OUTPUTS ARGUMENTS:
            %  chUuid: Unique identifier for the model
            
            chModelUuid = obj.chModelUuid;
        end  
        
        function dtCreationTimestamp = GetCreationTimestamp(obj)
            %dtCreationTimestamp = GetCreationTimestamp(obj)
            %
            % SYNTAX:
            %  dtCreationTimestamp = obj.GetCreationTimestamp()
            %
            % DESCRIPTION:
            %  Returns the records's dtCreationTimestamp which is set at
            %  construction
            %
            % INPUT ARGUMENTS:
            %  obj: GuessResultModelRecord object
            %
            % OUTPUTS ARGUMENTS:
            %  dtCreationTimestamp: datetime object
            
            dtCreationTimestamp = obj.dtCreationTimestamp;
        end
        
        function bBool = eq(obj1, obj2)
            arguments
                obj1 (1,1) GuessResultModelRecord
                obj2 (1,1) GuessResultModelRecord
            end
            
            bBool =...
                strcmp(obj1.chModelUuid, obj2.chModelUuid) && ...
                obj1.dtModelCreationTimestamp == obj2.dtModelCreationTimestamp && ...
                obj1.dtCreationTimestamp == obj2.dtCreationTimestamp;
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

