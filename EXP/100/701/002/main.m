Experiment.StartNewSection('Loading Experiment Assets');

% load experiment asset codes
[sSSCode, vsClinicalFeatureValueCodes, vsRadiomicFeatureValueCodes, sLabelsCode, ~, sModelCode, ...
sHPOCode, sObjFcnCodeForHPO,...
sFeatureSelectorCode, ~] = ...
ExperimentManager.LoadExperimentManifestCodesMatFile();

% load experiment assets
oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsClinicalFeatureValueCodes,...
    sLabelsCode);

oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);

% - apply sample selection
oSS = ExperimentManager.Load(sSSCode);

oClinicalDataSet = oSS.ApplySampleSelectionToFeatureValues(oClinicalDataSet);
oRadiomicDataSet = oSS.ApplySampleSelectionToFeatureValues(oRadiomicDataSet);

if isempty(oRadiomicDataSet)
    oReferenceDataset = oClinicalDataSet;
else
    oReferenceDataset = oRadiomicDataSet;
end
    
oOFN = ExperimentManager.Load(sObjFcnCodeForHPO); % OOB Samples AUC
oFS = ExperimentManager.Load(sFeatureSelectorCode); % Correlation Filter
oHPO = ExperimentManager.Load(sHPOCode); % Custom Bayesian HPO
oMDL = ExperimentManager.Load(sModelCode); % Random decision forest


% set up boot-strapped partitions
dNumGroupsInTrainingSetMultiplier = 1;
dNumGroupsInTrainingSet = round(dNumGroupsInTrainingSetMultiplier*oReferenceDataset.GetNumberOfGroups());
dNumGroupsInTestingSet = []; % default behaviour

dNumBootstrapReps = 250;
bAtLeastOneOfEachLabelPerPartition = true;

vstBootstrappedPartitions = BootstrappingPartition.CreatePartitions(oReferenceDataset, dNumBootstrapReps, dNumGroupsInTrainingSet, dNumGroupsInTestingSet, bAtLeastOneOfEachLabelPerPartition);

stTrainAndTestOnAllDataPartition = struct('TrainingIndices', 1:oReferenceDataset.GetNumberOfSamples(), 'TestingIndices', 1:oReferenceDataset.GetNumberOfSamples());
vstBootstrappedPartitions = [vstBootstrappedPartitions; stTrainAndTestOnAllDataPartition];


% volume feature blacklist
dCorrelationCoefficientCutoff = 0.70;
dPValueCutoff = 0.05; % Bonferroni correction applied to p-values, so 0.05 cutoff can be used

[vdCorrelationCoefficientToVolume, vdCorrelationCoefficientToVolumeCubeRoot, vdCorrectedPValuePerRadiomicFeatureForVolume, vdCorrectedPValuePerRadiomicFeatureForVolumeCubeRoot, vdCorrectedPValuePerClinicalFeature] =...
    FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-001-006-005'), '01 Analysis', 'P-Values And Correlation Coefficients Per Feature.mat'),...
    'vdCorrelationCoefficientToVolume', 'vdCorrelationCoefficientToVolumeCubeRoot', 'vdCorrectedPValuePerRadiomicFeatureForVolume', 'vdCorrectedPValuePerRadiomicFeatureForVolumeCubeRoot', 'vdCorrectedPValuePerClinicalFeature');

vdCorrectedPValuePerRadiomicFeatureForVolume(oRadiomicDataSet.GetFeatureNames() == "original_shape_VoxelVolume") = 0; % need to override since this feature was what compared against
vdCorrectedPValuePerRadiomicFeatureForVolumeCubeRoot(oRadiomicDataSet.GetFeatureNames() == "original_shape_VoxelVolume") = 0; % need to override since this feature was what compared against

% - radiomic features
vbRemoveFeatureSinceSignificantAndCorrelatedToVolume = (abs(vdCorrelationCoefficientToVolume) >= dCorrelationCoefficientCutoff) & (vdCorrectedPValuePerRadiomicFeatureForVolume <= dPValueCutoff);
vbRemoveFeatureSinceSignificantAndCorrelatedToVolumeCubeRoot = (abs(vdCorrelationCoefficientToVolumeCubeRoot) >= dCorrelationCoefficientCutoff) & (vdCorrectedPValuePerRadiomicFeatureForVolumeCubeRoot <= dPValueCutoff);

oRadiomicDataSet = oRadiomicDataSet(:, ~(vbRemoveFeatureSinceSignificantAndCorrelatedToVolume | vbRemoveFeatureSinceSignificantAndCorrelatedToVolumeCubeRoot));

% - clinical feature
vbRemoveFeatureSinceDependentOnVolume = vdCorrectedPValuePerClinicalFeature <= dPValueCutoff; 

oClinicalDataSet = oClinicalDataSet(:, ~vbRemoveFeatureSinceDependentOnVolume);

FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'Clinical and Radiomic Feature Filters.mat'),...
    'vbRadiomicFeatureSelection', ~(vbRemoveFeatureSinceSignificantAndCorrelatedToVolume | vbRemoveFeatureSinceSignificantAndCorrelatedToVolumeCubeRoot),...
    'vbClinicalFeatureSelection', ~vbRemoveFeatureSinceDependentOnVolume);

