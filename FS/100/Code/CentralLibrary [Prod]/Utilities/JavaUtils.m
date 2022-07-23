classdef (Abstract) JavaUtils
    %PythonUtils
    %
    % Provides functions calling Java functionality
    
    % Primary Author: David DeVries
    % Created: June 11, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function chUUID = CreateUUID()
            chUUID = char(java.util.UUID.randomUUID());
        end
        
        function dRandInt = GetRandomInteger(dUpperBound)
            % returns scalar random integer between 1 and dUpperBound
            % (inclusive)
            % this random integer is taken from the JAVA RANDOM NUMBER
            % GENERATOR and therefore is independent of the Matlab Random
            % Number Generator and its seed. This can be useful if you need
            % a random number, but you don't want to mess up the
            % reproducibility of some code
            
            oRng = java.util.Random;
            dRandInt = oRng.nextInt(dUpperBound) + 1; %java goes from 0 to (dUpperBound-1), so we add 1
        end
        
        function vdRandPerm = GetRandPerm(dVectorLength)
            vdRandPerm = zeros(1, dVectorLength);
            
            vdIndices = 1:dVectorLength;
            
            oRng = java.util.Random;
            
            for dVectorIndex=1:dVectorLength
                dSelection = oRng.nextInt(length(vdIndices)) + 1;
                
                vdRandPerm(dVectorIndex) = vdIndices(dSelection);
                vdIndices(dSelection) = [];
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private) % None
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

