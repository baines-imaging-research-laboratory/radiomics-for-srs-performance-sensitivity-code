Experiment.StartNewSection('Analysis');

[...
    vdCorrelationCoefficientCutoffs, vsVolumeGroups,...
    m2dAUCFromMeanROCPerGroupPerCutoff, m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff,...
    m2dFPRFromMeanROCPerGroupPerCutoff, m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff,...
    m2dFNRFromMeanROCPerGroupPerCutoff, m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff] = ...
    FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-001-007-023'), '01 Analysis', 'Error Metrics Per Volume Split, Bootstrap and Cutoff.mat'),...
    'vdCutoffValues',...
    'vsVolumeGroups',...
    'm2dAUCFromMeanROCPerGroupPerCutoff', 'm3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff',...
    'm2dFPRFromMeanROCPerGroupPerCutoff', 'm3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff',...
    'm2dFNRFromMeanROCPerGroupPerCutoff', 'm3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff');

dNumGroups = size(m2dAUCFromMeanROCPerGroupPerCutoff,1);
dNumCutoffs = size(m2dAUCFromMeanROCPerGroupPerCutoff,2);

   


vdFigDims_cm = [17/2 0.55*(17/2)];

vdAUCPerGroup = m2dAUCFromMeanROCPerGroupPerCutoff(:,1);
vdFNRPerGroup = m2dFNRFromMeanROCPerGroupPerCutoff(:,1);
vdFPRPerGroup = m2dFPRFromMeanROCPerGroupPerCutoff(:,1);

m2dDataPerGroupPerVariable = [vdAUCPerGroup'; vdFNRPerGroup'; vdFPRPerGroup'];
vsLabelPerGroup = ["AUC", "FNR", "FPR"];

m3dAUCFromMeanROCPerGroupPerCutoff = zeros([2, size(m2dAUCFromMeanROCPerGroupPerCutoff)]);
m3dAUCFromMeanROCPerGroupPerCutoff(1,:,:) = m2dAUCFromMeanROCPerGroupPerCutoff;
m3dAUCFromMeanROCPerGroupPerCutoff(2,:,:) = m2dAUCFromMeanROCPerGroupPerCutoff;

m2dAUCErrorBarSizePerGroupPerCutoff = squeeze(mean(abs(m3dAUCFromMeanROCPerGroupPerCutoff-m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff),1));


m3dFNRFromMeanROCPerGroupPerCutoff = zeros([2, size(m2dFNRFromMeanROCPerGroupPerCutoff)]);
m3dFNRFromMeanROCPerGroupPerCutoff(1,:,:) = m2dFNRFromMeanROCPerGroupPerCutoff;
m3dFNRFromMeanROCPerGroupPerCutoff(2,:,:) = m2dFNRFromMeanROCPerGroupPerCutoff;

m2dFNRErrorBarSizePerGroupPerCutoff = squeeze(mean(abs(m3dFNRFromMeanROCPerGroupPerCutoff-m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff),1));


m3dFPRFromMeanROCPerGroupPerCutoff = zeros([2, size(m2dFPRFromMeanROCPerGroupPerCutoff)]);
m3dFPRFromMeanROCPerGroupPerCutoff(1,:,:) = m2dFPRFromMeanROCPerGroupPerCutoff;
m3dFPRFromMeanROCPerGroupPerCutoff(2,:,:) = m2dFPRFromMeanROCPerGroupPerCutoff;

m2dFPRErrorBarSizePerGroupPerCutoff = squeeze(mean(abs(m3dFPRFromMeanROCPerGroupPerCutoff-m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff),1));



m2dErrorBarSizePerGroupPerVariable = [m2dAUCErrorBarSizePerGroupPerCutoff(:,1)'; m2dFNRErrorBarSizePerGroupPerCutoff(:,1)'; m2dFPRErrorBarSizePerGroupPerCutoff(:,1)'];

[hFig, hLegend] = CreateBarGraph(m2dDataPerGroupPerVariable, vsLabelPerGroup,...
    'ErrorBarSizePerGroupPerVariable', m2dErrorBarSizePerGroupPerVariable,...
    'FontSize', 8, 'FontName', 'Arial',...
    'TexturePerVariable', ["Cross45", "Line135", "Line135"],...
    'TextureColourPerVariable', {[0.65 0.65 0.65], [0.40 0.40 0.40], [0.85 0.85 0.85]},...
    'TextureLineWidth', 1, 'TextureLineSpacing' , 4,...
    'BarColourPerVariable', {[1 1 1], [0.75 0.75 0.75], [0.5 0.5 0.5]},...
    'XLabel', "Error Metrics for Correlation Cut-off = 1",...
    'YLabel', "Error Metric Value",...
    'YTicks', 0:0.1:0.7, 'YLim', [0 0.75],...
    'FigureSize', vdFigDims_cm, 'FigureSizeUnits', 'centimeters',...
    'FillFigure', false,...
    'LegendVariableNames', ["Combined", "< 7.5 cc", "> 7.5 cc"]);


hAxes = gca;

hAxes.YGrid = 'on';
hAxes.XGrid = 'off';

hAxes.YMinorTick = 'on';
hAxes.YMinorGrid = 'on';
hAxes.YRuler.MinorTickValues = 0.05:0.1:0.75;



saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'Cut-off = 1 Error Metrics.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'Cut-off = 1 Error Metrics.fig'));
delete(hFig);

saveas(hLegend, fullfile(Experiment.GetResultsDirectory(), 'Cut-off = 1 Error Metrics Legend.svg'));
savefig(hLegend, fullfile(Experiment.GetResultsDirectory(), 'Cut-off = 1 Error Metrics Legend.fig'));
delete(hLegend);



hFig = figure();

hFig.Units = 'centimeters';

vdPos = hFig.Position;
vdPos(3:4) = vdFigDims_cm;
hFig.Position = vdPos;

hold('on');

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,1,:)); flipud(squeeze(m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,1,:)))]);
hPatch.FaceColor = [0.009 0.009 0.009];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,2,:)); flipud(squeeze(m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,2,:)))]);
hPatch.FaceColor = [0.005 0.005 0.005];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,3,:)); flipud(squeeze(m3dAUC95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,3,:)))]);
hPatch.FaceColor = [0.001 0.001 0.001];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

