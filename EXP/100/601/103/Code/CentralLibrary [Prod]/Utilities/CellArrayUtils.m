classdef (Abstract) CellArrayUtils
    %CellArrayUtils
    %
    % Provides useful functions that can be applied to cell array
    
    % Primary Author: David DeVries
    % Created: Mar 8, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public, Static = true)
        
        function bBool = AreAllIndexClassesEqual(cNxCellArray)
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
            %  cNxCellArray: An N-D cell array containing any type
            %
            % OUTPUT ARGUMENTS:
            %  bBool: Question result
            
            % Primary Author: David DeVries
            % Created: Mar 8, 2019
            
            if isempty(cNxCellArray)
                bBool = true;
            else
                bBool = true;
                chFirstElementClass = class(cNxCellArray{1});
                
                for dIndex=2:numel(cNxCellArray)
                    if ~strcmp(chFirstElementClass, class(cNxCellArray{dIndex}))
                        bBool = false;
                        break;
                    end
                end
            end
        end
        
        function bBool = AreEqual(cNxCellArray1, cNxCellArray2)
            %bBool = AreEqual(cNxCellArray1, cNxCellArray2)
            %
            % SYNTAX:
            %  bBool = AreEqual(cNxCellArray1, cNxCellArray2)
            %
            % DESCRIPTION:
            %  Returns "true" if and only if all objects within every index 
            %  of the cell array are identical
            % INPUT ARGUMENTS:
            %  cNxCellArray1: The first N-D cell array containing any type
            %  for comparison
            %  cNxCellArray2: The second N-D cell array containing any type
            %  for comparison
            %
            % OUTPUT ARGUMENTS:
            %  bBool: Question result

            bBool = true;
            
            dDims1 = size(cNxCellArray1);
            dDims2 = size(cNxCellArray2);
            
            if length(dDims1) == length(dDims2) && all(dDims1 == dDims2)
                for dIndex=1:numel(cNxCellArray1)
                    if cNxCellArray1{dIndex} ~= cNxCellArray2{dIndex}
                        bBool = false;
                        break;
                    end
                end
            else
                bBool = false;
            end
        end
        
        function bBool = ContainsExactString(cNxCellArray, chString)
            %bBool = ContainsExactString(cNxCellArray, chString)
            %
            % SYNTAX:
            %  bBool = ContainsExactString(cNxCellArray, chString)
            %
            % DESCRIPTION:
            %  Looping through the cell array by index, the function
            %  will return "true" if it finds a match to the character
            %  string input.
            %
            % INPUT ARGUMENTS:
            %  cNxCellArray: An N-D cell array containing any type
            %  chString: character string to be matched
            %
            % OUTPUT ARGUMENTS:
            %  bBool: Question result

            bBool = false;
            
            for dIndex=1:numel(cNxCellArray)
                if strcmp(cNxCellArray{dIndex}, chString)
                    bBool = true;
                    break;
                end
            end
        end
        
        function vdIndices = FindExactString(cNxCellArray, chString)
            %vdIndices = FindExactString(cNxCellArray, chString)
            %
            % SYNTAX:
            %  vdIndices = FindExactString(cNxCellArray, chString)
            %
            % DESCRIPTION:
            %  Looping through the cell array by index, the function
            %  will return a vector of indices for each cell that contained
            %  a match to the character string input.
            %
            % INPUT ARGUMENTS:
            %  cNxCellArray: An N-D cell array containing any type
            %  chString: character string to be matched
            %
            % OUTPUT ARGUMENTS:
            %  vdIndices: vector of type double containing indeces
            %  indicating a match to the input character string

            vdIndices = [];
            
            for dIndex=1:numel(cNxCellArray)
                if strcmp(cNxCellArray{dIndex}, chString)
                    vdIndices = [vdIndices, dIndex];
                end
            end
        end
        
        function bBool = ContainsSubString(cNxCellArray, chString)
            %bBool = ContainsSubString(cNxCellArray, chString)
            %
            % SYNTAX:
            %  bBool = ContainsSubString(cNxCellArray, chString)
            %
            % DESCRIPTION:
            %  Looping through the cell array by index, the function
            %  will return "true" if it finds the input character string
            %  as a substring of the cell's content
            %
            % INPUT ARGUMENTS:
            %  cNxCellArray: An N-D cell array containing any type
            %  chString: character string to be matched as a substring
            %
            % OUTPUT ARGUMENTS:
            %  bBool: Question result

            bBool = false;
            
            for dIndex=1:numel(cNxCellArray)
                if contains(cNxCellArray{dIndex}, chString)
                    bBool = true;
                    break;
                end
            end
        end
        
        function bBool = AreCellArraysOfCharArraysEqual(cNxCellArray1, cNxCellArray2)
            %bBool = AreCellArraysOfCharArraysEqual(cNxCellArray1, cNxCellArray2)
            %
            % SYNTAX:
            %  bBool = AreCellArraysOfCharArraysEqual(cNxCellArray1, cNxCellArray2)
            %
            % DESCRIPTION:
            %  The function will return "True" if the character arrays
            %  contained in the first cell array are equal to that of the 
            %  second cell array.
            %
            % INPUT ARGUMENTS:
            %  cNxCellArray1: The first N-D cell array containing any type
            %  for comparison
            %  cNxCellArray2: The second N-D cell array containing any type
            %  for comparison
            %
            % OUTPUT ARGUMENTS:
            %  bBool: Question result
            
            bBool = true;
           
           dDims1 = size(cNxCellArray1);
           dDims2 = size(cNxCellArray2);
            
           if length(dDims1) == length(dDims2) && all(dDims1 == dDims2)
               for dIndex=1:numel(cNxCellArray1)
                   if ~strcmp(cNxCellArray1{dIndex}, cNxCellArray2{dIndex})
                        bBool = false;
                        break;
                   end
               end               
           else
               bBool = false;
           end
        end
        
        function mXxMatrix = CellArrayOfObjects2MatrixOfObjects(cXoObjects)
            %mXxMatrix = CellArrayOfObjects2MatrixOfObjects(cXoObjects)
            %
            % SYNTAX:
            %  mXxMatrix = CellArrayOfObjects2MatrixOfObjects(cXoObjects)
            %
            % DESCRIPTION:
            %  Function converts the cell array of objects into a
            %  matrix of objects
            %
            % INPUT ARGUMENTS:
            %  cXoObjects: A cell array containing objects of any type
            %
            % OUTPUT ARGUMENTS:
            %  mXxMatrix: A matrix of objects of any type

            mXxMatrix = repmat(cXoObjects{1},size(cXoObjects));
            
            for dElementIndex=1:numel(cXoObjects)
                mXxMatrix(dElementIndex) = cXoObjects{dElementIndex};
            end
        end
        
        function cXxCellArray = MatrixOfObjects2CellArrayOfObjects(mXoObjects)
            %cXxCellArray = MatrixOfObjects2CellArrayOfObjects(mXoObjects)
            %
            % SYNTAX:
            %  cXxCellArray = MatrixOfObjects2CellArrayOfObjects(mXoObjects)
            %
            % DESCRIPTION:
            %  Function converts the matrix of objects into a
            %  cell array of objects
            %
            % INPUT ARGUMENTS:
            %  mXoObjects: A matrix of objects of any type
            %
            % OUTPUT ARGUMENTS:
            %  cXxCellArray: A cell array containing objects of any type

            cXxCellArray = cell(size(mXoObjects));
            
            for dElementIndex=1:numel(mXoObjects)
                cXxCellArray{dElementIndex} = mXoObjects(dElementIndex);
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