Experiment.EndCurrentSection();


% Compute bootstrap iterations
Experiment.StartNewSection('Bootstrapped Iterations');

oManager = Experiment.GetLoopIterationManager(dNumBootstrapReps+1, 'AvoidIterationRecomputationIfResumed', true); % "+ 1" for the train and test on full data set iteration needed for AUC_0.632

parfor dBootstrapRepIndex=1:dNumBootstrapReps+1    
    if oManager.IterationWasPreviouslyComputed(dBootstrapRepIndex)
        continue; % don't recomputed it!
    end
    
    oManager.PerLoopIndexSetup(dBootstrapRepIndex);
    
    if dBootstrapRepIndex == dNumBootstrapReps+1 % train and test on all the data
        chFilename = 'Train and Test On All Data Results.mat';        
    else       
        chFilename = ['Iteration ', StringUtils.num2str_PadWithZeros(dBootstrapRepIndex, length(num2str(dNumBootstrapReps))), ' Results.mat'];        
    end
       
    % Declare variables (this avoids warnings)
    oRadiomicTuningAndTrainingSet = [];
    oRadiomicTestingSet = [];
    
    oClinicalTuningAndTrainingSet = [];
    oClinicalTestingSet = [];
    
    oTuningSet = [];
    oTrainingSet = [];
    oTestingSet = [];    
    
    % Get radiomic data
    if ~isempty(oRadiomicDataSet)
        oRadiomicTuningAndTrainingSet = oRadiomicDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TrainingIndices,:);
        oRadiomicTestingSet = oRadiomicDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TestingIndices,:);
        
        % Correlation filter
        oFeatureFilter = oFS.CreateFeatureSelector();
        oFeatureFilter.SelectFeatures(oRadiomicTuningAndTrainingSet, 'JournalingOn', false);
        vbRadiomicFeatureMask = oFeatureFilter.GetFeatureMask();
        
        oRadiomicTuningAndTrainingSet = oRadiomicTuningAndTrainingSet(:, vbRadiomicFeatureMask);
        oRadiomicTestingSet = oRadiomicTestingSet(:, vbRadiomicFeatureMask);
    else
        vbRadiomicFeatureMask = [];
    end
        
    % Get clinical data
    if ~isempty(oClinicalDataSet)
        oClinicalTuningAndTrainingSet = oClinicalDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TrainingIndices,:);
        oClinicalTestingSet = oClinicalDataSet(vstBootstrappedPartitions(dBootstrapRepIndex).TestingIndices,:);
    end
    
    % Combine radiomic and clinical data into one data set
    if ~isempty(oClinicalDataSet) && ~isempty(oRadiomicDataSet)
        oTuningSet = [oRadiomicTuningAndTrainingSet, oClinicalTuningAndTrainingSet];
        oTrainingSet = [oRadiomicTuningAndTrainingSet, oClinicalTuningAndTrainingSet];
        oTestingSet = [oRadiomicTestingSet, oClinicalTestingSet];
    elseif ~isempty(oClinicalDataSet)
        oTuningSet = oClinicalTuningAndTrainingSet;
        oTrainingSet = oClinicalTuningAndTrainingSet;
        oTestingSet = oClinicalTestingSet;
    elseif ~isempty(oRadiomicDataSet)
        oTuningSet = oRadiomicTuningAndTrainingSet;
        oTrainingSet = oRadiomicTuningAndTrainingSet;
        oTestingSet = oRadiomicTestingSet;
    end
    
    % Perform hyper-parameter optimization           
    oHyperParameterOptimizer = oHPO.CreateHyperParameterOptimizer(oOFN, oTuningSet);
    oClassifier = oMDL.CreateModel(oHyperParameterOptimizer, 'JournalingOn', false);
    dHyperParameterOptimizationAUC = 1 - oClassifier.GetHyperParameterOptimizer().GetObjectiveFunctionValueAtOptimalHyperParameters();
    
    % Train and evaluate classifier
    oRNG = RandomNumberGenerator();
    
    oRNG.PreLoopSetup(1);
    oRNG.PerLoopIndexSetup(1);
    
    oTrainedClassifier = oClassifier.Train(oTrainingSet, 'JournalingOn', false);
    oGuessResult = oTrainedClassifier.Guess(oTestingSet, 'JournalingOn', false);
    oOOBSamplesGuessResult = oTrainedClassifier.GuessOnOutOfBagSamples();
    
    oRNG.PerLoopIndexTeardown;
    oRNG.PostLoopTeardown;
    
    % Save artifacts to disk
    FileIOUtils.SaveMatFile(...
        fullfile(Experiment.GetResultsDirectory(), chFilename),...
        'vbRadiomicFeatureMask', vbRadiomicFeatureMask,...
        'stBootstrappedPartitions', vstBootstrappedPartitions(dBootstrapRepIndex),...
        'dHyperParameterOptimizationAUC', dHyperParameterOptimizationAUC,...
        'oConstructedClassifier', oClassifier,...
        'vdFeatureImportanceScores', oTrainedClassifier.GetFeatureImportanceFromOutOfBagSamples(),...
        'oGuessResult', oGuessResult,...
        'oOOBSamplesGuessResult', oOOBSamplesGuessResult,...
        '-v7', '-nocompression');          
    
    % par manager clean-up
    oManager.PerLoopIndexTeardown();
