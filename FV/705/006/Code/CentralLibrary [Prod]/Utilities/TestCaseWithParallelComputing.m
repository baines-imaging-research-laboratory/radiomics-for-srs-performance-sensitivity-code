classdef TestCaseWithParallelComputing < matlab.unittest.TestCase
    %TestCaseWithParallelComputing 
    %
    % A TestCase to inherit new TestCases from if parallel computing (e.g.
    % parfor) is being used within the tests.
    %
    % This class:
    % 1) Ensures a valid parpool of at least 2 workers exists
    % 2) Creates a new parpool if a valid pool doesn't exist
    % 3) Shutdowns any created parpools after testing is complete
    % 4) If a valid parpool already exists, it will use it, and not delete
    %    it afterwards to allow for minimal setup/teardown time if multiple
    %    TestCases use parallel computing
    
    % Primary Author: David DeVries
    % Created: Mar 20, 2019
    
    
    
    % *********************************************************************
    % *                            PROPERTIES                             *
    % *********************************************************************
    
    properties
        hParPool % handle to the parpool for deletion
        bPoolCreated % false if a pre-existing parpool was used
    end
    
    
    
    % *********************************************************************
    % *                 PER CLASS SETUP/TEADOWN METHODS                   *
    % *********************************************************************
    
    methods (TestClassSetup) % Called ONCE before All tests
        
        function SetupParPool(testCase)
            %SetupParPool(testCase)
            %
            % DESCRIPTION:
            %  Checks if there's a parpool with at least 2 workers already
            %  available. If so, no pool is created and the pool isn't
            %  deleted after the tests are completed. If there is no pool
            %  or a pool with only one workers, a new pool is created with
            %  2 workers and torn-down afterwards
            
            hPool = gcp('nocreate');
            
            if isempty(hPool) % no pool currently exists
                testCase.hParPool = parpool('local', 2);
                testCase.bPoolCreated = true;
            else
                if hPool.NumWorkers >= 2 && hPool.Connected % is a valid par pool to use
                    testCase.hParPool = hPool;
                    testCase.bPoolCreated = false;
                else
                    delete(hPool);
                    
                    testCase.hParPool = parpool('local', 2);
                    testCase.bPoolCreated = true;
                end
            end
        end
    end
    
    
    methods (TestClassTeardown) % Called ONCE after All tests
        
        function TeardownParPool(testCase)
            %TeardownParPool(testCase)
            %
            % DESCRIPTION:
            %  Checks if a parpool was made or if it already existed. If it
            %  was made by the SetupParPool function, it's deleted
            
            if testCase.bPoolCreated % allows a pre-create par-pool to persist through test cases to save time
                delete(testCase.hParPool);
            end
        end
    end
    
    
    
    % *********************************************************************
    % *               PER TEST CASE SETUP/TEADOWN METHODS                 *
    % *********************************************************************
    
    methods (TestMethodSetup) % Called before EACH test
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