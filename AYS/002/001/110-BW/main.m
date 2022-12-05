Experiment.StartNewSection('Analysis');

oLabels = ExperimentManager.Load('LBL-201').GetLabelledFeatureValues();
vbIsPositive = oLabels.GetLabels() == oLabels.GetPositiveLabel();

dNumPositives = sum(vbIsPositive);
dNumNegatives = sum(~vbIsPositive);

sVisionAndExpertExpCode = "EXP-100-601-101";
sVisionAndAvantoExpCode = "EXP-100-601-104";
sExpertAndAvantoExpCode = "EXP-100-601-105";

[m2dXAndCI_VisionAndExpert, m2dYAndCI_VisionAndExpert, vdAUCAndCI_VisionAndExpert, vdMCRAndCI_VisionAndExpert, vdFNRAndCI_VisionAndExpert, vdFPRAndCI_VisionAndExpert, dOptimalThresholdPointIndex_VisionAndExpert, dAUC_0Point632PlusPerBootstrap_VisionAndExpert] = GenerateROCAndCIMetrics(sVisionAndExpertExpCode, dNumPositives, dNumNegatives);
[m2dXAndCI_VisionAndAvanto, m2dYAndCI_VisionAndAvanto, vdAUCAndCI_VisionAndAvanto, vdMCRAndCI_VisionAndAvanto, vdFNRAndCI_VisionAndAvanto, vdFPRAndCI_VisionAndAvanto, dOptimalThresholdPointIndex_VisionAndAvanto, dAUC_0Point632PlusPerBootstrap_VisionAndAvanto] = GenerateROCAndCIMetrics(sVisionAndAvantoExpCode, dNumPositives, dNumNegatives);
[m2dXAndCI_ExpertAndAvanto, m2dYAndCI_ExpertAndAvanto, vdAUCAndCI_ExpertAndAvanto, vdMCRAndCI_ExpertAndAvanto, vdFNRAndCI_ExpertAndAvanto, vdFPRAndCI_ExpertAndAvanto, dOptimalThresholdPointIndex_ExpertAndAvanto, dAUC_0Point632PlusPerBootstrap_ExpertAndAvanto] = GenerateROCAndCIMetrics(sExpertAndAvantoExpCode, dNumPositives, dNumNegatives);

hFig = figure();
hold('on');
axis('square');

vdFigDims_cm = [17/2 17/2];

hFig.Units = 'centimeters';

vdPos = hFig.Position;
vdPos(3:4) = vdFigDims_cm;
hFig.Position = vdPos;

hROC_VisionAndExpert = PlotROCWithErrorBounds(m2dXAndCI_VisionAndExpert, m2dYAndCI_VisionAndExpert, dOptimalThresholdPointIndex_VisionAndExpert, [0 0 0]/255);
hROC_VisionAndAvanto = PlotROCWithErrorBounds(m2dXAndCI_VisionAndAvanto, m2dYAndCI_VisionAndAvanto, dOptimalThresholdPointIndex_VisionAndAvanto, [0 0 0]/255);
hROC_ExpertAndAvanto = PlotROCWithErrorBounds(m2dXAndCI_ExpertAndAvanto, m2dYAndCI_ExpertAndAvanto, dOptimalThresholdPointIndex_ExpertAndAvanto, [0 0 0]/255);

hChance = plot([0 1], [0, 1], '--k', 'LineWidth', 1.5);

ylim([0-0.01, 1+0.01]);
xlim([0-0.01, 1+0.01]);

xticks(0:0.1:1);
yticks(0:0.1:1);

grid('on');

ylabel('True Positive Rate');
xlabel('False Positive Rate');

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';



saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Available Features (No Legend).svg'));

legend([hROC_VisionAndExpert, hROC_VisionAndAvanto, hROC_ExpertAndAvanto, hChance], "Vision & Expert", "Vision & Avanto", "Expert & Avanto", "No Skill", "Location", 'southeast');

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Available Features (With Legend).svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROCs Across Available Features.fig'));

close(hFig);

