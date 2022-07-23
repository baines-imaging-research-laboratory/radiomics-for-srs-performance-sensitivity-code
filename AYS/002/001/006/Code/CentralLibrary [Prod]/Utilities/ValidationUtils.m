classdef (Abstract) ValidationUtils
    %ValidationUtils
    %
    % Provides useful functions for property or argument validation
    
    % Primary Author: David DeVries
    % Created: Oct 3, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function DatetimesMustBeGreaterThanOrEqual(dt1, dt2)
            %DatetimesMustBeGreaterThanOrEqual(dt1, dt2)
            %
            % SYNTAX:
            %  DatetimesMustBeGreaterThanOrEqual(dt1, dt2)
            %
            % DESCRIPTION:
            %  Function that tests if time1 is >= time2. If false, an error
            %  is thrown.
            %
            % INPUT ARGUMENTS:
            %  dt1: variable of type datetime representing the later
            %       timepoint
            %  dt2: variable of type datetime representing the earlier
            %       timepoint
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            if ~(dt1 >= dt2)
                error(...
                    'ValidationUtils:DatetimesMustBeGreaterThanOrEqual:Invalid',...
                    'Datetime is not greater than or equal.');
            end
        end
        
        function MustBeIntegerClass(xVar)
            %MustBeIntegerClass(xVar)
            %
            % SYNTAX:
            %  MustBeIntegerClass(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is an integer.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: input variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            if ~isinteger(xVar)
                error(...
                    'ValidationUtils:MustBeIntegerClass:Invalid',...
                    'Variable is not an integer class.');
            end
        end
        
        function MustBeNumericOrLogical(xVar)
            %MustBeNumericOrLogical(xVar)
            %
            % SYNTAX:
            %  MustBeNumericOrLogical(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is either a
            %  number or a logical type.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: input variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            if ~isnumeric(xVar) && ~islogical(xVar)
                error(...
                    'ValidationUtils:MustBeNumericOrLogical:Invalid',...
                    'Variable is not numeric or logical.');
            end
        end
        
        function StringMustBeNotBlank(sStr)
            %StringMustBeNotBlank(sStr)
            %
            % SYNTAX:
            %  StringMustBeNotBlank(sStr)
            %
            % DESCRIPTION:
            %  Function that tests that the input string is not empty. The
            %  string will be stripped of white space prior to the test.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  sStr: input variable of type string
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            sStr = strtrim(sStr);
            
            if sStr == ""
                error(...
                    'ValidationUtils:StringMustBeNotBlank:Invalid',...
                    'String must not be "" after trimming white space.');
            end
        end
        
        function MustBeAxes(hAxes)
            %MustBeAxes(hAxes)
            %
            % SYNTAX:
            %  MustBeAxes(hAxes)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is an object of
            %  type Axes or UIAxes
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  hAxes: handle to axes
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                hAxes (1,1)
            end
            
            if ~isa(hAxes, 'matlab.graphics.axis.Axes') && ~isa(hAxes, 'matlab.ui.control.UIAxes')
                error(...
                    'ValidationUtils:MustBeAxes:Invalid',...
                    'The object must be a Matlab axes either of type matlab.graphics.axis.Axes or matlab.ui.control.UIAxes.');
            end
        end
        
        function MustBeValidRgbVector(vdVector_rgb)
            %MustBeValidRgbVector(vdVector_rgb)
            %
            % SYNTAX:
            %  MustBeValidRgbVector(vdVector_rgb)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is a vector of
            %  3 numbers of type double. The numbers must be positive and
            %  less than or equal to 1. This is designed to test the
            %  validity of the red, green, blue parameters of a color.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  vdVector_rgb: vector of 3 double values representing the
            %       red, green and blue channels of a color.
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                vdVector_rgb (1,3) double {mustBeNonnegative(vdVector_rgb), mustBeLessThanOrEqual(vdVector_rgb,1)}
            end
        end
        
        function MustBeValidAlphaValue(dAlpha)
            %MustBeValidAlphaValue(dAlpha)
            %
            % SYNTAX:
            %  MustBeValidAlphaValue(dAlpha)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is a
            %  number of type double. The number must be positive and
            %  less than or equal to 1. This is designed to validate the
            %  alpha value (opacity) for a color.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  dAlpha: input variable of type double representing the alpha
            %       channel for transparency of a color.
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                dAlpha (1,1) double {mustBeNonnegative(dAlpha), mustBeLessThanOrEqual(dAlpha,1)}
            end
        end
        
        function MustBeIncreasing(vxData)
            %MustBeIncreasing(vxData)
            %
            % SYNTAX:
            %  MustBeIncreasing(vxData)
            %
            % DESCRIPTION:
            %  Function that tests the condition of the vector of numbers 
            %  input ensuring that each number (as the index increases)
            %  is greater than the previous number.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  vxData: a vector of numbers of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                vxData (1,:) {mustBeNumeric, mustBeFinite, mustBeReal}
            end
            
            for dIndex=1:length(vxData)-1
                if vxData(dIndex+1) <= vxData(dIndex)
                    error(...
                        'ValidationUtils:MustBeIncreasing:Invalid',...
                        'Values must be strictly increasing from as index increases.');
                end
            end
        end
        
        function MustBeA(xVar, vsClassNames)
            %MustBeA(xVar, vsClassNames)
            %
            % SYNTAX:
            %  MustBeA(xVar, vsClassNames)
            %
            % DESCRIPTION:
            %  Function that tests that the variable input is of one of the
            %  classes in the provided vector of strings
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a number of any type
            %  vsClassNames: a vector of strings holding the names of the
            %       accepted classes
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                xVar
                vsClassNames (1,:) string
            end
            
            bMatchFound = false;
            
            for dClassIndex = 1:length(vsClassNames)
                if isa(xVar, vsClassNames(dClassIndex))
                    bMatchFound = true;
                    break;
                end
            end
                        
            if ~bMatchFound
                error(...
                    'ValidationUtils:MustBeA:Invalid',...
                    ['Must be of type from one of:', sprintf(repmat(' %s', 1, length(vsClassNames)), vsClassNames)]);
            end
        end
        
        function MustContainUniqueValues(xVar)
            %MustContainUniqueValues(xVar)
            %
            % SYNTAX:
            %  MustContainUniqueValues(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that each item in the vector is unique.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: input variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            if numel(xVar) ~= numel(unique(xVar))
                error(...
                    'ValidationUtils:MustContainUniqueValues:Invalid',...
                    'The vector does not contain unique values.');
            end
        end
        
        function MustBeNotEqual(xVar1, xVar2)
            %MustBeNotEqual(xVar1, xVar2)
            %
            % SYNTAX:
            %  MustBeNotEqual(xVar1, xVar2)
            %
            % DESCRIPTION:
            %  Function that tests that the first input variable is not 
            %  equal to the second input variable.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar1: a variable of any type
            %  xVar2: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            ValidationUtils.MustBeSameSize(xVar1, xVar2);
            
            if all(xVar1(:) == xVar2(:))
                error(...
                    'ValidationUtils:MustBeNotEqual:Invalid',...
                    'The values are equal.');
            end
        end
        
        function MustBeCharString(xVar)
            %MustBeCharString(xVar)
            %
            % SYNTAX:
            %  MustBeCharString(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is of the type
            %  character string.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                xVar {ValidationUtils.MustBeA(xVar,'char'), ValidationUtils.MustBeRowVector(xVar)}
            end
        end
        
        function MustBeScalar(xVar)
            %MustBeScalar(xVar)
            %
            % SYNTAX:
            %  MustBeScalar(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is a scalar
            %  type - a variable with only one element.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                xVar (1,1)
            end
        end
        
        function MustBeEmpty(xVar)
            %MustBeEmpty(xVar)
            %
            % SYNTAX:
            %  MustBeEmpty(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is empty.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                xVar
            end
            
            if ~isempty(xVar)
                error(...
                    'ValidationUtils:MustBeEmpty:Invalid',...
                    'Must be empty.');
            end
        end
        
        function MustBeEmptyOrScalar(xVar)
            %MustBeEmptyOrScalar(xVar)
            %
            % SYNTAX:
            %  MustBeEmptyOrScalar(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is either empty
            %  or a variable with only one element (scalar).
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                xVar
            end
            
            if ~isscalar(xVar) && ~isempty(xVar)
                error(...
                    'ValidationUtils:MustBeEmptyOrScalar:Invalid',...
                    'Must be either a scalar or empty.');
            end
        end
        
        function MustBeUnsignedInteger(xVar)
            %MustBeUnsignedInteger(xVar)
            %
            % SYNTAX:
            %  MustBeUnsignedInteger(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is one of the
            %  unsigned integer types (uint8, uint16, uint32, uint64)
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            switch class(xVar)
                case 'uint8'                    
                case 'uint16'                    
                case 'uint32'                    
                case 'uint64'                    
                otherwise
                    error(...
                    'ValidationUtils:MustBeUnsignedInteger:Invalid',...
                        'Must have type of uint8, uint16, uint32 or uint64.');
            end
        end
        
        function MustBeSameSize(xVar1, xVar2)
            %MustBeSameSize(xVar1, xVar2)
            %
            % SYNTAX:
            %  MustBeSameSize(xVar1, xVar2)
            %
            % DESCRIPTION:
            %  Function that tests that the first input variable is the
            %  same size as the second input variable.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar1: a variable of any type
            %  xVar2: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            vdDims1 = size(xVar1);
            vdDims2 = size(xVar2);
            
            if length(vdDims1) ~= length(vdDims2) || any(vdDims1 ~= vdDims2)
                error(...
                    'ValidationUtils:MustBeSameSize:Invalid',...
                    'The variables must have the same dimensions.');
            end
        end
        
        function MustBeSameClass(xVar1, xVar2)
            %MustBeSameClass(xVar1, xVar2)
            %
            % SYNTAX:
            %  MustBeSameClass(xVar1, xVar2)
            %
            % DESCRIPTION:
            %  Function that tests that the first input variable is the
            %  same class as the second input variable.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar1: a variable of any type
            %  xVar2: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            if ~strcmp(class(xVar1), class(xVar2))
                error(...
                    'ValidationUtils:MustBeSameClass:Invalid',...
                    'The variables must be the same class.');
            end
        end
        
        function MustBeRowVector(xVar)
            %MustBeRowVector(xVar)
            %
            % SYNTAX:
            %  MustBeRowVector(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is a row vector.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            if ~isrow(xVar)
                error(...
                    'ValidationUtils:MustBeRowVector:Invalid',...
                    'The variable must be a row vector.');
            end
        end
        
        function MustBeColumnVector(xVar)
            %MustBeColumnVector(xVar)
            %
            % SYNTAX:
            %  MustBeColumnVector(xVar)
            %
            % DESCRIPTION:
            %  Function that tests that the input variable is a column vector.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            if ~iscolumn(xVar)
                error(...
                    'ValidationUtils:MustBeRowVector:Invalid',...
                    'The variable must be a column vector.');
            end
        end
        
        function MustBeOfSize(xVar, vdDims)
            %MustBeOfSize(xVar, vdDims)
            %
            % SYNTAX:
            %  MustBeOfSize(xVar, vdDims)
            %
            % DESCRIPTION:
            %  Function that tests that the dimensions of the input
            %  variable matches the size given.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %  vdDims: a vector of doubles representing the required matrix
            %       dimensions.
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                xVar
                vdDims (1,:) double                
            end
            
            vbIsInf = vdDims == Inf;
            
            vdDims(vbIsInf) = 1;
            
            mustBeInteger(vdDims);
            mustBePositive(vdDims);
            mustBeFinite(vdDims)
            
            for dDimIndex=1:length(vdDims)
                if ~vbIsInf(dDimIndex) && vdDims(dDimIndex) ~= size(xVar, dDimIndex)
                    error(...
                        'ValidationUtils:MustBeOfSize:Invalid',...
                        'The dimensions of the variable are not correct.');
                end
            end
        end
        
        function MustBeOfLength(xVar, dLength)
            %MustBeOfLength(xVar, dLength)
            %
            % SYNTAX:
            %  MustBeOfLength(xVar, dLength)
            %
            % DESCRIPTION:
            %  Function that tests that the length of the input
            %  variable matches the length given.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of any type
            %  dLength: a variable of type double representing the required
            %       length of the input variable.
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                xVar
                dLength (1,1) double
            end
            
            if length(xVar) ~= dLength
                error(...
                    'ValidationUtils:MustBeOfLength:Invalid',...
                    ['The object was not of length ', num2str(dLength)]);
            end
        end
        
        function xCastVar = CastAScalarStringOrCharToString(xVar)
            %CastAScalarStringOrCharToString(xVar)
            %
            % SYNTAX:
            %  CastAScalarStringOrCharToString(xVar)
            %
            % DESCRIPTION:
            %  Function that will convert the input variable into a 
            %  variable of type string. It will only accept inputs of a
            %  scalar string or a character array. 
            %
            % INPUT ARGUMENTS:
            %  xVar: a variable of type character array or scalar string
            %
            % OUTPUT ARGUMENTS:
            %  xCastVar: the resulting string from a cast of the input
            %       variable.

            if isa(xVar,'char')
                xCastVar = string(xVar);
                
            elseif isa(xVar,'string')
                if ~isscalar(xVar)
                    error('ValidationUtils:CastAScalarStringOrCharToString:InvalidSize',...
                        'Input must be a scalar.')
                end
                xCastVar = xVar;
                
            else
                error('ValidationUtils:CastAScalarStringOrCharToString:InvalidType',...
                    'Input must be a scalar string or char.')
            end
        end
        
        function MustHaveCellEntriesOfType(cxCellArray, sClassName)
            %MustHaveCellEntriesOfType(cxCellArray, sClassName)
            %
            % SYNTAX:
            %  MustHaveCellEntriesOfType(cxCellArray, sClassName)
            %
            % DESCRIPTION:
            %  Function that tests the variables in each cell of the input
            %  cell array to ensure that it matches the specified class
            %  name.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  cxCellArray: a cell array containing variables of any type
            %  sClassName: a variable of type string indicating the
            %       name of the class to match
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                cxCellArray {ValidationUtils.MustBeA(cxCellArray, 'cell')}
                sClassName
            end
           
           for dIndex=1:numel(cxCellArray)
                ValidationUtils.MustBeA(cxCellArray{dIndex}, sClassName);
           end            
        end
        
        function MustHaveCellEntriesOfSize(cxCellArray, vdDims)
            %MustHaveCellEntriesOfSize(cxCellArray, vdDims)
            %
            % SYNTAX:
            %  MustHaveCellEntriesOfSize(cxCellArray, vdDims)
            %
            % DESCRIPTION:
            %  Function that tests the variables in each cell of the input
            %  cell array to ensure that it matches the specified
            %  dimensions.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  cxCellArray: a cell array containing variables of any type
            %  vdDims: a vector of doubles representing the required 
            %       dimension of the variable contained in the cell.
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

           arguments
               cxCellArray {ValidationUtils.MustBeA(cxCellArray, 'cell')}
               vdDims
           end
           
           for dIndex=1:numel(cxCellArray)
                ValidationUtils.MustBeOfSize(cxCellArray{dIndex}, vdDims);
           end
        end
        
        function MustBeFinite_Optimized(mxData)
            %MustBeFinite_Optimized(mxData)
            %
            % SYNTAX:
            %  MustBeFinite_Optimized(mxData)
            %
            % DESCRIPTION:
            %  Function that tests the input matrix to ensure it holds
            %  finite numbers.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  mxData: a matrix of data of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                mxData {mustBeNumeric}
            end
            
            if ~(isa(mxData, 'logical') || isa(mxData, 'uint8') || isa(mxData, 'int8') || isa(mxData, 'uint16') || isa(mxData, 'int16') || isa(mxData, 'uint32') || isa(mxData, 'int32') || isa(mxData, 'uint64') || isa(mxData, 'int64')) % these classes must be finite
                mustBeFinite(mxData);
            end
        end
        
        function MustBeNonnegative_Optimized(mxData)
            %MustBeNonnegative_Optimized(mxData)
            %
            % SYNTAX:
            %  MustBeNonnegative_Optimized(mxData)
            %
            % DESCRIPTION:
            %  Function that tests the input matrix to ensure it holds
            %  only positive numbers.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  mxData: a matrix of data of any type
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.

            arguments
                mxData {mustBeNumeric}
            end
            
            if ~(isa(mxData, 'logical') || isa(mxData, 'uint8') || isa(mxData, 'uint16') || isa(mxData, 'uint32') || isa(mxData, 'uint64')) % these classes must be non-negative
                mustBePositive(mxData);
            end
        end
        
        function MustBeInOrder(vxData, fnOrderMetric, sOrderDirection)
            % MustBeInOrder(vxData, fnOrderMetric, sOrderDirection)
            %
            % SYNTAX:
            %  MustBeInOrder(vxData, fnOrderMetric, sOrderDirection)
            %
            % DESCRIPTION:
            %  Function that tests if the members in vxData are in order
            %  according to sort.
            %  If false, an error is thrown.
            %
            % INPUT ARGUMENTS:
            %  vxData: a vector of data
            %  fnOrderMetric : can be left blank if the data vector can
            %   directly inputed into the sort function, otherwise should
            %   be set to a fn handle
            %  sOrderDirection : must be either "ascend" or "descent"
            %
            % OUTPUT ARGUMENTS:
            %  None
            %       An error will be thrown if the condition is not met.
            arguments
                vxData (:,1)
                fnOrderMetric
                sOrderDirection (1,1) string {mustBeMember(sOrderDirection, ["ascend", "descend"])}
            end
            
            if ~isempty(vxData)
                if isempty(fnOrderMetric)
                    [~,vdSortIndices] = sort(vxData, sOrderDirection);
                else
                    dNumElements = numel(vxData);
                    
                    c1xSortMetricValues = cell(dNumElements,1);
                    
                    for dIndex=1:dNumElements
                        c1xSortMetricValues{dIndex} = fnOrderMetric(vxData(dIndex));
                    end
                    
                    [~,vdSortIndices] = sort(CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1xSortMetricValues), sOrderDirection);
                end
                
                if ~all(vdSortIndices == (1:dNumElements)')
                    error(...
                        'ValidationUtils:MustBeInOrder:NotInOrder',...
                        'The elements in the vector were not in order.');
                end
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