plot(-vdCorrelationCoefficientCutoffs, m2dAUCFromMeanROCPerGroupPerCutoff(1,:), '-', 'LineWidth', 1.75, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot(-vdCorrelationCoefficientCutoffs, m2dAUCFromMeanROCPerGroupPerCutoff(2,:), ':', 'LineWidth', 1.5, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot(-vdCorrelationCoefficientCutoffs, m2dAUCFromMeanROCPerGroupPerCutoff(3,:), '--', 'LineWidth', 0.9, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);



ylabel("AUC");
xlabel("Correlation Cut-off");

xticks(-vdCorrelationCoefficientCutoffs);
xticklabels(string(vdCorrelationCoefficientCutoffs));

xlim(-vdCorrelationCoefficientCutoffs([1,end]));

grid('on');

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';

hAxes.TickDir = 'both';

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROC AUC.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'ROC AUC.fig'));
delete(hFig);




hFig = figure();

hFig.Units = 'centimeters';

vdPos = hFig.Position;
vdPos(3:4) = vdFigDims_cm;
hFig.Position = vdPos;

hold('on');

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,1,:)); flipud(squeeze(m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,1,:)))]);
hPatch.FaceColor = [0.009 0.009 0.009];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,2,:)); flipud(squeeze(m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,2,:)))]);
hPatch.FaceColor = [0.005 0.005 0.005];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,3,:)); flipud(squeeze(m3dFPR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,3,:)))]);
hPatch.FaceColor = [0.001 0.001 0.001];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