vsErrorMetricsHeaders = ["Features", "AUC (CI)", "AUC_0.632+", "MCR (CI)", "FNR (CI)", "FPR (CI)"];
vsErrorMetricsVisionAndExpert = [...
    "Vision & Expert",...
    string(round(vdAUCAndCI_VisionAndExpert(1),2)) + " (" + string(round(mean(abs(vdAUCAndCI_VisionAndExpert(2:3) - vdAUCAndCI_VisionAndExpert(1))),2)) + ")",... 
    string(round(dAUC_0Point632PlusPerBootstrap_VisionAndExpert,2)),...
    string(round(100*vdMCRAndCI_VisionAndExpert(1),1)) + " (" + string(round(100*mean(abs(vdMCRAndCI_VisionAndExpert(2:3) - vdMCRAndCI_VisionAndExpert(1))),1)) + ")",...
    string(round(100*vdFNRAndCI_VisionAndExpert(1),1)) + " (" + string(round(100*mean(abs(vdFNRAndCI_VisionAndExpert(2:3) - vdFNRAndCI_VisionAndExpert(1))),1)) + ")",...
    string(round(100*vdFPRAndCI_VisionAndExpert(1),1)) + " (" + string(round(100*mean(abs(vdFPRAndCI_VisionAndExpert(2:3) - vdFPRAndCI_VisionAndExpert(1))),1)) + ")"];
vsErrorMetricsVisionAndAvanto = [...
    "Vision & Avanto",...
    string(round(vdAUCAndCI_VisionAndAvanto(1),2)) + " (" + string(round(mean(abs(vdAUCAndCI_VisionAndAvanto(2:3) - vdAUCAndCI_VisionAndAvanto(1))),2)) + ")",... 
    string(round(dAUC_0Point632PlusPerBootstrap_VisionAndAvanto,2)),...
    string(round(100*vdMCRAndCI_VisionAndAvanto(1),1)) + " (" + string(round(100*mean(abs(vdMCRAndCI_VisionAndAvanto(2:3) - vdMCRAndCI_VisionAndAvanto(1))),1)) + ")",...
    string(round(100*vdFNRAndCI_VisionAndAvanto(1),1)) + " (" + string(round(100*mean(abs(vdFNRAndCI_VisionAndAvanto(2:3) - vdFNRAndCI_VisionAndAvanto(1))),1)) + ")",...
    string(round(100*vdFPRAndCI_VisionAndAvanto(1),1)) + " (" + string(round(100*mean(abs(vdFPRAndCI_VisionAndAvanto(2:3) - vdFPRAndCI_VisionAndAvanto(1))),1)) + ")"];
vsErrorMetricsExpertAndAvanto = [...
    "Expert & Avanto",...
    string(round(vdAUCAndCI_ExpertAndAvanto(1),2)) + " (" + string(round(mean(abs(vdAUCAndCI_ExpertAndAvanto(2:3) - vdAUCAndCI_ExpertAndAvanto(1))),2)) + ")",... 
    string(round(dAUC_0Point632PlusPerBootstrap_ExpertAndAvanto,2)),...
    string(round(100*vdMCRAndCI_ExpertAndAvanto(1),1)) + " (" + string(round(100*mean(abs(vdMCRAndCI_ExpertAndAvanto(2:3) - vdMCRAndCI_ExpertAndAvanto(1))),1)) + ")",...
    string(round(100*vdFNRAndCI_ExpertAndAvanto(1),1)) + " (" + string(round(100*mean(abs(vdFNRAndCI_ExpertAndAvanto(2:3) - vdFNRAndCI_ExpertAndAvanto(1))),1)) + ")",...
    string(round(100*vdFPRAndCI_ExpertAndAvanto(1),1)) + " (" + string(round(100*mean(abs(vdFPRAndCI_ExpertAndAvanto(2:3) - vdFPRAndCI_ExpertAndAvanto(1))),1)) + ")"];

disp([vsErrorMetricsHeaders; vsErrorMetricsVisionAndExpert; vsErrorMetricsVisionAndAvanto; vsErrorMetricsExpertAndAvanto]);


function [m2dXAndCI, m2dYAndCI, vdAUCAndCI, vdMCRAndCI, vdFNRAndCI, vdFPRAndCI, dPointIndexForOptThres, dAUC_0Point632PlusPerBootstrap] = GenerateROCAndCIMetrics(sExpCode, dNumPositives, dNumNegatives)

[c1oGuessResultsPerPartition, c1oOOBGuessResultsPerPartition] = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), "02 Bootstrapped Iterations ", "Partitions & Guess Results.mat"), "c1oGuessResultsPerPartition", "c1oOOBSamplesGuessResultsPerPartition");
vdAUC_0Point632PlusPerBootstrap = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExpCode), "03 Performance", "AUC Metrics.mat"), "vdAUC_0Point632PlusPerBootstrap");

dAUC_0Point632PlusPerBootstrap = mean(vdAUC_0Point632PlusPerBootstrap);

dNumBootstraps = length(c1oGuessResultsPerPartition);

