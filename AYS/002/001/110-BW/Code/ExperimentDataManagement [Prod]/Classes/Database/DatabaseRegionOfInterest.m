classdef DatabaseRegionOfInterest < handle
    %DatabaseRegionOfInterest
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public) 
        dRegionOfInterestNumber double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger}
        
        oContourValidationResult ContourValidationResult {ValidationUtils.MustBeEmptyOrScalar} = ContourValidationResult.empty
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DatabaseRegionOfInterest(dRegionOfInterestNumber, oContourValidationResult)
            %obj = DatabaseRegionOfInterest(dRegionOfInterestNumber, oContourValidationResult)
            
            obj.dRegionOfInterestNumber = dRegionOfInterestNumber;
            obj.oContourValidationResult = oContourValidationResult;
        end
               
        function Update(obj)
            
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dRegionOfInterestNumber = GetRegionOfInterestNumber(obj)
            dRegionOfInterestNumber = obj.dRegionOfInterestNumber;
        end
        
        function oContourValidationResult = GetContourValidationResult(obj)
            oContourValidationResult = obj.oContourValidationResult;
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

