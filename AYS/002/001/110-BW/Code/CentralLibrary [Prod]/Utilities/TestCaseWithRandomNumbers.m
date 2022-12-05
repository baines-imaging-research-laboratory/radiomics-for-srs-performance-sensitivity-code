classdef TestCaseWithRandomNumbers < matlab.unittest.TestCase
    %TestCaseWithRandomNumbers
    %
    % A TestCase to inherit new TestCases from if random number generation
    % is used. It's recommended to always inherit from this class just
    % case, since some Matlab functions use random numbers under the hood
    %
    % This class:
    % 1) Ensures that a reproducible random number seed is set a the
    %    beginning of each test
    % 2) Manages the numbers using the "RandomNumberGenerator" class,
    %    allowing for easy integration of it for parfor/for loops
    
    % Primary Author: David DeVries
    % Created: Mar 21, 2019
    
    
    
    % *********************************************************************
    % *                            PROPERTIES                             *
    % *********************************************************************
    
    properties
        oRandomNumberGenerator = []
    end
    
    
    
    % *********************************************************************
    % *                 PER CLASS SETUP/TEADOWN METHODS                   *
    % *********************************************************************
    
    methods (TestClassSetup) % Called ONCE before All tests
        
        function SetRandomNumberGeneratorBeforeAllTests(testCase)
            %SetRandomNumberGenerator(testCase)
            %
            % DESCRIPTION:
            %  This function resets the RandomNumberGenerator class and
            %  creates a new RandomNumberGenerator object with a set seed.
            %  This object is saved to the "oRandomNumberGenerator"
            %  property of "testCase". It can be accessed within tests via
            %  "testCase.oRandomNumberGenerator".
            
            % Primary Author: David DeVries
            % Created: Mar. 8, 2019
            
            RandomNumberGenerator.Reset('SuppressWarnings');
            
            dSeed = 1;
            testCase.oRandomNumberGenerator = RandomNumberGenerator(dSeed);
        end
    end
    
    
    methods (TestClassTeardown) % Called ONCE after All tests
    end
    
    
    
    % *********************************************************************
    % *               PER TEST CASE SETUP/TEADOWN METHODS                 *
    % *********************************************************************
    
    methods (TestMethodSetup) % Called before EACH test
                
        function SetRandomNumberGeneratorBeforeEachTest(testCase)
            %SetRandomNumberGenerator(testCase)
            %
            % DESCRIPTION:
            %  This function resets the RandomNumberGenerator class and
            %  creates a new RandomNumberGenerator object with a set seed.
            %  This object is saved to the "oRandomNumberGenerator"
            %  property of "testCase". It can be accessed within tests via
            %  "testCase.oRandomNumberGenerator".
            
            % Primary Author: David DeVries
            % Created: Mar. 8, 2019
            
            RandomNumberGenerator.Reset('SuppressWarnings');
            
            dSeed = 1;
            testCase.oRandomNumberGenerator = RandomNumberGenerator(dSeed);
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