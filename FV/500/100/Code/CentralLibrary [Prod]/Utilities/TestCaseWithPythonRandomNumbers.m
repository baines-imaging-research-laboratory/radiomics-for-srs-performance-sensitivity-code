classdef TestCaseWithPythonRandomNumbers < matlab.unittest.TestCase
    %TestCaseWithPythonRandomNumbers
    %
    % A TestCase to inherit new TestCases from if random number generation
    % in Python is used. 
    
    % Primary Author: David DeVries
    % Created: Jan 4, 2021
    
    
    
    % *********************************************************************
    % *                            PROPERTIES                             *
    % *********************************************************************
    
    properties
    end
    
    
    
    % *********************************************************************
    % *                 PER CLASS SETUP/TEADOWN METHODS                   *
    % *********************************************************************
    
    methods (TestClassSetup) % Called ONCE before All tests
        
        function SetPythonRandomNumberGeneratorBeforeAllTests(testCase)
            %SetPythonRandomNumberGenerator(testCase)
            %
            % DESCRIPTION:
            %  The Python seed number tracker is set.
                        
            % set Python seed as well
            PythonUtils.ResetPythonRandomSeedNumber();
        end
    end
    
    
    methods (TestClassTeardown) % Called ONCE after All tests
    end
    
    
    
    % *********************************************************************
    % *               PER TEST CASE SETUP/TEADOWN METHODS                 *
    % *********************************************************************
    
    methods (TestMethodSetup) % Called before EACH test
                
        function SetPythonRandomNumberGeneratorBeforeEachTest(testCase)
            %SetPythonRandomNumberGenerator(testCase)
            %
            % DESCRIPTION:
            %  The Python seed number tracker is set.
                                    
            % set Python seed as well
            PythonUtils.ResetPythonRandomSeedNumber();
        end
    end
    
    
    methods (TestMethodTeardown) % Called after EACH tests
    end
    
    
    
    % *********************************************************************
    % *                            TEST CASES                             *
    % *********************************************************************
    
    methods(Test)
    end
    
    
    
    % *********************************************************************
    % *                         HELPER FUNCTIONS                          *
    % *********************************************************************
    
    methods (Static = true)
    end
end