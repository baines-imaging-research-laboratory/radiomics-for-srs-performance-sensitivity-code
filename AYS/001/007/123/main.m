Experiment.StartNewSection('Analysis');


vdCutoffValues = [1 0.85 0.7 0.55 0.4 0.25 0.1 0];
vsExpCodePerCutoff = [...
    "EXP-100-400-202"
    "EXP-100-501-101"
    "EXP-100-501-102"
    "EXP-100-501-103"
    "EXP-100-501-104"
    "EXP-100-501-105"
    "EXP-100-501-106"
    "EXP-100-500-110"];

dNumCutoffs = length(vsExpCodePerCutoff);

oLabels = ExperimentManager.Load('LBL-201').GetLabelledFeatureValues();
vbIsPositive = oLabels.GetLabels() == oLabels.GetPositiveLabel();

oClinicalFeatureValues = ExperimentManager.Load('FV-500-104').GetFeatureValues();


oFeatureValuesVolume = ExperimentManager.Load('FV-500-400').GetFeatureValues();
vdVolume_mm3 = oFeatureValuesVolume.GetFeatures();


vdVolumeBinEdges = [2.4^3 7.5*10^3 31.2^3];

vdVolumeGroupPerSample = zeros(oClinicalFeatureValues.GetNumberOfSamples(),1);

for dGroupIndex=1:length(vdVolumeBinEdges)-1
    dBottom = vdVolumeBinEdges(dGroupIndex);
    dTop = vdVolumeBinEdges(dGroupIndex+1);
    
    vdVolumeGroupPerSample(dBottom <= vdVolume_mm3 & vdVolume_mm3 < dTop) = dGroupIndex;
end

vdVolumeGroupValues = 1:length(vdVolumeBinEdges)-1;
vsVolumeGroups = (string(round(vdVolumeBinEdges(1:end-1))) + " - " + string(round(vdVolumeBinEdges(2:end)))) + "mm3";

vsVolumeGroups = ["All", vsVolumeGroups];

dNumGroups = length(vsVolumeGroups);

viGroupIds = oClinicalFeatureValues.GetGroupIds();
viSubGroupIds = oClinicalFeatureValues.GetSubGroupIds();

dNumBootstraps = 250;

m3dAUCPerGroupPerCutoffPerBootstrap = nan(dNumGroups, dNumCutoffs, dNumBootstraps);
m3dPRAUCPerGroupPerCutoffPerBootstrap = nan(dNumGroups, dNumCutoffs, dNumBootstraps);
m3dMCRPerGroupPerCutoffPerBootstrap = nan(dNumGroups, dNumCutoffs, dNumBootstraps);
m3dFPRPerGroupPerCutoffPerBootstrap = nan(dNumGroups, dNumCutoffs, dNumBootstraps);
m3dFNRPerGroupPerCutoffPerBootstrap = nan(dNumGroups, dNumCutoffs, dNumBootstraps);

m3dAUCAndErrorPerGroupPerCutoff = nan(3, dNumGroups, dNumCutoffs);
m3dPRAUCAndErrorPerGroupPerCutoff = nan(3, dNumGroups, dNumCutoffs);
m3dMCRAndErrorPerGroupPerCutoff = nan(3, dNumGroups, dNumCutoffs);
m3dFPRAndErrorPerGroupPerCutoff = nan(3, dNumGroups, dNumCutoffs);
m3dFNRAndErrorPerGroupPerCutoff = nan(3, dNumGroups, dNumCutoffs);

