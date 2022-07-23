classdef AdvancedErrorMetricsCalculator_Test < TestCaseWithRandomNumbers
    %AdvancedErrorMetricsCalculator_Test
    %
    % Unit tests for: CellArrayUtils.AdvancedErrorMetricsCalculator
    
    % Primary Author: David DeVries
    % Created: Feb 20, 2021
    
    
    
    % *********************************************************************
    % *                            PROPERTIES                             *
    % *********************************************************************
    
    properties
    end
    
    
    
    % *********************************************************************
    % *                 PER CLASS SETUP/TEADOWN METHODS                   *
    % *********************************************************************
    
    methods (TestClassSetup) % Called ONCE before All tests
    end
    
    
    methods (TestClassTeardown) % Called ONCE after All tests
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
    
    methods (Test)
        
        function test_LeaveOnePairOutBootstrapAUCAndStDev(testCase)
            oClassifier = MATLABfitcsvm('MATLABfitcsvm_hyperParameters.mat');
            
            viGroupIds = uint8((1:7)');
            viSubGroupIds = uint8(ones(7,1));
            
            viLabels = uint8([0 0 1 0 1 1 0]');
            iPosLabel = uint8(1);
            iNegLabel = uint8(0);
            
            m2dFeatures = rand(7,1);
            
            vsFeatureNames = "Random";
            
            vsUserDefinedSampleStrings = string(viGroupIds);
            
            oLabelledFeatureValues = LabelledFeatureValuesByValue(m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames, viLabels, iPosLabel, iNegLabel);
            
            vstBootstrapPartitions(1) = struct('TrainingIndices', [6,6,5,5,6], 'TestingIndices', [3,4,7,1,2]);
            vstBootstrapPartitions(2) = struct('TrainingIndices', [5,3,3,3,5], 'TestingIndices', [2,4,6,7,1]);
            vstBootstrapPartitions(3) = struct('TrainingIndices', [3,3,3,3,3], 'TestingIndices', [1,5,6,7,2,4]);
            vstBootstrapPartitions(4) = struct('TrainingIndices', [2,4,2,6,5], 'TestingIndices', [1,3,7]);
            vstBootstrapPartitions(5) = struct('TrainingIndices', [3,4,7,4,3], 'TestingIndices', [1,2,5,6]);
            vstBootstrapPartitions(6) = struct('TrainingIndices', [2,4,7,4,7], 'TestingIndices', [1,5,6,3]);
            
            c1vdPosLabelConfidencesPerBootstrap = {...
                [0.9 0.1 0.7 1.0 0.2]',...
                [0.3 0.5 0.5 0.2 0.7]',...
                [0.3 0.5 0.8 0.9 0.7 0.5]',...
                [0.4 0.6 0.7]',...
                [0.1 0.6 0.6 0.5]',...
                [0.4 0.3 0.4 0.5]'};
            
            dNumBootstraps = length(c1vdPosLabelConfidencesPerBootstrap);
            
            c1oGuessResultPerBootstrap = cell(dNumBootstraps,1);
            
            for dBootstrapIndex=1:dNumBootstraps
                c1oGuessResultPerBootstrap{dBootstrapIndex} = ClassificationGuessResult.Constructor_UnitTestAccess(...
                    oClassifier,...
                    oLabelledFeatureValues(vstBootstrapPartitions(dBootstrapIndex).TestingIndices,:),...
                    c1vdPosLabelConfidencesPerBootstrap{dBootstrapIndex});
            end
            
            vbSampleLabels = ( oLabelledFeatureValues.GetLabels == oLabelledFeatureValues.GetPositiveLabel() );
            
            [dActualAUC, dActualStDev] = AdvancedErrorMetricsCalculator.LeaveOnePairOutBootstrapAUCAndStDev(vstBootstrapPartitions, c1oGuessResultPerBootstrap);
            
            dExpectedAUC = 19/32;
            dExpectedStDev = 0.3820917285;
            
            testCase.verifyEqual(dActualAUC, dExpectedAUC);
            testCase.verifyEqual(dActualStDev, dExpectedStDev, 'AbsTol', 1e-10);
        end
    end
    
    
    
    % *********************************************************************
    % *                         HELPER FUNCTIONS                          *
    % *********************************************************************
    
    methods (Static = true)
    end
end