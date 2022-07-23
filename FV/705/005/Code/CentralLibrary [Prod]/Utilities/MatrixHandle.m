classdef MatrixHandle < matlab.mixin.Copyable
    %MatrixHandle
    %
    % This class is used to store and pass a matrix by reference (e.g. handle)
    % This allows for the passing of large matrices without data being
    % copied.
    
    % Primary Author: David DeVries
    % Created: Mar 8, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = immutable, GetAccess = private)
        xMatrix % holds the actual matrix values. Will only be copied when "copy" is called on it
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = public)
        
        function obj = MatrixHandle(xMatrix)
            %obj = MatrixHandle(xMatrix)
            %
            % SYNTAX:
            %  obj = MatrixHandle(xMatrix)
            %
            % DESCRIPTION:
            %  Constructor for MatrixHandle
            %
            % INPUT ARGUMENTS:
            %  xMatrix: A matrix or cell array of any type
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            if ismatrix(xMatrix)
                obj.xMatrix = xMatrix;
            else
                error(...
                    'MatrixHandle:Constructor:InvalidDataType',...
                    'MatrixHandle objects may only be constructed with matrix objects');
            end
        end
        
        % >>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function varargout = size(obj, varargin)
            %varargout = size(obj, varargin)
            %
            % SYNTAX:
            %  varargout = size(obj, varargin) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "size" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  varargin: Refer to Matlab syntax
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = size(obj.xMatrix, varargin{:});
        end
        
        function varargout = length(obj)
            %varargout = length(obj)
            %
            % SYNTAX:
            %  varargout = length(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "length" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = length(obj.xMatrix);
        end
        
        function varargout = numel(obj)
            %varargout = numel(obj)
            %
            % SYNTAX:
            %  varargout = numel(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "numel" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = numel(obj.xMatrix);
        end
        
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "disp" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            disp(obj.xMatrix);
        end
        
        function varargout = isscalar(obj)            
            %varargout = isscalar(obj)
            %
            % SYNTAX:
            %  varargout = isscalar(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isscalar" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = isscalar(obj.xMatrix);
        end        
        
        function varargout = isvector(obj)
            %varargout = isvector(obj)
            %
            % SYNTAX:
            %  varargout = isvector(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isvector" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = isvector(obj.xMatrix);
        end
        
        function varargout = isempty(obj)
            %varargout = isempty(obj)
            %
            % SYNTAX:
            %  varargout = isempty(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isempty" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = isempty(obj.xMatrix);
        end
        
        function varargout = isfloat(obj)
            %varargout = isfloat(obj)
            %
            % SYNTAX:
            %  varargout = isfloat(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isfloat" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = isfloat(obj.xMatrix);
        end
        
        function varargout = isnumeric(obj)
            %varargout = isnumeric(obj)
            %
            % SYNTAX:
            %  varargout = isnumeric(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isnumeric" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = isnumeric(obj.xMatrix);
        end
        
        function varargout = isreal(obj)
            %varargout = isreal(obj)
            %
            % SYNTAX:
            %  varargout = isreal(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isreal" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax
            
            [varargout{1:nargout}] = isreal(obj.xMatrix);
        end
        
        function varargout = isnan(obj)
            %varargout = isnan(obj)
            %
            % SYNTAX:
            %  varargout = isnan(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isnan" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax

            [varargout{1:nargout}] = isnan(obj.xMatrix);
        end
                      
        function varargout = ismatrix(obj)
            %varargout = ismatrix(obj)
            %
            % SYNTAX:
            %  varargout = ismatrix(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "ismatrix" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax

            [varargout{1:nargout}] = ismatrix(obj.xMatrix);
        end 
                      
        function varargout = isobject(obj)
            %varargout = isobject(obj)
            %
            % SYNTAX:
            %  varargout = isobject(obj) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "isobject" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax

            [varargout{1:nargout}] = isobject(obj.xMatrix);
        end 
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "subsref" call to the stored matrix
            %  Can view this call as dereferncing the handle and getting
            %  the actual selected matrix back
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: Refer to Matlab syntax

            switch stSelection(1).type
                case '.' % allow built in function to run (member methods, etc.)
                    [varargout{1:nargout}] = builtin('subsref',obj, stSelection);
                case '()' % shoot off to builtin selection on the xMatrix
                    varargout = {builtin('subsref',obj.xMatrix, stSelection)};                    
                otherwise % invalid selection (e.g. {} selection)
                    error(...
                        'MatrixHandle:subsref:cellRefFromNonCell',...
                        'Brace indexing is not supported for variables of this type.');
            end
        end
        
        function dInd = end(obj, k, n)
            %dInd = end(obj, k, n)
            %
            % SYNTAX:
            %  dInd = end(obj, k, n) - Refer to Matlab syntax
            %
            % DESCRIPTION:
            %  Passes the "enn" call to the stored matrix
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  k: Refer to Matlab documentation
            %  n: Refer to Matlab documentation
            %
            % OUTPUTS ARGUMENTS:
            %  dInd: Refer to Matlab documentation

            dInd = builtin('end', obj.xMatrix, k, n);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected)
        
        function newObj = copyElement(obj)
            %newObj = copyElement(obj)
            %
            % SYNTAX:
            %  newObj = copyElement(obj)
            %
            % DESCRIPTION:
            %  Copied the handle by copying the stored matrix into the new
            %  object
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  newObj: Copied class object

            newObj = copyElement@matlab.mixin.Copyable(obj);
            
            newObj.xMatrix = obj.xMatrix;
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

