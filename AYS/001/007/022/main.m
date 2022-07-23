Experiment.StartNewSection('Analysis');

sExpCode= "EXP-100-400-102";

oLabels = ExperimentManager.Load('LBL-201').GetLabelledFeatureValues();
vbIsPositive = oLabels.GetLabels() == oLabels.GetPositiveLabel();

oClinicalFeatureValues = ExperimentManager.Load('FV-500-100').GetFeatureValues();

oPrimarySite = oClinicalFeatureValues(:,4);
vdPrimarySitePerSample = oPrimarySite.GetFeatures();

vdPrimarySiteGroupValues = 1:6;
vsPrimarySiteGroups = ["All", "Lung", "Breast", "Renal", "Colorectal", "Melanoma", "Other"];


dNumGroups = length(vsPrimarySiteGroups);

viGroupIds = oClinicalFeatureValues.GetGroupIds();
viSubGroupIds = oClinicalFeatureValues.GetSubGroupIds();

dNumBootstraps = 250;

m2dAUCPerGroupPerBootstrap = nan(dNumGroups, dNumBootstraps);
m2dPRAUCPerGroupPerBootstrap = nan(dNumGroups, dNumBootstraps);
m2dMCRPerGroupPerBootstrap = nan(dNumGroups, dNumBootstraps);
m2dFPRPerGroupPerBootstrap = nan(dNumGroups, dNumBootstraps);
m2dFNRPerGroupPerBootstrap = nan(dNumGroups, dNumBootstraps);

m2dAUCAndErrorPerGroup = nan(3, dNumGroups);
m2dPRAUCAndErrorPerGroup = nan(3, dNumGroups);
m2dMCRAndErrorPerGroup = nan(3, dNumGroups);
m2dFPRAndErrorPerGroup = nan(3, dNumGroups);
m2dFNRAndErrorPerGroup = nan(3, dNumGroups);


[c1oGuessResultsPerPartition, c1oOOBSamplesGuessResultsPerPartition] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), '02 Bootstrapped Iterations', 'Partitions & Guess Results.mat'),...
    'c1oGuessResultsPerPartition','c1oOOBSamplesGuessResultsPerPartition');


vdNumTimesSampleCorrectlyClassified = zeros(oClinicalFeatureValues.GetNumberOfSamples(),1);
vdNumTimesSampleIncorrectlyClassified = zeros(oClinicalFeatureValues.GetNumberOfSamples(),1);

m2dConfidencePerSamplePerBootstrap = nan(oClinicalFeatureValues.GetNumberOfSamples(), length(c1oGuessResultsPerPartition));
m2dOOBConfidencePerSamplePerBootstrap = nan(oClinicalFeatureValues.GetNumberOfSamples(), length(c1oGuessResultsPerPartition));

for dBootstrapIndex=1:length(c1oGuessResultsPerPartition)
    oGuessResult = c1oGuessResultsPerPartition{dBootstrapIndex};
    
    dOptThreshold = ErrorMetricsCalculator.CalculateOptimalThreshold({'upperleft','MCR'}, c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex}, 'JournalingOn', false); % calculate optimatl threshold with OOB training set samples
    
    vbGroundTruthLabels = oGuessResult.GetLabels();
    vbPredictedLabels = oGuessResult.GetPredictedLabels(dOptThreshold);
    
    vbCorrect = (vbGroundTruthLabels == vbPredictedLabels);
    
    vdPositiveConfidences = oGuessResult.GetPositiveLabelConfidences();
    
    viGuessResultGroupIds = oGuessResult.GetGroupIds();
    viGuessResultSubGroupIds = oGuessResult.GetSubGroupIds();
    
    for dSampleIndex=1:length(vbCorrect)
        dOriginalSampleIndex = find(viGuessResultGroupIds(dSampleIndex) == viGroupIds & viGuessResultSubGroupIds(dSampleIndex) == viSubGroupIds);
        
        if vbCorrect(dSampleIndex)
            vdNumTimesSampleCorrectlyClassified(dOriginalSampleIndex) = vdNumTimesSampleCorrectlyClassified(dOriginalSampleIndex) + 1;
        else
            vdNumTimesSampleIncorrectlyClassified(dOriginalSampleIndex) = vdNumTimesSampleIncorrectlyClassified(dOriginalSampleIndex) + 1;
        end
        
        m2dConfidencePerSamplePerBootstrap(dOriginalSampleIndex, dBootstrapIndex) = vdPositiveConfidences(dSampleIndex);
    end
    
    
    vdOOBPositiveConfidences = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex}.GetPositiveLabelConfidences();
    
    viOOBGuessResultGroupIds = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex}.GetGroupIds();
    viOOBGuessResultSubGroupIds = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex}.GetSubGroupIds();
    
    for dOriginalSampleIndex=1:oClinicalFeatureValues.GetNumberOfSamples()
        vdOOBSampleIndices = find(viOOBGuessResultGroupIds == viGroupIds(dOriginalSampleIndex) & viOOBGuessResultSubGroupIds == viSubGroupIds(dOriginalSampleIndex));
        
        if ~isempty(vdOOBSampleIndices)
            m2dOOBConfidencePerSamplePerBootstrap(dOriginalSampleIndex, dBootstrapIndex) = mean(vdOOBPositiveConfidences(vdOOBSampleIndices));
        end
    end
