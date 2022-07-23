classdef (Abstract) MatrixContainer
    %MatrixContainer
    %
    % This class is used to store a feature table with samples along the
    % rows and different features along the column.
    % It is implemented to be manipulated much as typical matrix would
    % be, supporting directory row and index manipulating
    % The data of the feature table is held in an object that is passed
    % by value or reference
    
    % Primary Author: David DeVries
    % Created: Mar 8, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = private)
        c1vdDimensionSelections = {}
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)  
        
        % >>>>>>>>>>>>>>>>>> OVERLOADED FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<
         
        function disp(obj)
            %disp(obj)
            %
            % SYNTAX:
            %  disp(obj)
            %
            % DESCRIPTION:
            %  Displays the size of matrix container
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            disp('Dimensions:');
            disp(size(obj));
        end
        
        function vdDims = size(obj, varargin)
            %vdDims = size(obj, varargin)
            %
            % SYNTAX:
            %  vdDims = size(obj)
            %  vdDims = size(obj, nDim)
            %
            % DESCRIPTION:
            %  Returns the size of the object
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  nDim: Dimension number to return size of
            %
            % OUTPUTS ARGUMENTS:
            %  vdDims: Row vector of each dimension's size
            
            dNumDimensions = length(obj.c1vdDimensionSelections);
            vdDims = zeros(1,dNumDimensions);
            
            for dDimIndex=1:dNumDimensions
                vdDims(dDimIndex) = length(obj.c1vdDimensionSelections{dDimIndex});
            end
            
            if ~isempty(varargin)
                vdDims = vdDims(varargin{1});
            end
        end
        
        function dLength = length(obj)
            %dLength = length(obj)
            %
            % SYNTAX:
            %  dLength = length(obj)
            %
            % DESCRIPTION:
            %  Returns the length of the object (max of the output from
            %  "size")
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  dLength: The object's length
            
            dLength = max(size(obj));
        end
        
        function dIndex = end(obj, dDimension, dTotalNumIndices)
            %dIndex = end(obj, dDimension, dTotalNumIndices)
            %
            % SYNTAX:
            %  dIndex = end(obj, dDimension, dTotalNumIndices)
            %
            % DESCRIPTION:
            %  Overloading end such that obj(4:end,5:end) allows user to
            %  select to the end of the rows or cols
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  dDimension: Dimension the "end" is being used for
            %  dTotalNumIndices: The total number of dimensions being
            %                    indexed
            %
            % OUTPUTS ARGUMENTS:
            %  dIndex: Index to reach the "end" of the requested dimension
            
            dNumDimensions = length(obj.c1vdDimensionSelections);
            
            if dDimension > dNumDimensions
                dIndex = 1;
            else                
                dIndex = length(obj.c1vdDimensionSelections{dDimension});
            end
        end
        
        function varargout = subsref(obj, stSelection)
            %varargout = subsref(obj, stSelection)
            %
            % SYNTAX:
            %  varargout = subsref(obj, stSelection)
            %
            % DESCRIPTION:
            %  Overloading subsref to allow selections (e.g. a(1:3,4)) to
            %  be made on matrix containers. Also handles a.FnName() calls
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %  stSelection: Selection struct. Refer to Matlab documentation
            %               on "subsef"
            %
            % OUTPUTS ARGUMENTS:
            %  varargout: If is was a selection, a MatrixContainer object
            %             will be returned. If it was a a.FnName() call,
            %             anything could be returned
            
            switch stSelection(1).type
                case '.' % allow built in function to run (member methods, etc.)
                    [varargout{1:nargout}] = builtin('subsref',obj, stSelection);                
                case '()' % custom index selection code
                    newObj = obj;
                    
                    dNumDimensionsSelected = length(stSelection.subs);
                    
                    dNumDimensions = length(obj.c1vdDimensionSelections);
                    
                    for dDimIndex=1:dNumDimensionsSelected
                        xSelection = stSelection.subs{dDimIndex};
                            
                        if dDimIndex <= dNumDimensions                            
                            if isa(xSelection, 'char') && strcmp(xSelection, ':')
                                newObj.c1vdDimensionSelections{dDimIndex} = obj.c1vdDimensionSelections{dDimIndex}; % select all rows
                            else
                                vdCurrentSelection = obj.c1vdDimensionSelections{dDimIndex};
                                newObj.c1vdDimensionSelections{dDimIndex} = vdCurrentSelection(xSelection);
                            end
                        else
                            if ~((numel(xSelection) == 1 && xSelection == 1) || (isa(xSelection, 'char') && strcmp(xSelection, ':')))
                                error(...
                                    'MatrixContainer:badsubscript',...
                                    ['Index in position ', num2str(dDimIndex), ' exceeds array bounds (must not exceed 1).']);
                            end
                        end
                    end
                    
                    varargout = {newObj};
                otherwise % invalid selection (e.g. {} selection)
                    error(...
                        'FeatureTable:cellRefFromNonCell',...
                        'Brace indexing is not supported for variables of this type.');
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = protected, Abstract = true)
        
        newObj = CopyContainedMatrices(obj, newObj)
        %newObj = CopyContainedMatrices(obj, newObj)
        %
        % SYNTAX:
        %  newObj = CopyContainedMatrices(obj, newObj)
        %
        % DESCRIPTION:
        %  Copies any matrix contained in "obj" over to "newObj". If the
        %  contained matrices are handle objects they should be FULLY
        %  COPIED
        %
        % INPUT ARGUMENTS:
        %  obj: Class object
        %  newObj: Copied class object
        %
        % OUTPUTS ARGUMENTS:
        %  newObj: Copied class object
        
    end
    
    methods (Access = protected)                
        
        function obj = MatrixContainer(varargin)
            %obj = MatrixContainer(vdDims)
            %
            % SYNTAX:
            %  obj = MatrixContainer(mNxMatrix)
            %  obj = MatrixContainer('Dimensions',vdDims)
            %  obj = MatrixContainer(__ , vdDimSelection1, vdDimSelection2, ...)            %  
            %
            % DESCRIPTION:
            %  Super-class constructor for a MatrixContainer. A row vector
            %  of the MatrixContainer's "dimension" will be given. This
            %  will determine the initial selection of the container.
            %
            % INPUT ARGUMENTS:
            %  vdDims: Row vector of dimenions, typically the result from
            %          size(xMatrix).
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed class object
            
            
            if ( nargin >= 2 && strcmp(varargin{1}, 'Dimensions') )
                vdDims = varargin{2};
                dNumMatrixSizeArgs = 2;
            else
                vdDims = size(varargin{1});
                dNumMatrixSizeArgs = 1;
            end
            
            dNumDims = length(vdDims);
            
            if nargin == dNumMatrixSizeArgs
                c1vdDimensionSelections = cell(dNumDims,1);
                
                for dDimIndex=1:dNumDims
                    c1vdDimensionSelections{dDimIndex} = 1:vdDims(dDimIndex);
                end
                
                obj.c1vdDimensionSelections = c1vdDimensionSelections;
            else
                varargin = varargin(dNumMatrixSizeArgs+1:end);
                
                if length(varargin) ~= dNumDims
                    error(...
                        'MatrixContainer:Constuctor:SelectionDimsMismatch',...
                        'The number of given dimensions selections must equal the given dimensions of the matrix.');
                end
                
                for dDimIndex=1:dNumDims
                    if ~isrow(varargin{dDimIndex}) && ~isnumeric(varargin{dDimIndex})
                        error(...
                            'MatrixContainer:Constuctor:InvalidSelectionType',...
                            'The dimensions selection vectors must be given as numeric row vectors.');
                    elseif any(varargin{dDimIndex} > vdDims(dDimIndex) | varargin{dDimIndex} < 1)
                        error(...
                            'MatrixContainer:Constuctor:InvalidSelectionValues',...
                            'The dimensions selection vectors must have values between 1 and the length of the dimension.');
                    end
                end
                
                c1vdDimensionSelections = varargin;
            end
            
            obj.c1vdDimensionSelections = c1vdDimensionSelections;            
        end
        
        function vdSelection = GetRowSelection(obj)
            %vdSelection = GetRowSelection(obj)
            %
            % SYNTAX:
            %  vdSelection = GetRowSelection(obj)
            %
            % DESCRIPTION:
            %  Returns the currently selected rows of the container
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdSelection: Vector of currently selected rows
            
            vdSelection = obj.c1vdDimensionSelections{1};
        end
        
        function vdSelection = GetColumnSelection(obj)
            %vdSelection = GetColumnSelection(obj)
            %
            % SYNTAX:
            %  vdSelection = GetColulmSelection(obj)
            %
            % DESCRIPTION:
            %  Returns the currently selected columns of the container
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  vdSelection: Vector of currently selected columns
            
            vdSelection = obj.c1vdDimensionSelections{2};
        end
        
        function c1vdDimensionSelections = GetAllSelections(obj)
            %c1vdDimensionSelections = GetAllSelections(obj)
            %
            % SYNTAX:
            %c1vdDimensionSelections = GetAllSelections(obj)
            %
            % DESCRIPTION:
            %  Returns the currently selected indices of all dimensions of
            %  the matrix container
            %
            % INPUT ARGUMENTS:
            %  obj: Class object
            %
            % OUTPUTS ARGUMENTS:
            %  c1vdDimensionSelections: Cell array vector containing the
            %                           current selections of each
            %                           dimension. The first cell array
            %                           index is the current selection of
            %                           the 1st dimenions, and so on.
            
            c1vdDimensionSelections = obj.c1vdDimensionSelections;
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

