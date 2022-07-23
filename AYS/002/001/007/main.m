Experiment.StartNewSection('Analysis');

vdPRAUCBaseline = [nan 0.13 0.36 0.13 0.40 0.67 nan];

[vsPrimarySiteGroups, vdAUCFromMeanROCPerGroup, m2dAUC95ConfidenceIntervalFromMeanROCPerGroup, vdPRAUCFromMeanPRCPerGroup, m2dPRAUC95ConfidenceIntervalFromMeanPRCPerGroup, vdMCRFromMeanROCPerGroup, m2dMCR95ConfidenceIntervalFromMeanROCPerGroup, vdFPRFromMeanROCPerGroup, m2dFPR95ConfidenceIntervalFromMeanROCPerGroup, vdFNRFromMeanROCPerGroup, m2dFNR95ConfidenceIntervalFromMeanROCPerGroup] = ...
    FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-001-007-022'), '01 Analysis', 'Error Metrics Per Volume Split, Bootstrap and Cutoff.mat'),...
    'vsPrimarySiteGroups', 'vdAUCFromMeanROCPerGroup', 'm2dAUC95ConfidenceIntervalFromMeanROCPerGroup', 'vdPRAUCFromMeanPRCPerGroup', 'm2dPRAUC95ConfidenceIntervalFromMeanPRCPerGroup', 'vdMCRFromMeanROCPerGroup', 'm2dMCR95ConfidenceIntervalFromMeanROCPerGroup', 'vdFPRFromMeanROCPerGroup', 'm2dFPR95ConfidenceIntervalFromMeanROCPerGroup', 'vdFNRFromMeanROCPerGroup', 'm2dFNR95ConfidenceIntervalFromMeanROCPerGroup');

dNumGroups = length(vsPrimarySiteGroups);

vsDisp = ["Group", "AUC (CI)" "PR AUC From Baseline (CI)", "MCR (CI)", "FNR (CI)", "FPR (CI)"];

for dGroupIndex=2:dNumGroups % skip "All"
    vsDisp = [vsDisp; ...
        vsPrimarySiteGroups(dGroupIndex),...
        string(round(vdAUCFromMeanROCPerGroup(dGroupIndex),2)) + " (" + string(round(mean(abs(m2dAUC95ConfidenceIntervalFromMeanROCPerGroup(:,dGroupIndex) - vdAUCFromMeanROCPerGroup(dGroupIndex))),2)) + ")",...
        string(round(vdPRAUCFromMeanPRCPerGroup(dGroupIndex)-vdPRAUCBaseline(dGroupIndex),2)) + " (" + string(round(mean(abs(m2dPRAUC95ConfidenceIntervalFromMeanPRCPerGroup(:,dGroupIndex) - vdPRAUCFromMeanPRCPerGroup(dGroupIndex))),2)) + ")",...
        string(round(100*vdMCRFromMeanROCPerGroup(dGroupIndex),1)) + " (" + string(round(100*mean(abs(m2dMCR95ConfidenceIntervalFromMeanROCPerGroup(:,dGroupIndex) - vdMCRFromMeanROCPerGroup(dGroupIndex))),1)) + ")",...
        string(round(100*vdFNRFromMeanROCPerGroup(dGroupIndex),1)) + " (" + string(round(100*mean(abs(m2dFNR95ConfidenceIntervalFromMeanROCPerGroup(:,dGroupIndex) - vdFNRFromMeanROCPerGroup(dGroupIndex))),1)) + ")",...
        string(round(100*vdFPRFromMeanROCPerGroup(dGroupIndex),1)) + " (" + string(round(100*mean(abs(m2dFPR95ConfidenceIntervalFromMeanROCPerGroup(:,dGroupIndex) - vdFPRFromMeanROCPerGroup(dGroupIndex))),1)) + ")"];
end

disp(vsDisp);