end

oManager.PostLoopTeardown();

% combine all guess results into a single file

c1oGuessResultsPerBootstrapPartition = cell(dNumBootstrapReps,1);
c1oOOBSamplesGuessResultsPerBootstrapPartition = cell(dNumBootstrapReps,1);

chResultsDirPath = Experiment.GetResultsDirectory();

for dBootstrapIndex=1:dNumBootstrapReps
    [c1oGuessResultsPerBootstrapPartition{dBootstrapIndex}, c1oOOBSamplesGuessResultsPerBootstrapPartition{dBootstrapIndex}] = FileIOUtils.LoadMatFile(...
        fullfile(chResultsDirPath, ['Iteration ', StringUtils.num2str_PadWithZeros(dBootstrapIndex, length(num2str(dNumBootstrapReps))), ' Results.mat']),...
        'oGuessResult', 'oOOBSamplesGuessResult');
end

FileIOUtils.SaveMatFile(...
    fullfile(chResultsDirPath, 'Partitions & Guess Results.mat'),...
    'c1oGuessResultsPerPartition', c1oGuessResultsPerBootstrapPartition,...
    'c1oOOBSamplesGuessResultsPerPartition', c1oOOBSamplesGuessResultsPerBootstrapPartition,...
    'vstBootstrapPartitions', vstBootstrappedPartitions(1:dNumBootstrapReps));

Experiment.EndCurrentSection();

% calculate AUC

Experiment.StartNewSection('Performance');
    

[oTrainAndTestOnAllSamplesGuessResultForFeatureCombination] = FileIOUtils.LoadMatFile(fullfile(chResultsDirPath, 'Train and Test On All Data Results.mat'), 'oGuessResult');

vdAUCPerBootstrap = zeros(dNumBootstrapReps,1);

for dBootstrapIndex=1:dNumBootstrapReps
    vdAUCPerBootstrap(dBootstrapIndex) = ErrorMetricsCalculator.CalculateAUC(c1oGuessResultsPerBootstrapPartition{dBootstrapIndex}, 'JournalingOn', false);
end

vdAUC_0Point632PerBootstrap = AdvancedErrorMetricsCalculator.CalculateAUC_0Point632(c1oGuessResultsPerBootstrapPartition, oTrainAndTestOnAllSamplesGuessResultForFeatureCombination);
vdAUC_0Point632PlusPerBootstrap = AdvancedErrorMetricsCalculator.CalculateAUC_0Point632Plus(c1oGuessResultsPerBootstrapPartition, oTrainAndTestOnAllSamplesGuessResultForFeatureCombination);

dAUCTrainAndTestOnAllSamples = ErrorMetricsCalculator.CalculateAUC(oTrainAndTestOnAllSamplesGuessResultForFeatureCombination, 'JournalingOn', false);

[dLPOBAUC, dLPOBAUCStDev] = AdvancedErrorMetricsCalculator.LeaveOnePairOutBootstrapAUCAndStDev(vstBootstrappedPartitions(1:dNumBootstrapReps), c1oGuessResultsPerBootstrapPartition);

FileIOUtils.SaveMatFile(...
    fullfile(Experiment.GetResultsDirectory(), 'AUC Metrics.mat'),...
    'vdAUCPerBootstrap', vdAUCPerBootstrap,...
    'vdAUC_0Point632PerBootstrap', vdAUC_0Point632PerBootstrap,...
    'vdAUC_0Point632PlusPerBootstrap', vdAUC_0Point632PlusPerBootstrap,...
    'dAUCTrainAndTestOnAllSamples', dAUCTrainAndTestOnAllSamples,...
    'dLPOBAUC', dLPOBAUC, 'dLPOBAUCStDev', dLPOBAUCStDev);

Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAUCPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAUCPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAUCPerBootstrap))));

Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC 0.632: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAUC_0Point632PerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAUC_0Point632PerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAUC_0Point632PerBootstrap))));

Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC 0.632+: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(mean(vdAUC_0Point632PlusPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("Median: " + string(median(vdAUC_0Point632PlusPerBootstrap))));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(std(vdAUC_0Point632PlusPerBootstrap))));

Experiment.AddToReport(ReportUtils.CreateParagraphWithBoldLabel('AUC LPOB: ', ''));
Experiment.AddToReport(ReportUtils.CreateParagraph("Mean: " + string(dLPOBAUC)));
Experiment.AddToReport(ReportUtils.CreateParagraph("St. Dev.: " + string(dLPOBAUCStDev)));

hFig = figure();
histogram(vdAUCPerBootstrap, 'BinEdges', 0:0.1:1);

chFigSavePath = fullfile(Experiment.GetResultsDirectory(), 'AUC Histogram.fig');

savefig(hFig, chFigSavePath);
Experiment.AddToReport(chFigSavePath);

delete(hFig);

Experiment.EndCurrentSection();