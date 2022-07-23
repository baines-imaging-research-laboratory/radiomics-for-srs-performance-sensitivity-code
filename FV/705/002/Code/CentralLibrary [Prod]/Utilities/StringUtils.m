classdef (Abstract) StringUtils
    %StringUtils
    %
    % Provides useful functions for working with strings
    
    % Primary Author: David DeVries
    % Created: Feb 28, 2020
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function chString = num2str_PadWithZeros(dNum, dMinStrLength)
            %chString = num2str_PadWithZeros(dNum, dMinStrLength)
            %
            % SYNTAX:
            %  chString = num2str_PadWithZeros(dNum, dMinStrLength)
            %
            % DESCRIPTION:
            %  Utility to convert a number of type double into a character
            %  string. If the minimum length input was not met, the string
            %  is prefixed with 0's.
            %  e.g. 123.45 with min length 10 becomes '0000123.45'
            %
            % INPUT ARGUMENTS:
            %  dNum: number of type double to be converted
            %  dMinStrLength: minimum number of characters to be returned
            %
            % OUTPUT ARGUMENTS:
            %  chString: character string holding converted number

            arguments
                dNum (1,1) double
                dMinStrLength (1,1) double {mustBeInteger, mustBePositive}
            end
            
            chString = num2str(dNum);
            
            dLen = length(chString);
            chString = [repmat('0', 1, dMinStrLength-dLen), chString];
        end
        
        function xPath = MakePathStringValidForPrinting(xPath)
            %xPath = MakePathStringValidForPrinting(xPath)
            %
            % SYNTAX:
            %  xPath = MakePathStringValidForPrinting(xPath)
            %
            % DESCRIPTION:
            %  Given a character string representing a path, this function
            %  will convert the '\' character into '\\' to make the path
            %  valid for printing.
            %
            % e.g. the path 'D:Temp\Subfolder' becomes 'D:Temp\Subfolder'
            %
            % INPUT ARGUMENTS:
            %  xPath: 
            %
            % OUTPUT ARGUMENTS:
            %  xPath: 

            if ~(ischar(xPath) && isrow(xPath)) && ~(isstring(xPath) && isscalar(xPath))
                error(...
                    'StringUtils:MakePathStringValidForPrinting:InvalidPath',...
                    'The path must be either a char row vector or scalar string.');
            end
            
            xPath = strrep(xPath, '\', '\\');
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