for dCutoffIndex=1:dNumCutoffs
    disp(dCutoffIndex);
    
    sExp = vsExpCodePerCutoff(dCutoffIndex);
    
    [c1oGuessResultsPerPartition, c1oOOBSamplesGuessResultsPerPartition] = FileIOUtils.LoadMatFile(...
        fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExp), '02 Bootstrapped Iterations', 'Partitions & Guess Results.mat'),...
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
    
    
    
    
    
    
    
    
    for dGroupIndex=1:dNumGroups
        c1vdConfidencesPerBootstrap = cell(dNumBootstraps,1);
        c1vdTrueLabelsPerBootstrap = cell(dNumBootstraps,1);
        
        c1vdOOBConfidencesPerBootstrap = cell(dNumBootstraps,1);
        c1vdOOBTrueLabelsPerBootstrap = cell(dNumBootstraps,1);
        
        dPosLabel = c1oGuessResultsPerPartition{1}.GetPositiveLabel();
        
        
        if dGroupIndex == 1 % All
            vbInGroup = true(size(vdVolumeGroupPerSample));
        else
            vbInGroup = vdVolumeGroupPerSample == (dGroupIndex-1);
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
            
            c1vdOOBConfidencesPerBootstrap{dBootstrapIndex} = vdOOBConfidencesForAnalysis;
            c1vdOOBTrueLabelsPerBootstrap{dBootstrapIndex} = double(vbOOBIsPositiveForAnalysis);
            
            
            
            try
                m3dAUCPerGroupPerCutoffPerBootstrap(dGroupIndex, dCutoffIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateAUC(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), 'JournalingOn', false);
                m3dPRAUCPerGroupPerCutoffPerBootstrap(dGroupIndex, dCutoffIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculatePRAUC(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), 'JournalingOn', false);
            catch e
            end
            
            try
                dThreshold = ErrorMetricsCalculator.CalculateOptimalThreshold({'upperleft','MCR'}, uint8(vbOOBIsPositiveForAnalysis), vdOOBConfidencesForAnalysis, uint8(1), 'JournalingOn', false); % calculate optimal threshold with OOB training set samples
                
                m3dMCRPerGroupPerCutoffPerBootstrap(dGroupIndex, dCutoffIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateMisclassificationRate(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), dThreshold, 'JournalingOn', false);
                m3dFNRPerGroupPerCutoffPerBootstrap(dGroupIndex, dCutoffIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateFalseNegativeRate(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), dThreshold, 'JournalingOn', false);
                m3dFPRPerGroupPerCutoffPerBootstrap(dGroupIndex, dCutoffIndex, dBootstrapIndex) = ErrorMetricsCalculator.CalculateFalsePositiveRate(uint8(vbIsPositiveForAnalysis), vdConfidencesForAnalysis, uint8(1), dThreshold, 'JournalingOn', false);
            catch e
            end
        end
        
        % Use perfcurve and non-OOB samples to calculate AUC and PRAUC
        [m2dX, m2dY, vdT, vdAUC] = perfcurve(c1vdTrueLabelsPerBootstrap, c1vdConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1);
        [~, ~, ~, vdPRAUC] = perfcurve(c1vdTrueLabelsPerBootstrap, c1vdConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1, 'XCrit', 'reca', 'YCrit', 'prec');
        
        m3dAUCAndErrorPerGroupPerCutoff(:, dGroupIndex, dCutoffIndex) = vdAUC;
        m3dPRAUCAndErrorPerGroupPerCutoff(:, dGroupIndex, dCutoffIndex) = vdPRAUC;
        
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
        
        m3dFPRAndErrorPerGroupPerCutoff(:, dGroupIndex, dCutoffIndex) = vdFPR;
        m3dFNRAndErrorPerGroupPerCutoff(:, dGroupIndex, dCutoffIndex) = vdFNR; 
        
        dNumPos = sum(vbIsPositive == 1);
        dNumNeg = sum(vbIsPositive == 0);
        
        vdFP = vdFPR * dNumNeg; % by defn
        vdFN = vdFNR * dNumPos; % by defn
        
        m3dMCRAndErrorPerGroupPerCutoff(:, dGroupIndex, dCutoffIndex) = (vdFP + vdFN) ./ (dNumPos + dNumNeg); 
    end
    
end
    
FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'Error Metrics Per Volume Split, Bootstrap and Cutoff.mat'),...
    'vdCutoffValues', vdCutoffValues,...
    'vdVolumeGroupPerSample', vdVolumeGroupPerSample, 'vsVolumeGroups', vsVolumeGroups,...
    'm3dAUCPerGroupPerCutoffPerBootstrap', m3dAUCPerGroupPerCutoffPerBootstrap,...
    'm3dPRAUCPerGroupPerCutoffPerBootstrap', m3dPRAUCPerGroupPerCutoffPerBootstrap,...
    'm3dMCRPerGroupPerCutoffPerBootstrap', m3dMCRPerGroupPerCutoffPerBootstrap,...
    'm3dFPRPerGroupPerCutoffPerBootstrap', m3dFPRPerGroupPerCutoffPerBootstrap,...
    'm3dFNRPerGroupPerCutoffPerBootstrap', m3dFNRPerGroupPerCutoffPerBootstrap,...
    ...
    'm2dAUCFromMeanROCPerGroupPerCutoff', squeeze(m3dAUCAndErrorPerGroupPerCutoff(1,:,:)),...
    'm3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff', m3dAUCAndErrorPerGroupPerCutoff(2:3,:,:),...
    'm2dPRAUCFromMeanPRCPerGroupPerCutoff', squeeze(m3dPRAUCAndErrorPerGroupPerCutoff(1,:,:)),...
    'm3dPRAUC95ConfidenceIntervalFromMeanPRCPerGroupPerCutoff', m3dPRAUCAndErrorPerGroupPerCutoff(2:3,:,:),...
    'm2dMCRFromMeanROCPerGroupPerCutoff', squeeze(m3dMCRAndErrorPerGroupPerCutoff(1,:,:)),...
    'm3dMCR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff', m3dMCRAndErrorPerGroupPerCutoff(2:3,:,:),...
    'm2dFPRFromMeanROCPerGroupPerCutoff', squeeze(m3dFPRAndErrorPerGroupPerCutoff(1,:,:)),...
    'm3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff', m3dFPRAndErrorPerGroupPerCutoff(2:3,:,:),...
    'm2dFNRFromMeanROCPerGroupPerCutoff', squeeze(m3dFNRAndErrorPerGroupPerCutoff(1,:,:)),...
    'm3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff', m3dFNRAndErrorPerGroupPerCutoff(2:3,:,:));
    