end

vdNumTruePositives = vdNumTimesSampleCorrectlyClassified;
vdNumTruePositives(~vbIsPositive) = 0;

vdNumTrueNegatives = vdNumTimesSampleCorrectlyClassified;
vdNumTrueNegatives(vbIsPositive) = 0;

vdNumFalsePositives = vdNumTimesSampleIncorrectlyClassified;
vdNumFalsePositives(vbIsPositive) = 0;

vdNumFalseNegatives = vdNumTimesSampleIncorrectlyClassified;
vdNumFalseNegatives(~vbIsPositive) = 0;





hFig = figure();
hold('on');


for dGroupIndex=1:dNumGroups
    c1vdConfidencesPerBootstrap = cell(dNumBootstraps,1);
    c1vdTrueLabelsPerBootstrap = cell(dNumBootstraps,1);
    
    vbNonEmptyConfidencesPerBootstrap = false(dNumBootstraps,1);
    
    c1vdOOBConfidencesPerBootstrap = cell(dNumBootstraps,1);
    c1vdOOBTrueLabelsPerBootstrap = cell(dNumBootstraps,1);
    
    vbNonEmptyOOBConfidencesPerBootstrap = false(dNumBootstraps,1);
    
    dPosLabel = c1oGuessResultsPerPartition{1}.GetPositiveLabel();
    
    
    if dGroupIndex == 1 % All
        vbInGroup = true(size(vdPrimarySitePerSample));
    else
        vbInGroup = vdPrimarySitePerSample == (dGroupIndex-1);
    end
    
    for dBootstrapIndex=1:dNumBootstraps
        vdConfidences = m2dConfidencePerSamplePerBootstrap(:,dBootstrapIndex);
        
        vbSampleInBootstrap = ~isnan(vdConfidences);
        
        vdConfidencesForBootstrap = vdConfidences(vbSampleInBootstrap);
        vbIsPositiveForBootstrap = vbIsPositive(vbSampleInBootstrap);
        vbInGroupForBootstrap = vbInGroup(vbSampleInBootstrap);
        
        vdConfidencesForAnalysis = vdConfidencesForBootstrap(vbInGroupForBootstrap);
        vbIsPositiveForAnalysis = vbIsPositiveForBootstrap(vbInGroupForBootstrap);
        
        
        oOOBGuessResult = c1oOOBSamplesGuessResultsPerPartition{dBootstrapIndex};
        
        vdOOBConfidences = oOOBGuessResult.GetPositiveLabelConfidences();
        vbOOBIsPositive = oOOBGuessResult.GetLabels() == oOOBGuessResult.GetPositiveLabel();
        
        viOOBGroupIds = oOOBGuessResult.GetGroupIds();
        viOOBSubGroupIds = oOOBGuessResult.GetSubGroupIds();
        
        dNumOOBSamples = oOOBGuessResult.GetNumberOfSamples();
        
        vbOOBSampleInGroup = false(dNumOOBSamples,1);
        
        for dOOBSampleIndex=1:dNumOOBSamples
            iGroupId = viOOBGroupIds(dOOBSampleIndex);
            iSubGroupId = viOOBSubGroupIds(dOOBSampleIndex);
            
            dOrigSampleIndex = find(iGroupId == viGroupIds & iSubGroupId == viSubGroupIds);
            
            vbOOBSampleInGroup(dOOBSampleIndex) = vbInGroup(dOrigSampleIndex);
        end
        
        vdOOBConfidencesForAnalysis = vdOOBConfidences(vbOOBSampleInGroup);
        vbOOBIsPositiveForAnalysis = vbOOBIsPositive(vbOOBSampleInGroup);
        
        
        % Gather raw confidences and label from all bootstraps for use
        % with Matlab's perfcurve
        c1vdConfidencesPerBootstrap{dBootstrapIndex} = vdConfidencesForAnalysis;
        c1vdTrueLabelsPerBootstrap{dBootstrapIndex} = double(vbIsPositiveForAnalysis);
        
        vbNonEmptyConfidencesPerBootstrap(dBootstrapIndex) = ~isempty(vdConfidencesForAnalysis);
        
        c1vdOOBConfidencesPerBootstrap{dBootstrapIndex} = vdOOBConfidencesForAnalysis;
        c1vdOOBTrueLabelsPerBootstrap{dBootstrapIndex} = double(vbOOBIsPositiveForAnalysis);
        
        vbNonEmptyOOBConfidencesPerBootstrap(dBootstrapIndex) = ~isempty(vdOOBConfidencesForAnalysis);
        
        
        try
            m2dAUCPerGroupPerBootstrap(dGroupIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateAUC(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), 'JournalingOn', false);
            m2dPRAUCPerGroupPerBootstrap(dGroupIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculatePRAUC(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), 'JournalingOn', false);
        catch e
        end
        
        try
            dThreshold = ErrorMetricsCalculator.CalculateOptimalThreshold({'upperleft','MCR'}, uint8(vbOOBIsPositiveForAnalysis), vdOOBConfidencesForAnalysis, uint8(1), 'JournalingOn', false); % calculate optimal threshold with OOB training set samples
            
            m2dMCRPerGroupPerBootstrap(dGroupIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateMisclassificationRate(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), dThreshold, 'JournalingOn', false);
            m2dFNRPerGroupPerBootstrap(dGroupIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateFalseNegativeRate(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), dThreshold, 'JournalingOn', false);
            m2dFPRPerGroupPerBootstrap(dGroupIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateFalsePositiveRate(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), dThreshold, 'JournalingOn', false);
        catch e
        end
    end
    
    c1vdConfidencesPerBootstrap = c1vdConfidencesPerBootstrap(vbNonEmptyConfidencesPerBootstrap);
    c1vdTrueLabelsPerBootstrap = c1vdTrueLabelsPerBootstrap(vbNonEmptyConfidencesPerBootstrap);
    
    c1vdOOBConfidencesPerBootstrap = c1vdOOBConfidencesPerBootstrap(vbNonEmptyOOBConfidencesPerBootstrap);
    c1vdOOBTrueLabelsPerBootstrap = c1vdOOBTrueLabelsPerBootstrap(vbNonEmptyOOBConfidencesPerBootstrap);
    
    % Use perfcurve and non-OOB samples to calculate AUC and PRAUC
    [m2dX, m2dY, vdT, vdAUC] = perfcurve(c1vdTrueLabelsPerBootstrap, c1vdConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1);
    [~, ~, ~, vdPRAUC] = perfcurve(c1vdTrueLabelsPerBootstrap, c1vdConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1, 'XCrit', 'reca', 'YCrit', 'prec');
    
    m2dAUCAndErrorPerGroup(:, dGroupIndex) = vdAUC;
    m2dPRAUCAndErrorPerGroup(:, dGroupIndex) = vdPRAUC;
    
    
    
    
    % Use perfcurve and OOB samples to find optimal threshold (upper
    % left)
    [m2dOOBX, m2dOOBY, vdOOBT, vdOOBAUC] = perfcurve(c1vdOOBTrueLabelsPerBootstrap, c1vdOOBConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1);
    
    vdUpperLeftDist = ((m2dOOBX(:,1)).^2) + ((1-m2dOOBY(:,1)).^2);
    [~,dMinIndex] = min(vdUpperLeftDist);
    dOptThres = vdOOBT(dMinIndex);
    
    % find the corresponding closest point on the non-OOB ROC for the
    % same threshold
    [~,dPointIndexForOptThres] = min(abs(dOptThres - vdT(:,1)));
    
    % get FPR, FNR and MCR from ROC
    vdFPR = m2dX(dPointIndexForOptThres,:); % since ROC
    vdTPR = m2dY(dPointIndexForOptThres,:); % since ROC
    
    vdFNR = 1-vdTPR; % by defn
    vdTNR = 1-vdFPR; % by defn
    
    vdFNR([2,3]) = vdFNR([3,2]); % CIs are backwards
    vdTNR([2,3]) = vdTNR([3,2]); % CIs are backwards
    
    m2dFPRAndErrorPerGroup(:, dGroupIndex) = vdFPR;
    m2dFNRAndErrorPerGroup(:, dGroupIndex) = vdFNR;
    
    dNumPos = sum(vbIsPositive == 1);
    dNumNeg = sum(vbIsPositive == 0);
    
    vdFP = vdFPR * dNumNeg; % by defn
    vdFN = vdFNR * dNumPos; % by defn
    
    m2dMCRAndErrorPerGroup(:, dGroupIndex) = (vdFP + vdFN) ./ (dNumPos + dNumNeg);
    
    
    
    hROC = plot(m2dX(:,1), m2dY(:,1), '-', 'LineWidth', 1.5);
    
    hPatch = patch('XData', [m2dX(:,2); flipud(m2dX(:,3))], 'YData', [m2dY(:,3); flipud(m2dY(:,2))]);
    hPatch.FaceColor = hROC.Color;
    hPatch.LineStyle = 'none';
    hPatch.FaceAlpha = 0.25;
    
    %operating point
    plot(m2dX(dPointIndexForOptThres,1), m2dY(dPointIndexForOptThres,1), 'Marker', '+', 'MarkerSize', 8, 'Color', [0 0 0], 'LineWidth', 1.5);