plot(-vdCorrelationCoefficientCutoffs, m2dFPRFromMeanROCPerGroupPerCutoff(1,:), '-', 'LineWidth', 1.75, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot(-vdCorrelationCoefficientCutoffs, m2dFPRFromMeanROCPerGroupPerCutoff(2,:), ':', 'LineWidth', 1.5, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot(-vdCorrelationCoefficientCutoffs, m2dFPRFromMeanROCPerGroupPerCutoff(3,:), '--', 'LineWidth', 0.9, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);



ylabel("FPR");
xlabel("Correlation Cut-off");

xticks(-vdCorrelationCoefficientCutoffs);
xticklabels(string(vdCorrelationCoefficientCutoffs));

xlim(-vdCorrelationCoefficientCutoffs([1,end]));
ylim([0.25 0.6]);

yticks(0.25:0.05:0.6);


grid('on');

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';

hAxes.TickDir = 'both';

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'FPR.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'FPR.fig'));
delete(hFig);



hFig = figure();

hFig.Units = 'centimeters';

vdPos = hFig.Position;
vdPos(3:4) = vdFigDims_cm;
hFig.Position = vdPos;

hold('on');

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,1,:)); flipud(squeeze(m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,1,:)))]);
hPatch.FaceColor = [0.009 0.009 0.009];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,2,:)); flipud(squeeze(m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,2,:)))]);
hPatch.FaceColor = [0.005 0.005 0.005];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

hPatch = patch('XData', [-vdCorrelationCoefficientCutoffs'; flipud(-vdCorrelationCoefficientCutoffs')], 'YData', [squeeze(m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(1,3,:)); flipud(squeeze(m3dFNR95ConfidenceIntervalFromMeanROCPerGroupPerCutoff(2,3,:)))]);
hPatch.FaceColor = [0.001 0.001 0.001];
hPatch.LineStyle = 'none';
hPatch.FaceAlpha = 0.3;

plot(-vdCorrelationCoefficientCutoffs, m2dFNRFromMeanROCPerGroupPerCutoff(1,:), '-', 'LineWidth', 1.75, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot(-vdCorrelationCoefficientCutoffs, m2dFNRFromMeanROCPerGroupPerCutoff(2,:), ':', 'LineWidth', 1.5, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot(-vdCorrelationCoefficientCutoffs, m2dFNRFromMeanROCPerGroupPerCutoff(3,:), '--', 'LineWidth', 0.9, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);



ylabel("FNR");
xlabel("Correlation Cut-off");

xticks(-vdCorrelationCoefficientCutoffs);
xticklabels(string(vdCorrelationCoefficientCutoffs));

xlim(-vdCorrelationCoefficientCutoffs([1,end]));
ylim([0.25 0.6]);

yticks(0.25:0.05:0.6);

grid('on');

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';

hAxes.TickDir = 'both';

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'FNR.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'FNR.fig'));
delete(hFig);




hFig = figure();

hold('on');

vdAUCPerGroup = m2dAUCFromMeanROCPerGroupPerCutoff(:,1);
vdFNRPerGroup = m2dFNRFromMeanROCPerGroupPerCutoff(:,1);
vdFPRPerGroup = m2dFPRFromMeanROCPerGroupPerCutoff(:,1);

vdBarPlotXValues = 1:3;
m2dBarPlotData = [vdAUCPerGroup'; vdFNRPerGroup'; vdFPRPerGroup'];

hBarPlot = bar(vdBarPlotXValues, m2dBarPlotData, 'FaceColor', 'flat');

hBarPlot(1).CData = 1*[1 1 1];
hBarPlot(2).CData = 0.8*[1 1 1];
hBarPlot(3).CData = 0.6*[1 1 1];

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';

legend(["Combined", "< 7.5 cc", "> 7.5 cc"], 'Location', 'southoutside', 'FontSize', 10);

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'Legend Bars.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'Legend Bars.fig'));
delete(hFig);



hFig = figure();

hold('on');

plot([0 1], [0 1], '-', 'LineWidth', 1.75, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot([0 1], [0 1], ':', 'LineWidth', 1.5, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);
plot([0 1], [0 1], '--', 'LineWidth', 0.9, 'Color', 0*[1 1 1], 'Marker', '.', 'MarkerSize', 14);

hAxes = gca;

hAxes.FontSize = 8;
hAxes.FontName = 'Arial';

legend(["Combined", "  < 7.5 cc", "  > 7.5 cc"], 'Location', 'southoutside', 'FontSize', 10);

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'Legend Lines.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'Legend Lines.fig'));
delete(hFig);