c1vdConfidencesPerBootstrap = cell(dNumBootstraps,1);
c1vdTrueLabelsPerBootstrap = cell(dNumBootstraps,1);

c1vdOOBConfidencesPerBootstrap = cell(dNumBootstraps,1);
c1vdOOBTrueLabelsPerBootstrap = cell(dNumBootstraps,1);

dPosLabel = c1oGuessResultsPerPartition{1}.GetPositiveLabel();

for dBootstrapIndex=1:dNumBootstraps
    oGuessResult = c1oGuessResultsPerPartition{dBootstrapIndex};
    
    c1vdConfidencesPerBootstrap{dBootstrapIndex} = oGuessResult.GetPositiveLabelConfidences();
    c1vdTrueLabelsPerBootstrap{dBootstrapIndex} = oGuessResult.GetLabels();
    
    oOOBGuessResult = c1oOOBGuessResultsPerPartition{dBootstrapIndex};
    
    c1vdOOBConfidencesPerBootstrap{dBootstrapIndex} = oOOBGuessResult.GetPositiveLabelConfidences();
    c1vdOOBTrueLabelsPerBootstrap{dBootstrapIndex} = oOOBGuessResult.GetLabels();
end

% Use perfcurve and non-OOB samples to calculate AUC
[m2dXAndCI, m2dYAndCI, vdT, vdAUCAndCI] = perfcurve(c1vdTrueLabelsPerBootstrap, c1vdConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1);

% Use perfcurve and OOB samples to find optimal threshold (upper
% left)
[m2dOOBX, m2dOOBY, vdOOBT, ~] = perfcurve(c1vdOOBTrueLabelsPerBootstrap, c1vdOOBConfidencesPerBootstrap, dPosLabel, 'TVals', 0:0.001:1);

vdUpperLeftDist = ((m2dOOBX(:,1)).^2) + ((1-m2dOOBY(:,1)).^2);
[~,dMinIndex] = min(vdUpperLeftDist);
dOptThres = vdOOBT(dMinIndex);

% find the corresponding closest point on the non-OOB ROC for the
% same threshold
[~,dPointIndexForOptThres] = min(abs(dOptThres - vdT(:,1)));

% get FPR, FNR and MCR from ROC
vdFPRAndCI = m2dXAndCI(dPointIndexForOptThres,:); % since ROC
vdTPRAndCI = m2dYAndCI(dPointIndexForOptThres,:); % since ROC

vdFNRAndCI = 1-vdTPRAndCI; % by defn
vdTNRAndCI = 1-vdFPRAndCI; % by defn

vdFNRAndCI([2,3]) = vdFNRAndCI([3,2]); % CIs are backwards
vdTNRAndCI([2,3]) = vdTNRAndCI([3,2]); % CIs are backwards

vdFPAndCI = vdFPRAndCI * dNumNegatives; % by defn
vdFNAndCI = vdFNRAndCI * dNumPositives; % by defn

vdMCRAndCI = (vdFPAndCI + vdFNAndCI) ./ (dNumPositives + dNumNegatives);


end

function hROC = PlotROCWithErrorBounds(m2dXAndError, m2dYAndError, dOptimalThresholdPointIndex, vdColour)

hROC = plot(m2dXAndError(:,1), m2dYAndError(:,1), '-', 'Color', vdColour, 'LineWidth', 1.5);

hPatch = patch('XData', [m2dXAndError(:,2); flipud(m2dXAndError(:,3))], 'YData', [m2dYAndError(:,3); flipud(m2dYAndError(:,2))]);
hPatch.FaceColor = vdColour;
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.25;

%operating point
plot(m2dXAndError(dOptimalThresholdPointIndex,1), m2dYAndError(dOptimalThresholdPointIndex,1), 'Marker', '+', 'MarkerSize', 8, 'Color', [0 0 0], 'LineWidth', 1.5);

% errorbar(m2dXAndError(dOptimalThresholdPointIndex,1), m2dYAndError(dOptimalThresholdPointIndex,1),...
%     m2dYAndError(dOptimalThresholdPointIndex,1)-m2dYAndError(dOptimalThresholdPointIndex,2), m2dYAndError(dOptimalThresholdPointIndex,3)-m2dYAndError(dOptimalThresholdPointIndex,1),...
%     m2dXAndError(dOptimalThresholdPointIndex,1)-m2dXAndError(dOptimalThresholdPointIndex,2), m2dXAndError(dOptimalThresholdPointIndex,3)-m2dXAndError(dOptimalThresholdPointIndex,1),...
%     'Marker', '.', 'MarkerSize', 10, 'Color', [0 0 0]);
end