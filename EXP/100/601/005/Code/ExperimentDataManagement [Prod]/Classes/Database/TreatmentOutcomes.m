classdef TreatmentOutcomes
    %TreatmentOutcomes
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dtDateDeceased datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty
        
        dtDateOutOfFieldProgression datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty % empty means no progression out of field
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = TreatmentOutcomes(dtDateDeceased, dtDateOutOfFieldProgression)
            %obj = TreatmentOutcomes(dtDateDeceased, dtDateOutOfFieldProgression)
            arguments
                dtDateDeceased (1,1) datetime
                dtDateOutOfFieldProgression datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty
            end
           
            obj.dtDateDeceased = dtDateDeceased;
            obj.dtDateOutOfFieldProgression = dtDateOutOfFieldProgression;
        end 
                
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dtDateDeceased = GetDateDeceased(obj)
            dtDateDeceased = obj.dtDateDeceased;            
        end
        
        function dtDateOutOfFieldProgression = GetDateOutOfFieldProgression(obj)
            dtDateOutOfFieldProgression = obj.dtDateOutOfFieldProgression;
        end
        
        function bDidProgress = DidProgressOutOfField(obj)
            bDidProgress = ~isempty(obj.dtDateOutOfFieldProgression);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
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

