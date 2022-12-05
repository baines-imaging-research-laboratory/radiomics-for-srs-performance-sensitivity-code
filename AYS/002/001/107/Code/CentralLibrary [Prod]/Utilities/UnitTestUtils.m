classdef (Abstract) UnitTestUtils
    %UnitTestUtils
    %
    % Provides useful functions that can be used for testing
    
    % Primary Author: David DeVries & Carol Johnson
    % Created: Mar 8, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (Constant = true, GetAccess = private)
        chCheckObjectPublicProperitiesEqualErrorId = 'UnitTestUtils:CheckObjectPublicProperitiesEqual:NotEqual'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public, Static = true)
        
        function RunAllTestsForClassName(chDirectoryPath, chClassName, varargin)
            %RunAllTestsForClassName(chDirectoryPath, chClassName, varargin)
            %
            % SYNTAX:
            %  RunAllTestsForClassName(chDirectoryPath, chClassName)
            %  RunAllTestsForClassName(__, 'ReportCoverageFor', chCoverageDirectoryPath)
            %  RunAllTestsForClassName(__, 'HtmlRunnerReport', chRunnerReportFileName)
            %
            % DESCRIPTION:
            %  Runs all the tests in the folder given that begin with the
            %  provided class name.
            %  If the 'ReportCoverageFor' flag is given, a code coverage
            %  report of the unit tests will be given for all .m files
            %  within the given directory.
            %  If the 'HtmlRunnerReport' flag is given, a runner report
            %  will be generated for the unit tests in the given directory
            %  and automatically presented in the web browser.
            %
            %
            % INPUT ARGUMENTS:
            %  chDirectoryPath: Path to the folder containing the tests
            %  chClassName: Name of class to run tests for (case-sensitive)
            %  chCoverageDirectoryPath: Path to the folder containing the
            %                           code files to analyze coverage of
            %  chRunnerReportFileName: Name of report file for the html
            %                           runner report (valid only for
            %                           Matlab version 2018+)
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Primary Author: David DeVries
            % Created: Mar 8, 2019
            % Modified: Mar 15, 2019 Carol Johnson
            
            import matlab.unittest.TestSuite;
            
            oSuite = TestSuite.fromFolder(chDirectoryPath,'Name',[chClassName,'_*_Test/*']);
            
            [oRunner,bRunnerReportAvailable,chRunnerReportTempFileName] =...
                UnitTestUtils.BuildReportPlugins(varargin{:});
            oRunner.run(oSuite);
            
            if bRunnerReportAvailable
                web(chRunnerReportTempFileName,'-new');
            end
        end
        
        function RunAllTestsInDirectory(chDirectoryPath, varargin)
            %RunAllTestsInDirectory(chDirectoryPath, varargin)
            %
            % SYNTAX:
            %  RunAllTestsInDirectory(chDirectoryPath)
            %  RunAllTestsInDirectory(__, 'ReportCoverageFor', chCoverageDirectoryPath)
            %  RunAllTestsInDirectory(__, 'HtmlRunnerReport', chRunnerReportFileName)
            %
            % DESCRIPTION:
            %  Runs all the tests in the folder given.
            %  If the 'ReportCoverageFor' flag is given, a code coverage
            %  report of the unit tests will be given for all .m files
            %  within the given directory.
            %  If the 'HtmlRunnerReport' flag is given, a runner report
            %  will be generated for the unit tests in the given directory
            %  and automatically presented in the web browser.
            %
            % INPUT ARGUMENTS:
            %  chDirectoryPath: Path to the folder containing the tests
            %  chCoverageDirectoryPath: Path to the folder containing the
            %                           code files to analyze coverage of
            %  chRunnerReportFileName: Name of report file for the html
            %                           runner report (valid only for
            %                           Matlab version 2018+)
            %
            % OUTPUTS ARGUMENTS:
            %  None
            
            % Primary Author: David DeVries
            % Created: Mar 8, 2019
            % Modified: Mar 15, 2019 Carol Johnson
            
            import matlab.unittest.TestSuite;
            
            oSuite = TestSuite.fromFolder(chDirectoryPath);
            
            [oRunner,bRunnerReportAvailable,chRunnerReportTempFileName] =...
                UnitTestUtils.BuildReportPlugins(varargin{:});
            oRunner.run(oSuite);
            
            if bRunnerReportAvailable
                web(chRunnerReportTempFileName,'-new');
            end
        end
        
        function VerifyErrorIdentifier(testCase, hFunctionToTest, chExpectedMessageIdentifier, dDepth)
            %VerifyErrorIdentifier(testCase, hFnToTest, chExpectedMessageIdentifier, dDepth)
            %
            % SYNTAX:
            %  VerifyErrorIdentifier(testCase, hFnToTest, chExpectedMessageIdentifier, dDepth)
            %
            % DESCRIPTION:
            %  This function is used instead of the unittest verifyError
            %  function in order to relax the comparison of error messages
            %  returned by Matlab from different versions.
            %  It will parse the Matlab error message identifier by ':' and
            %  based on the depth specified by the user, make comparisons
            %  to that depth.
            %
            % INPUTS:   testCase    : object of the unit test being run
            %           hFnToTest   : handle to function being tested
            %           chExpectedMessageIdentifier : character array of
            %                           the error message expected
            %           dDepth : double defining how deep into the actual
            %                     error message identifer that the user is
            %                     willing to accept as a match.
            % OUTPUTS: none
            
            % Primary Author: Carol Johnson
            % Created: Mar 20, 2019
            
            bErrorHappened = false;
            bTestMsgEquality = false;
            
            try
                hFunctionToTest();
            catch e
                bErrorHappened = true;
            end
            
            if bErrorHappened
                c1chActualErrorMsgSplit = strsplit(e.identifier,':');
                c1chExpectedMsgSplit = strsplit(chExpectedMessageIdentifier,':');
                
                if (length(c1chActualErrorMsgSplit) == length(c1chExpectedMsgSplit))
                    chTrimmedMsg = c1chActualErrorMsgSplit(:,1:dDepth);
                    chShorterMsg = c1chExpectedMsgSplit(:,1:dDepth);
                elseif (length(c1chActualErrorMsgSplit) > length(c1chExpectedMsgSplit))
                    chTrimmedMsg = c1chActualErrorMsgSplit(:,1:dDepth);
                    chShorterMsg = c1chExpectedMsgSplit;
                else
                    chTrimmedMsg = c1chExpectedMsgSplit(:,1:dDepth);
                    chShorterMsg = c1chActualErrorMsgSplit;
                end
                bTestMsgEquality = isequal(chTrimmedMsg,chShorterMsg);
            end
            
            verifyTrue(testCase,bTestMsgEquality);
        end
        
        function VerifyObjectPublicPropertiesAreEqual(testCase, objActual, objExpected, NameValueArgs)
            % VerifyObjectPublicPropertiesAreEqual(testCase, objActual, objExpected, NameValueArgs)
            %
            % SYNTAX:
            %  ValidationUtils.VerifyObjectPublicPropertiesAreEqual(testCase, objActual, objExpected)
            %  ValidationUtils.VerifyObjectPublicPropertiesAreEqual(__, __, __, Name, Value)
            %
            %  Name-Value Pairs:
            %   'AbsTol': Scalar double. Absolute tolerance for numerical comparisons
            %   'RelTol': Scalar double. Relative tolerance for numerical comparisons
            %             (cannot set both 'AbsTol' and 'RelTol')
            %   'IgnoringProperties': Cell array of char vectors or vector
            %                         of strings. Names of public
            %                         properities in classes to ignore.
            %
            % DESCRIPTION:
            %  This function is used to compare two classes objects by ONLY
            %  comparing their public properties. If objects contain
            %  objects, these objects are compared recursively. Public
            %  properities that should not be compared can be specified
            %  using the name-value argument.
            %
            % INPUTS:
            %  testCase: matlab.unittest.TestCase object
            %  objActual: the actual object computed
            %  objExpected: the known expected object
            %
            % OUTPUTS:
            %  none
            
            % Primary Author: David DeVries
            % Created: Oct 9, 2019
            
            arguments
                testCase (1,1) {ValidationUtils.MustBeA(testCase, 'matlab.unittest.TestCase')}
                objActual
                objExpected
                NameValueArgs.AbsTol (1,1) double
                NameValueArgs.RelTol (1,1) double
                NameValueArgs.IgnoringProperties = {}% cell array of char vectors or string array
                NameValueArgs.ForceCustomCompare = false
            end
            
            if isfield(NameValueArgs, 'AbsTol') && isfield(NameValueArgs, 'RelTol')
                error(...
                    'UnitTestUtils:VerifyObjectPublicPropertiesAreEqual:InvalidTolerances',...
                    'Cannot specific both a relative and absolute tolerance.');
            end
            
            
            
            try
                if NameValueArgs.ForceCustomCompare
                    error('Forcing custom compare'); % this error will be caught and then trigger the custom repair
                end
                
                % import required packages
                import matlab.unittest.constraints.*;
                
                % set up comparator
                compObj = PublicPropertyComparator('Recursively', true);
                
                % check/set tolerances
                if isempty(NameValueArgs.IgnoringProperties)
                    c1xVarargin = {};
                else
                    c1xVarargin = {'IgnoringProperties', NameValueArgs.IgnoringProperties};
                end
                
                if isfield(NameValueArgs, 'AbsTol')
                    compObj = compObj.supportingAllValues('Within', AbsoluteTolerance(NameValueArgs.AbsTol), c1xVarargin{:});
                elseif isfield(NameValueArgs, 'RelTol')
                    compObj = compObj.supportingAllValues('Within', RelativeTolerance(NameValueArgs.RelTol), c1xVarargin{:});
                else
                    compObj = compObj.supportingAllValues(c1xVarargin{:});
                end
                
                % perform compare
                testCase.verifyThat(objActual, IsEqualTo(objExpected,'Using',compObj));
            catch e
                if isfield(NameValueArgs, 'AbsTol')
                    c1xTolVarargin = {'AbsTol', NameValueArgs.AbsTol};
                elseif isfield(NameValueArgs, 'RelTol')
                    error(...
                        'UnitTestUtils:VerifyObjectPublicPropertiesAreEqual:CannotUseRelTolForCustomCompare',...
                        'If the custom compare code must be used, ''RelTol'' is not valid.');
                else
                    c1xTolVarargin = {};
                end
                
                bAreEqual = true;
                chTraceBack = '';
                
                try
                    UnitTestUtils.CheckObjectPublicProperitiesEqual(objActual, objExpected, 'obj', NameValueArgs.IgnoringProperties, c1xTolVarargin);
                catch e
                    if ~strcmp(e.identifier, UnitTestUtils.chCheckObjectPublicProperitiesEqualErrorId)
                        rethrow(e);
                    end
                    
                    bAreEqual = false;
                    chTraceBack = e.message;
                end
                
                testCase.verifyTrue(bAreEqual, chTraceBack);
            end
        end
        
        function VerifyEqualityOfPRToolsClassifier(testCase,oTstClassifier,oExpClassifier)
            %VerifyEqualityOfPRToolsClassifier(testCase,oTstClassifier,oExpClassifier)
            %
            % SYNTAX:
            %   VerifyEqualityOfPRToolsClassifier(testCase,oTstClassifier,oExpClassifier)
            %
            % DESCRIPTION:
            %   This helper function is called when the implementation of the
            %   constructed classifier is PRTools. Fields within the constructed
            %   classifier that are stored as prmapping objects must be
            %   extracted and compared as structs.
            %   Version fields that hold a date/time stamp are also removed
            %   since these are set at run time.
            %
            % INPUTS:
            %   testCase: unit test object from calling test function
            %   oTstClassifier: object of type Classifier constructed for
            %       this test.
            %   oExpClassifier: object of type Classifier loaded from disk
            %       with expected results.
            
            % Author: C.Johnson
            % Date:   May 23, 2019
            % Modified: Oct 16, 2019 CJ
            %           - Add in test for oTrainedClassifier comparison
            %           - Modify to use UnitTestUtils VerifyObjectPublicPropertiesAreEqual
            %               to ensure equality of properties
            
            %
            % In order to verify equality of a classifier generated for the
            % PRTools implementation, the objects are converted to structs.
            % There are 3 levels of verification that must be completed.
            
            % >>>>>>>>>>>>>>>>>> Level 1 Comparison <<<<<<<<<<<<<<<<<<<<<<
            %           ConstructedClassifier (test and expected)
            %              |
            %              | field
            %              | field
            %              | hClassifier (prmapping - extract)
            %              | field
            %              | field n
            %
            %        Here the hClassifier is removed and the remaining
            %        shell is tested for equality.
            
            stTstClassifier = struct(oTstClassifier);
            stExpClassifier = struct(oExpClassifier);
            
            c1sRmFields = {'hClassifier','oTrainedClassifier','chUuid'};
            stTstClassifierShell = rmfield(stTstClassifier,c1sRmFields);
            stExpClassifierShell = rmfield(stExpClassifier,c1sRmFields);
            
            UnitTestUtils.VerifyObjectPublicPropertiesAreEqual(testCase,stTstClassifierShell,...
                stExpClassifierShell,'AbsTol',eps);
            
            % >>>>>>>>>> Level 2.1 oTrainedClassifier Comparison <<<<<<<<<<
            %    repeat above test for oTrainedClassifier if it exists
            %    (Classifier may not have been trained yet)
            
            if ~isempty(oTstClassifier.oTrainedClassifier)
                stPRToolsTstTrainedClassifier = struct(oTstClassifier.oTrainedClassifier);
                stPRToolsExpTrainedClassifier = struct(oExpClassifier.oTrainedClassifier);
                
                stPRToolsTstTrainedClassifierShell = rmfield(stPRToolsTstTrainedClassifier,'version');
                stPRToolsExpTrainedClassifierShell = rmfield(stPRToolsExpTrainedClassifier,'version');
                stPRToolsTstTrainedClassifierShell.data = [];
                stPRToolsExpTrainedClassifierShell.data = [];
                
                UnitTestUtils.VerifyObjectPublicPropertiesAreEqual(testCase,stPRToolsTstTrainedClassifierShell,...
                    stPRToolsExpTrainedClassifierShell,'AbsTol',eps);
            end
              % Needs some rethinking. The variable
              % stPRToolsTstTrainedClassifier.data is different for all
              % classifiers.
            % >>>>>>>>>>>>> Level 3 PRTools data Comparison <<<<<<<<<<<<<<<
            %           data (test and expected extracted from Level 2)
            %              |
            %              | field
            %              | field
            %              | field
            %              | field n
            %              | version  (remove - date/time stamp)
            %
            %        Here the version time stamp is removed and the
            %        remaining shell is tested for equality.
            
            %stPRToolsTstData = struct(stPRToolsTstTrainedClassifier.data{2});
            %stPRToolsExpData = struct(stPRToolsExpTrainedClassifier.data{2});
            %stPRToolsTstDataShell = rmfield(stPRToolsTstData,'version');
            %stPRToolsExpDataShell = rmfield(stPRToolsExpData,'version');
            
            %UnitTestUtils.VerifyObjectPublicPropertiesAreEqual(testCase,stPRToolsTstDataShell,...
            %    stPRToolsExpDataShell,'AbsTol',eps);
            
        end
        
        function OverrideCallsToInput(testCase, varargin)
            import matlab.unittest.fixtures.PathFixture;
            
            chTempDir = tempname;
            mkdir(chTempDir);
            
            copyfile(...
                which('UnitTestInputSpoofer.m'),...
                fullfile(chTempDir, 'input.m'));
            
            testCase.applyFixture(PathFixture(chTempDir));
            
            global c1xSpoofedInputResponsesForUnitTest;
            c1xSpoofedInputResponsesForUnitTest = varargin;
            
            global chUnitTestUtilsOverrideCallstoInputTempDirPath;
            chUnitTestUtilsOverrideCallstoInputTempDirPath = chTempDir;
        end
        
        function OverrideCallsToInputTeardown()
            global c1xSpoofedInputResponsesForUnitTest;
            global chUnitTestUtilsOverrideCallstoInputTempDirPath;
            
            c1xSpoofedInputResponsesForUnitTest = [];
            
            delete(fullfile(chUnitTestUtilsOverrideCallstoInputTempDirPath, 'input.m'));
            rmdir(chUnitTestUtilsOverrideCallstoInputTempDirPath);
            chUnitTestUtilsOverrideCallstoInputTempDirPath = [];
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
    
    methods (Access = private, Static = true)
        function ThrowSyntaxErrorMessage()
            %ThrowSyntaxErrorMessage()
            %
            % SYNTAX:
            %  ThrowSyntaxErrorMessage()
            %
            % DESCRIPTION:
            %  This function will throw an error message for any syntax
            %  violations discovered by the calling function.
            %
            % INPUTS: none
            % OUTPUTS: none
            
            % Primary Author: Carol Johnson
            % Created: Mar 15, 2019
            
            chMsg = strcat('UnitTestUtils:RunAllTestsForClassName:InvalidParameters',...
                'Invalid parameters. Usage:  RunAllTestsForClassName(chDirectoryPath, chClassName,',...
                '''ReportCoverageFor'', chCoverageDirectoryPath,',...
                '''HtmlRunnerReport'', chRunnerReportDirectoryPath)');
            error(chMsg);
        end
        
        function [oRunner,...
                bRunnerReportAvailable,...
                chRunnerReportTempFileName] = BuildReportPlugins(varargin)
            %[oRunner,bRunnerReportAvailable,chRunnerReportTempFileName] =...
            %               BuildReportPlugins(chDirectoryPath, varargin)
            %
            % SYNTAX:
            %  [stRunnerReport] = BuildReportPlugins(chDirectoryPath, varargin)
            %
            % DESCRIPTION:
            %  This function will generate the plugins for the unit tests
            %  based on the flags provided in the input variable arguments
            %  passed in by the calling function.
            %
            % INPUT ARGUMENTS:
            %  varargin: List of input variables containing the name/value
            %               pairs for the test report options passed in
            %               by the calling script.
            %
            % OUTPUTS ARGUMENTS:
            %  oRunner: TestRunner class object created to run tests
            %  bRunnerReportAvailable: Flag to indicate whether the runner
            %                           reports are available - must be at
            %                           least Matlab version 2018 (ie.
            %                           version # 9.4...)
            %  chRunnerReportTempFileName: full path/filename for the
            %                               runner report in the temporary
            %                               directory
            
            % Primary Author: Carol Johnson
            % Created: Mar 15, 2019
            
            import matlab.unittest.TestRunner;
            import matlab.unittest.plugins.CodeCoveragePlugin;
            import matlab.unittest.plugins.TestRunnerPlugin
            import matlab.unittest.plugins.TestReportPlugin;
            
            oRunner = TestRunner.withTextOutput;
            chRunnerReportTempFileName = '';
            bRunnerReportAvailable = false;
            
            if ~isempty(varargin)
                if ~mod(length(varargin),2) % even number of name value pairs
                    for dVarIndex=1:2:length(varargin)
                        
                        switch varargin{dVarIndex}
                            case 'ReportCoverageFor'
                                if ischar(varargin{dVarIndex+1})
                                    chCoverageDirectoryPath = varargin{dVarIndex+1};
                                    oRunner.addPlugin(CodeCoveragePlugin.forFolder(chCoverageDirectoryPath));
                                else
                                    UnitTestUtils.ThrowSyntaxErrorMessage();
                                end
                                
                            case 'HtmlRunnerReport'
                                dVersionPrefix = str2double(extractBetween(version,1,3));
                                if (dVersionPrefix < 9.4) % prior to Matlab v2018
                                    bRunnerReportAvailable = false;
                                    break;
                                else
                                    bRunnerReportAvailable = true;
                                end
                                if ischar(varargin{dVarIndex+1})
                                    chRunnerReportName = varargin{dVarIndex+1};
                                    chRunnerReportTempFileName = strcat(tempdir,chRunnerReportName);
                                    oPlugin = TestReportPlugin.producingHTML(tempdir,'MainFile',chRunnerReportName);
                                    oRunner.addPlugin(oPlugin);
                                else
                                    UnitTestUtils.ThrowSyntaxErrorMessage();
                                end
                                
                            otherwise
                                UnitTestUtils.ThrowSyntaxErrorMessage();
                        end %switch
                        
                    end % for each name value pair
                    
                else % if variables not in pairs
                    UnitTestUtils.ThrowSyntaxErrorMessage();
                end % if even number name value pairs
                
            end % if empty name value pairs
            
        end % function
        
        function CheckObjectPublicProperitiesEqual(xObj1, xObj2, chTraceBack, c1chIgnoredProperties, c1xToleranceNameValuePair)
            % get object out of cell array if the cell array is a scalar
            if iscell(xObj1) && iscell(xObj2) && numel(xObj1) == 1 && numel(xObj2) == 1
                xObj1 = xObj1{1};
                xObj2 = xObj2{1};
            end
            
            % check that the obj dimensions and classes agree
            vdDims1 = size(xObj1);
            vdDims2 = size(xObj2);
            
            if ~strcmp(class(xObj1), class(xObj2)) || length(vdDims1) ~= length(vdDims2) || any(vdDims1 ~= vdDims2)
                UnitTestUtils.TriggerCheckObjectPublicProperitiesEqualError(chTraceBack);
            end
            
            % if objects are primitives, just compare them directly
            if isnumeric(xObj1) || islogical(xObj1) || ischar(xObj1) || isstring(xObj1) % shortcut to not have to loop through values
                if isnumeric(xObj1) && ~isempty(c1xToleranceNameValuePair) && strcmp(c1xToleranceNameValuePair{1}, 'AbsTol') && c1xToleranceNameValuePair{2} ~= 0
                    xObj1 = double(xObj1);
                    xObj2 = double(xObj2);
                    
                    if any(abs(xObj1(:) - xObj2(:)) > c1xToleranceNameValuePair{2})
                        UnitTestUtils.TriggerCheckObjectPublicProperitiesEqualError(chTraceBack);
                    end
                else                
                    if any(xObj1(:) ~= xObj2(:))
                        UnitTestUtils.TriggerCheckObjectPublicProperitiesEqualError(chTraceBack);
                    end
                end
            else
                oMetaClass1 = metaclass(xObj1);
                
                if numel(xObj1) == 1 % if scalar, drill into public properities
                    
                    if strcmp(oMetaClass1.Name, 'struct') % drill into fields of struct (no "properities" really)
                        
                        % check field names are the same
                        c1chFieldnames1 = fieldnames(xObj1);
                        c1chFieldnames2 = fieldnames(xObj2);
                        
                        if length(c1chFieldnames1) ~= length(c1chFieldnames2)
                            UnitTestUtils.TriggerCheckObjectPublicProperitiesEqualError(chTraceBack);
                        end
                        
                        for dFieldIndex=1:length(c1chFieldnames1)
                            if ~CellArrayUtils.ContainsExactString(c1chFieldnames2, c1chFieldnames1{dFieldIndex})
                                UnitTestUtils.TriggerCheckObjectPublicProperitiesEqualError(chTraceBack);
                            end
                        end
                        
                        % recurse into contents of each field
                        for dFieldIndex=1:length(c1chFieldnames1)
                            UnitTestUtils.CheckObjectPublicProperitiesEqual(...
                                xObj1.(c1chFieldnames1{dFieldIndex}),...
                                xObj2.(c1chFieldnames1{dFieldIndex}),...
                                [chTraceBack, '.', c1chFieldnames1{dFieldIndex}],...
                                c1chIgnoredProperties, c1xToleranceNameValuePair);
                            
                        end
                        
                    else % use "properties" function to get access public functions
                        c1chProps1 = properties(xObj1);
                        
                        for dPropIndex=1:length(c1chProps1) % check that property exists in both objects and then recurse
                            if ~CellArrayUtils.ContainsExactString(c1chIgnoredProperties, c1chProps1{dPropIndex})
                                UnitTestUtils.CheckObjectPublicProperitiesEqual(...
                                    xObj1.(c1chProps1{dPropIndex}),...
                                    xObj2.(c1chProps1{dPropIndex}),...
                                    [chTraceBack, '.', c1chProps1{dPropIndex}],...
                                    c1chIgnoredProperties, c1xToleranceNameValuePair);
                            end
                        end
                    end
                else
                    % if objs are tables, need to index with (row,col)
                    switch oMetaClass1.Name
                        case 'table'
                            
                            for dCol=1:vdDims1(2)
                                for dRow=1:vdDims1(1)
                                    UnitTestUtils.CheckObjectPublicProperitiesEqual(...
                                        xObj1(dRow,dCol),...
                                        xObj2(dRow,dCol),...
                                        [chTraceBack, '(', num2str(dRow), ',', num2str(dCol), ')'],...
                                        c1chIgnoredProperties, c1xToleranceNameValuePair);
                                end
                            end
                            
                        otherwise % if not table, index with linear indexing
                            for dIndex=1:numel(xObj1)
                                UnitTestUtils.CheckObjectPublicProperitiesEqual(...
                                    xObj1(dIndex),...
                                    xObj2(dIndex),...
                                    [chTraceBack, '(', num2str(dIndex), ')'],...
                                    c1chIgnoredProperties, c1xToleranceNameValuePair);
                            end
                    end
                end
            end
        end
        
        function TriggerCheckObjectPublicProperitiesEqualError(chTraceBack)
            stErrorStruct = struct(...
                'identifier', UnitTestUtils.chCheckObjectPublicProperitiesEqualErrorId,...
                'message', chTraceBack);
            
            error(stErrorStruct);
        end

        
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
        
        function CheckObjectPublicProperitiesEqual_UnitTestAccess(xObj1, xObj2, chTraceBack, c1chIgnoredProperties, c1xToleranceNameValuePair)
            UnitTestUtils.CheckObjectPublicProperitiesEqual(xObj1, xObj2, chTraceBack, c1chIgnoredProperties, c1xToleranceNameValuePair);
        end
        
    end
end