end

FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'Error Metrics Per Volume Split, Bootstrap and Cutoff.mat'),...
    'vdPrimarySitePerSample', vdPrimarySitePerSample, 'vsPrimarySiteGroups', vsPrimarySiteGroups,...
    'm2dAUCPerGroupPerBootstrap', m2dAUCPerGroupPerBootstrap,...
    'm2dPRAUCPerGroupPerBootstrap', m2dPRAUCPerGroupPerBootstrap,...
    'm2dMCRPerGroupPerBootstrap', m2dMCRPerGroupPerBootstrap,...
    'm2dFPRPerGroupPerBootstrap', m2dFPRPerGroupPerBootstrap,...
    'm2dFNRPerGroupPerBootstrap', m2dFNRPerGroupPerBootstrap,...
    ...
    'vdAUCFromMeanROCPerGroup', squeeze(m2dAUCAndErrorPerGroup(1,:)),...
    'm2dAUC95ConfidenceIntervalFromMeanROCPerGroup', m2dAUCAndErrorPerGroup(2:3,:),...
    'vdPRAUCFromMeanPRCPerGroup', squeeze(m2dPRAUCAndErrorPerGroup(1,:)),...
    'm2dPRAUC95ConfidenceIntervalFromMeanPRCPerGroup', m2dPRAUCAndErrorPerGroup(2:3,:),...
    'vdMCRFromMeanROCPerGroup', squeeze(m2dMCRAndErrorPerGroup(1,:)),...
    'm2dMCR95ConfidenceIntervalFromMeanROCPerGroup', m2dMCRAndErrorPerGroup(2:3,:),...
    'vdFPRFromMeanROCPerGroup', squeeze(m2dFPRAndErrorPerGroup(1,:)),...
    'm2dFPR95ConfidenceIntervalFromMeanROCPerGroup', m2dFPRAndErrorPerGroup(2:3,:),...
    'vdFNRFromMeanROCPerGroup', squeeze(m2dFNRAndErrorPerGroup(1,:)),...
    'm2dFNR95ConfidenceIntervalFromMeanROCPerGroup', m2dFNRAndErrorPerGroup(2:3,:));

