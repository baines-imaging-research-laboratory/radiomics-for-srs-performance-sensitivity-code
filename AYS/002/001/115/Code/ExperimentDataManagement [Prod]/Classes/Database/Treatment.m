classdef Treatment
    %Treatment
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        eType % TreatmentType
        
        dtTreatmentDate % MATLAB datetime
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Treatment(eType, dtTreatmentDate)
            %obj = Treatment(eType, dtTreatmentDate)
            obj.eType = eType;
            obj.dtTreatmentDate = dtTreatmentDate;
        end 
                
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function eType = GetType(obj)
            eType = obj.eType;
        end
                
        function dtTreatmentDate = GetTreatmentDate(obj)
            dtTreatmentDate = obj.dtTreatmentDate;
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

