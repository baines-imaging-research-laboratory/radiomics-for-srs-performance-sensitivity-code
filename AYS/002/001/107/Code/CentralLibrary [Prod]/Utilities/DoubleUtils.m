classdef (Abstract) DoubleUtils
    %DoubleUtils
    %
    % Provides useful functions that can be applied to objects of type
    % double
    
    % Primary Author: David DeVries
    % Created: May 10, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Static = true)
        
        function bBool = MatricesEqualWithinBound(mXdMatrix1, mXdMatrix2, dAbsoluteTolerance)
            %bBool = AreAllIndexClassesEqual(cNxCellArray)
            %
            % SYNTAX:
            %  bBool = AreAllIndexClassesEqual(cNxCellArray)
            %
            % DESCRIPTION:
            %  Returns "true" if and only if all objects within every index 
            %  of the cell array is of the same class
            %
            % INPUT ARGUMENTS:
            %  cNxCellArray: An N-D cell array of containing any types
            %
            % OUTPUTS ARGUMENTS:
            %  bBool: Question result
            
            % Primary Author: David DeVries
            % Created: Mar 8, 2019
            
            bBool = all(abs(mXdMatrix1(:) - mXdMatrix2(:)) < dAbsoluteTolerance);
        end
        
        
        function bBool = MatrixContainsOnlyIntegerValuedDoubles(mXdMatrix)
            %bBool = MatrixContainsONlyIntegerValuedDoubles(mXdMatrix)
            %
            % SYNTAX:
            %  bBool = DoubleUtils.MatrixContainsOnlyIntegerValuedDoubles(mXdMatrix)
            %
            % DESCRIPTION:
            %  Returns "true" if and only if all double values are:
            %  1) Not nan
            %  2) Not inf
            %  3) Are integer valued (e.g. x == floor(x))
            %
            % INPUT ARGUMENTS:
            %  mXdMatrix: An N-D cell array of containing doubles
            %
            % OUTPUTS ARGUMENTS:
            %  bBool: Question result
            
            % Primary Author: David DeVries
            % Created: Sept 1, 2019
            
            bBool = ...
                all(~isnan(mXdMatrix(:))) && ...
                all(~isinf(mXdMatrix(:))) && ...
                all(mXdMatrix(:) == floor(mXdMatrix(:)));
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

