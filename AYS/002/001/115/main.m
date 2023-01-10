% Feature importance rankings
Experiment.StartNewSection('Analysis');

vdCorrelationCoefficientCutoffs = [1 0.85 0.7 0.55 0.4 0.25 0.1 0]';
dNumCorrelationCoefficientCutoffs = length(vdCorrelationCoefficientCutoffs);

vsBaseExperimentExpCodesPerCutoff = [...
    "EXP-100-400-202"
    "EXP-100-701-001"
    "EXP-100-701-002"
    "EXP-100-701-003"
    "EXP-100-701-004"
    "EXP-100-701-005"
    "EXP-100-701-005" % number of features did not changes
    "EXP-100-701-005"]; % number of features did not changes

vsClinicalFeatureValueCodes = ["FV-500-104"];
vsRadiomicFeatureValueCodes = ["FV-705-001","FV-705-002","FV-705-005","FV-705-006","FV-705-007","FV-705-008","FV-705-009"];
sLabelsCode = "LBL-201";

oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsClinicalFeatureValueCodes,...
    sLabelsCode);


oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);

dNumBootstraps = 250;

dNumClinicalFeatures = oClinicalDataSet.GetNumberOfFeatures();
dNumRadiomicFeatures = oRadiomicDataSet.GetNumberOfFeatures();

dTotalNumFeatures = dNumClinicalFeatures + dNumRadiomicFeatures;

m2dFeatureImportancePerCutoffPerFeature = zeros(dNumCorrelationCoefficientCutoffs, dTotalNumFeatures); % NaN values mean feature was removed or not used (e.g. removed by correlation filter)
m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures = false(dNumCorrelationCoefficientCutoffs, dTotalNumFeatures);


vsFeatureGroups = ["Clinical", ""];

[vdCorrelationCoefficientToVolume, vdCorrelationCoefficientToVolumeCubeRoot] = FileIOUtils.LoadMatFile(fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory('AYS-001-006-004'), '01 Analysis', 'FV-705-XXX Volume Correlation Coefficients.mat'),...
            'vdCorrelationCoefficientToVolume', 'vdCorrelationCoefficientToVolumeCubeRoot');


for dCutoffIndex=1:dNumCorrelationCoefficientCutoffs
    disp(dCutoffIndex);
    sExp = vsBaseExperimentExpCodesPerCutoff(dCutoffIndex);
    
    if dCutoffIndex == 1
        vbKeepRadiomicFeature = true(1,oRadiomicDataSet.GetNumberOfFeatures());
        vbKeepClinicalFeature = true(1,oClinicalDataSet.GetNumberOfFeatures());
    else
        [vbKeepRadiomicFeature,vbKeepClinicalFeature] = FileIOUtils.LoadMatFile(...
            fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExp), '01 Loading Experiment Assets\Clinical and Radiomic Feature Filters.mat'),...
            'vbRadiomicFeatureSelection', 'vbClinicalFeatureSelection');
    end
    
    m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex, 1:dNumRadiomicFeatures) = ~vbKeepRadiomicFeature;
    m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex, dNumRadiomicFeatures+1:end) = ~vbKeepClinicalFeature;
    
    
    vbVolumeCorrelatedFeatureNamesMask = ~vbKeepRadiomicFeature;


    m2dFeatureRankingScorePerBootstrapPerFeature = nan(dNumBootstraps, dTotalNumFeatures);
    m2dFeatureRankPerBootstrapPerFeature = nan(dNumBootstraps, dTotalNumFeatures);
    
    chResultsPath = ExperimentManager.GetPathToExperimentAssetResultsDirectory(sExp);
    
    for dBootstrapIndex=1:dNumBootstraps
        [vbRadiomicMask, vdFeatureImportanceScores] = FileIOUtils.LoadMatFile(fullfile(chResultsPath, '02 Bootstrapped Iterations', "Iteration " + string(StringUtils.num2str_PadWithZeros(dBootstrapIndex,3)) + " Results.mat"),...
            'vbRadiomicFeatureMask', 'vdFeatureImportanceScores');
        
        vdFeatureRankings = zeros(size(vdFeatureImportanceScores));
        [~, vdSortIndices] = sort(vdFeatureImportanceScores, 'descend');
        
        for dFeatureIndex=1:length(vdFeatureImportanceScores)
            vdFeatureRankings(vdSortIndices(dFeatureIndex)) = dFeatureIndex;
        end
        
        vdNormalizedFeatureImportance = (vdFeatureImportanceScores - min(vdFeatureImportanceScores)) / (max(vdFeatureImportanceScores) - min(vdFeatureImportanceScores));
        
        vdClinicalFeatureImportanceScores = NaN(dNumClinicalFeatures,1);
        vdClinicalFeatureRankings = NaN(dNumClinicalFeatures,1);
        
        vdClinicalFeatureImportanceScores(vbKeepClinicalFeature) = vdNormalizedFeatureImportance(end-sum(vbKeepClinicalFeature)+1:end);
        vdClinicalFeatureRankings(vbKeepClinicalFeature) = vdFeatureRankings(end-sum(vbKeepClinicalFeature)+1:end);
                
        m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex, end-dNumClinicalFeatures+1:end) = vdClinicalFeatureImportanceScores;
        m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex, end-dNumClinicalFeatures+1:end) = vdClinicalFeatureRankings;
        
        
        
        vdInsertIndices = 1:dNumRadiomicFeatures;
        
        vdInsertIndices = vdInsertIndices(vbKeepRadiomicFeature); % account for feature loss due to volume correlation
        vdInsertIndices = vdInsertIndices(vbRadiomicMask); % account for feature loss due to inter-feature correlation
        
        m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex, vdInsertIndices) = vdNormalizedFeatureImportance(1:end-sum(vbKeepClinicalFeature));
        m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex, vdInsertIndices) = vdFeatureRankings(1:end-sum(vbKeepClinicalFeature));
        
        % nan correction:
        % want to set all nans due to inter-feature correlation to be
        % set to the min feature score or max feature rank to indicate
        % "these features were excluded by the correlation filter,
        % therefore they were the least important".
        
        vdNanIndices = 1:dNumRadiomicFeatures;
        vdNanIndices = vdNanIndices(vbKeepRadiomicFeature);
        vdNanIndices = vdNanIndices(~vbRadiomicMask);
        
        m2dFeatureRankingScorePerBootstrapPerFeature(dBootstrapIndex, vdNanIndices) = min(vdNormalizedFeatureImportance);
        m2dFeatureRankPerBootstrapPerFeature(dBootstrapIndex, vdNanIndices) = max(vdFeatureRankings);
    end
    
    vdAverageFeatureScore = zeros(1,dTotalNumFeatures);
    vdAverageFeatureRanking = zeros(1,dTotalNumFeatures);
    
    for dFeatureIndex=1:dTotalNumFeatures
        vdFeatureScores = m2dFeatureRankingScorePerBootstrapPerFeature(:,dFeatureIndex);
        vdFeatureScores = vdFeatureScores(~isnan(vdFeatureScores));
        vdAverageFeatureScore(dFeatureIndex) = mean(vdFeatureScores);
        
        vdFeatureRankings = m2dFeatureRankPerBootstrapPerFeature(:,dFeatureIndex);
        vdFeatureRankings = vdFeatureRankings(~isnan(vdFeatureRankings));
        vdAverageFeatureRanking(dFeatureIndex) = mean(vdFeatureRankings);
    end
% %     
% %     vsFeatureNames = [oRadiomicDataSet.GetFeatureNames() oClinicalDataSet.GetFeatureNames()];
% %     vsFeatureNames = vsFeatureNames(~isnan(vdAverageFeatureScore));
% %     
% %     vdAverageFeatureScore = vdAverageFeatureScore(~isnan(vdAverageFeatureScore));
% %     vdAverageFeatureRanking = vdAverageFeatureRanking(~isnan(vdAverageFeatureRanking));
    
    m2dFeatureImportancePerCutoffPerFeature(dCutoffIndex,:) = vdAverageFeatureScore;
end

m3dImageValues = ones(dNumCorrelationCoefficientCutoffs, dTotalNumFeatures, 3);

m2dNormalizedFeatureImportancePerCutoffPerFeature = zeros(size(m2dFeatureImportancePerCutoffPerFeature));

for dCutoffIndex=1:dNumCorrelationCoefficientCutoffs
    m3dImageValues(dCutoffIndex, m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:), 1) = 0.5; % grey
    m3dImageValues(dCutoffIndex, m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:), 2) = 0.5; % grey
    m3dImageValues(dCutoffIndex, m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:), 3) = 0.5; % grey
    
    % normalize averages such that for each cutoff the min is 0 and max is
    % 1
    vdNormalizedFeatureImportance = m2dFeatureImportancePerCutoffPerFeature(dCutoffIndex,:);
    vdNormalizedFeatureImportance = (vdNormalizedFeatureImportance - min(vdNormalizedFeatureImportance)) / (max(vdNormalizedFeatureImportance) - min(vdNormalizedFeatureImportance));

    m2dNormalizedFeatureImportancePerCutoffPerFeature(dCutoffIndex,:) = vdNormalizedFeatureImportance;
    
    vdNormalizedFeatureImportance_Green = ones(size(vdNormalizedFeatureImportance));
    vdNormalizedFeatureImportance_Green(vdNormalizedFeatureImportance > 0.5) = 2*(-vdNormalizedFeatureImportance(vdNormalizedFeatureImportance > 0.5)+1);
    vdNormalizedFeatureImportance_Green(vdNormalizedFeatureImportance < 0.5) = 2*vdNormalizedFeatureImportance(vdNormalizedFeatureImportance < 0.5);
        
    vdNormalizedFeatureImportance_Red = ones(size(vdNormalizedFeatureImportance));
    vdNormalizedFeatureImportance_Red(vdNormalizedFeatureImportance > 0.5) = 2*(-vdNormalizedFeatureImportance(vdNormalizedFeatureImportance > 0.5)+1);
    vdNormalizedFeatureImportance_Red(vdNormalizedFeatureImportance < 0.5) = 1;
    
    vdNormalizedFeatureImportance_Blue = ones(size(vdNormalizedFeatureImportance));
    vdNormalizedFeatureImportance_Blue(vdNormalizedFeatureImportance > 0.5) = 1;
    vdNormalizedFeatureImportance_Blue(vdNormalizedFeatureImportance < 0.5) = 2*vdNormalizedFeatureImportance(vdNormalizedFeatureImportance < 0.5);
    
    m3dImageValues(dCutoffIndex, ~m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:), 1) = vdNormalizedFeatureImportance_Red(~m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:)); % blue to red
    m3dImageValues(dCutoffIndex, ~m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:), 2) = vdNormalizedFeatureImportance_Green(~m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:)); % blue to red
    m3dImageValues(dCutoffIndex, ~m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:), 3) = vdNormalizedFeatureImportance_Blue(~m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoffIndex,:)); % blue to red
end


hFig = figure();

hFig.Units = 'centimeters';
hFig.Position = [1 1 20 28];

imshow(permute(m3dImageValues,[2,1,3]), 'InitialMagnification', 'fit');
hAxes = gca;
axis on;
hold on;

vsFeatureGroups = ["1st Order", "Shape & Size", "GLCM", "GLRLM", "GLDM", "GLSZM", "NGTDM"];
vsFeatureNames = ["firstorder", "shape", "glcm", "glrlm", "gldm", "glszm", "ngtdm"];

vsRadiomicDataSetFeatureNames = oRadiomicDataSet.GetFeatureNames();

yyaxis right

vdYTicks = [];

hAxes.YAxis(2).Direction = 'reverse';
hAxes.YAxis(2).Color = [0 0 0];

for dFeatureGroupIndex=1:length(vsFeatureGroups)
    vdMatches = find(contains(vsRadiomicDataSetFeatureNames , vsFeatureNames(dFeatureGroupIndex)));
    dFirstMatch = vdMatches(1);
    dLastMatch = vdMatches(end);
    
    plot([0.5 8.5],[dLastMatch + 0.5,dLastMatch + 0.5],'-k','LineWidth',2);
    
    vdYTicks = [vdYTicks, mean([dFirstMatch, dLastMatch])];
end

for dFeatureIndex=1:dTotalNumFeatures
    plot([0.5 8.5],[dFeatureIndex-0.5 dFeatureIndex-0.5],'-k','Color',[0.1 0.1 0.1],'LineWidth',0.1);
end

vdYTicks = [vdYTicks, mean([dNumRadiomicFeatures + 1, dTotalNumFeatures])];
vsFeatureGroups = [vsFeatureGroups, "Clinical"];

yticks(vdYTicks);
yticklabels(vsFeatureGroups);

ylabel('Feature Type')

ylim([0.5 dTotalNumFeatures+0.5])

hAxes.YAxis(2).TickLength = [0.0 0];

hAxes.YAxis(2).FontSize = 8;
hAxes.YAxis(2).Label.FontSize = 9;

yyaxis left


ylabel('Feature Look-up Number')

yticks(2:2:118);
yticklabels(2:2:118);

hAxes.YAxis(1).TickLength = [0.005 0];
hAxes.YAxis(1).TickDirection = 'both';

hAxes.YAxis(1).TickLabelInterpreter = 'none';
hAxes.YAxis(1).FontSize = 8;
hAxes.YAxis(1).Label.FontSize = 9;


xticks(1:8)
xticklabels(string(vdCorrelationCoefficientCutoffs))
hAxes.XAxis.TickLength = [0 0];

xlabel('Correlation Threshold')

hAxes.XAxis.FontSize = 8;
hAxes.XAxis.Label.FontSize = 9;

for dCutoff=1:dNumCorrelationCoefficientCutoffs
    text(dCutoff, -1.1, string(sum(~m2bRemovedByVolumeCorrelationFilterPerCutoffPerFeaures(dCutoff,:))), 'HorizontalAlignment', 'center', 'FontSize', 8);
end

text(4.5,-4, 'Number of Features Available', 'HorizontalAlignment', 'center', 'FontSize', 9);

for dX=1.5:1:7.5
    plot([dX,dX],[0.5 dTotalNumFeatures+0.5],'-','Color',[0.1 0.1 0.1],'LineWidth',0.1);
end

axis square;
pbaspect([1.5 4 1]);

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'Feature Importance Per Feature & Cutoff.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'Feature Importance Per Feature & Cutoff.fig'))

close(hFig);


% make color scale bar

hFig = figure();

hFig.Units = 'centimeters';
hFig.Position = [1 1 15 10];

imshow([0 1; 0.5 0.5],[], 'InitialMagnification', 'fit');
colormap(flipud([[linspace(0,1,100), linspace(1,1,100)]',[linspace(0,1,100), linspace(1,0,100)]',[linspace(1,1,100), linspace(1,0,100)]']));

hColorbar = colorbar();

hColorbar.Label.String = 'Normalized Feature Importance Score';
hColorbar.FontSize = 8;
hColorbar.Label.FontSize = 9;

saveas(hFig, fullfile(Experiment.GetResultsDirectory(), 'Feature Importance Legend.svg'));
savefig(hFig, fullfile(Experiment.GetResultsDirectory(), 'Feature Importance Legend.fig'))

close(hFig);


% analyze figure using rules

vsOriginalTopFeaturesThatWereRemovedAtLaterCutoff = string.empty();
vsOriginalTopFeaturesThatWereNotRemovedAtLaterCutoff = string.empty();

vsTopFeaturesUntilRemovalAtLaterCutoff = string.empty();
vsTopFeaturesFromOriginalToLaterCutoff = string.empty();

vsOriginalNonTopFeaturesThatBecameTopFeaturesAtLaterCutoff = string.empty();
vsOriginalNonTopFeaturesThatStayedNonTopFeaturesAtLaterCutoff = string.empty();
vsOriginalTopFeaturesThatBecameNonTopFeaturesAtLaterCutoff = string.empty();
vsOriginalTopFeaturesThatStayedTopFeaturesAtLaterCutoff = string.empty();

dOriginalCutoff = 1;

dCutoff0_25Index = find(vdCorrelationCoefficientCutoffs == 0.25);
dLaterCutoffIndex = dCutoff0_25Index;

dTopDefinition = 0.75; % feature importance >= than this number

vsFeatureNames = [oRadiomicDataSet.GetFeatureNames() oClinicalDataSet.GetFeatureNames()]';

for dFeatureIndex=1:dTotalNumFeatures
    sFeatureName = string(dFeatureIndex) + " - " + vsFeatureNames(dFeatureIndex);
    
    vdFeatureImportancePerCutoff = m2dNormalizedFeatureImportancePerCutoffPerFeature(:,dFeatureIndex);
    
    dRemovalIndex = find(isnan(vdFeatureImportancePerCutoff), 1);
    
    if isempty(dRemovalIndex)
        dRemovalIndex = inf;
    end
    
    bWasOriginalTop = vdFeatureImportancePerCutoff(dOriginalCutoff) >= dTopDefinition;
    
    bWasRemovedAtLaterCutoff = dRemovalIndex <= dLaterCutoffIndex;
    
    bWasTopAtLaterCutoff = vdFeatureImportancePerCutoff(dLaterCutoffIndex) >= dTopDefinition;
    
    vdFeatureImportancePerCutoffNotIncludingPastLaterCutoff = vdFeatureImportancePerCutoff(1:dLaterCutoffIndex);
    bWasTopForAllCutoffsBeforeRemovalNotIncludingPastLaterCutoff = all(vdFeatureImportancePerCutoffNotIncludingPastLaterCutoff(~isnan(vdFeatureImportancePerCutoffNotIncludingPastLaterCutoff)) >= dTopDefinition);
    
    if bWasOriginalTop && bWasRemovedAtLaterCutoff
        vsOriginalTopFeaturesThatWereRemovedAtLaterCutoff = [vsOriginalTopFeaturesThatWereRemovedAtLaterCutoff; sFeatureName];
    end
    
    if bWasOriginalTop && ~bWasRemovedAtLaterCutoff
        vsOriginalTopFeaturesThatWereNotRemovedAtLaterCutoff = [vsOriginalTopFeaturesThatWereNotRemovedAtLaterCutoff; sFeatureName];
    end
    
    if bWasRemovedAtLaterCutoff && bWasTopForAllCutoffsBeforeRemovalNotIncludingPastLaterCutoff
        vsTopFeaturesUntilRemovalAtLaterCutoff = [vsTopFeaturesUntilRemovalAtLaterCutoff; sFeatureName];
    end
    
    if ~bWasRemovedAtLaterCutoff && bWasTopForAllCutoffsBeforeRemovalNotIncludingPastLaterCutoff
        vsTopFeaturesFromOriginalToLaterCutoff = [vsTopFeaturesFromOriginalToLaterCutoff; sFeatureName];
    end
    
    if ~bWasRemovedAtLaterCutoff
        if ~bWasOriginalTop && bWasTopAtLaterCutoff
            vsOriginalNonTopFeaturesThatBecameTopFeaturesAtLaterCutoff = [vsOriginalNonTopFeaturesThatBecameTopFeaturesAtLaterCutoff; sFeatureName];
        end
        
        if ~bWasOriginalTop && ~bWasTopAtLaterCutoff
            vsOriginalNonTopFeaturesThatStayedNonTopFeaturesAtLaterCutoff = [vsOriginalNonTopFeaturesThatStayedNonTopFeaturesAtLaterCutoff; sFeatureName];
        end
        
        if bWasOriginalTop && ~bWasTopAtLaterCutoff
            vsOriginalTopFeaturesThatBecameNonTopFeaturesAtLaterCutoff = [vsOriginalTopFeaturesThatBecameNonTopFeaturesAtLaterCutoff; sFeatureName];
        end
        
        if bWasOriginalTop && bWasTopAtLaterCutoff
            vsOriginalTopFeaturesThatStayedTopFeaturesAtLaterCutoff = [vsOriginalTopFeaturesThatStayedTopFeaturesAtLaterCutoff; sFeatureName];
        end
    end
end

disp('vsOriginalTopFeaturesThatWereRemovedAtLaterCutoff');
disp(vsOriginalTopFeaturesThatWereRemovedAtLaterCutoff);

disp('vsOriginalTopFeaturesThatWereNotRemovedAtLaterCutoff');
disp(vsOriginalTopFeaturesThatWereNotRemovedAtLaterCutoff);

disp('vsTopFeaturesUntilRemovalAtLaterCutoff');
disp(vsTopFeaturesUntilRemovalAtLaterCutoff);

disp('vsTopFeaturesFromOriginalToLaterCutoff');
disp(vsTopFeaturesFromOriginalToLaterCutoff);

disp('vsOriginalNonTopFeaturesThatBecameTopFeaturesAtLaterCutoff');
disp(vsOriginalNonTopFeaturesThatBecameTopFeaturesAtLaterCutoff);

disp('vsOriginalNonTopFeaturesThatStayedNonTopFeaturesAtLaterCutoff');
disp(vsOriginalNonTopFeaturesThatStayedNonTopFeaturesAtLaterCutoff);

disp('vsOriginalTopFeaturesThatBecameNonTopFeaturesAtLaterCutoff');
disp(vsOriginalTopFeaturesThatBecameNonTopFeaturesAtLaterCutoff);

disp('vsOriginalTopFeaturesThatStayedTopFeaturesAtLaterCutoff');
disp(vsOriginalTopFeaturesThatStayedTopFeaturesAtLaterCutoff);

FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'Feature Analysis.mat'),...
    'm2dNormalizedFeatureImportancePerCutoffPerFeature', m2dNormalizedFeatureImportancePerCutoffPerFeature,...
    'vsFeatureNames', vsFeatureNames,...
    'vdCorrelationCoefficientCutoffs', vdCorrelationCoefficientCutoffs,...
    'vsOriginalTopFeaturesThatWereRemovedAtLaterCutoff', vsOriginalTopFeaturesThatWereRemovedAtLaterCutoff,...
    'vsOriginalTopFeaturesThatWereNotRemovedAtLaterCutoff', vsOriginalTopFeaturesThatWereNotRemovedAtLaterCutoff,...
    'vsOriginalNonTopFeaturesThatBecameTopFeaturesAtLaterCutoff', vsOriginalNonTopFeaturesThatBecameTopFeaturesAtLaterCutoff,...
    'vsOriginalNonTopFeaturesThatStayedNonTopFeaturesAtLaterCutoff', vsOriginalNonTopFeaturesThatStayedNonTopFeaturesAtLaterCutoff,...
    'vsOriginalTopFeaturesThatBecameNonTopFeaturesAtLaterCutoff', vsOriginalTopFeaturesThatBecameNonTopFeaturesAtLaterCutoff,...
    'vsOriginalTopFeaturesThatStayedTopFeaturesAtLaterCutoff', vsOriginalTopFeaturesThatStayedTopFeaturesAtLaterCutoff);

% save data to xslx

c1xHeader = [{"Feature #", "Feature Name"}, CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vdCorrelationCoefficientCutoffs')];

c2xData = [CellArrayUtils.MatrixOfObjects2CellArrayOfObjects((1:dTotalNumFeatures)'), CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vsFeatureNames), CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(m2dNormalizedFeatureImportancePerCutoffPerFeature')];

writecell([c1xHeader; c2xData], fullfile(Experiment.GetResultsDirectory(), 'Feature Analysis.xlsx'));

% summary table


vbHighlyImportantAtCutoff1PerFeature = m2dNormalizedFeatureImportancePerCutoffPerFeature(1,:) >= dTopDefinition;
vbHighlyImportantAtCutoff0_25PerFeature = m2dNormalizedFeatureImportancePerCutoffPerFeature(dCutoff0_25Index,:) >= dTopDefinition;

vbFeatureInAnalysis = vbHighlyImportantAtCutoff0_25PerFeature | vbHighlyImportantAtCutoff1PerFeature;

vdFeatureNumber = find(vbFeatureInAnalysis);
vsFeatureNamesForAnalysis = vsFeatureNames(vbFeatureInAnalysis);

vdFeatureRankAtCutoff1PerFeature = zeros(dTotalNumFeatures,1);
[~,vdSortIndices] = sort(m2dNormalizedFeatureImportancePerCutoffPerFeature(1,:), 'descend');

for dFeatureIndex=1:dTotalNumFeatures
    vdFeatureRankAtCutoff1PerFeature(dFeatureIndex) = find(vdSortIndices == dFeatureIndex);
end

vdFeatureRankAtCutoff1PerFeature = vdFeatureRankAtCutoff1PerFeature(vbFeatureInAnalysis);

vdFeatureRankAtCutoff0_25PerFeature = zeros(dTotalNumFeatures,1);
[~,vdSortIndices] = sort(m2dNormalizedFeatureImportancePerCutoffPerFeature(dCutoff0_25Index,:), 'descend');

for dFeatureIndex=1:dTotalNumFeatures
    vdFeatureRankAtCutoff0_25PerFeature(dFeatureIndex) = find(vdSortIndices == dFeatureIndex);
end

vdFeatureRankAtCutoff0_25PerFeature(isnan(m2dNormalizedFeatureImportancePerCutoffPerFeature(dCutoff0_25Index,:))) = nan;
vdFeatureRankAtCutoff0_25PerFeature = vdFeatureRankAtCutoff0_25PerFeature(vbFeatureInAnalysis);
vdFeatureRankAtCutoff0_25PerFeature = vdFeatureRankAtCutoff0_25PerFeature - sum(isnan(m2dNormalizedFeatureImportancePerCutoffPerFeature(dCutoff0_25Index,:)));

[~,vdCutoff1RankingSort] = sort(vdFeatureRankAtCutoff1PerFeature, 'ascend');

vdFeatureImportanceScoreAtCutoff1_sorted = m2dNormalizedFeatureImportancePerCutoffPerFeature(1,:);
vdFeatureImportanceScoreAtCutoff1_sorted = vdFeatureImportanceScoreAtCutoff1_sorted(vbFeatureInAnalysis);
vdFeatureImportanceScoreAtCutoff1_sorted = vdFeatureImportanceScoreAtCutoff1_sorted(vdCutoff1RankingSort);

vdFeatureImportanceScoreAtCutoff0_25_sorted = m2dNormalizedFeatureImportancePerCutoffPerFeature(dCutoff0_25Index,:);
vdFeatureImportanceScoreAtCutoff0_25_sorted = vdFeatureImportanceScoreAtCutoff0_25_sorted(vbFeatureInAnalysis);
vdFeatureImportanceScoreAtCutoff0_25_sorted = vdFeatureImportanceScoreAtCutoff0_25_sorted(vdCutoff1RankingSort);

c1xHeader = {"Feature #", "Feature Name", "Cutoff = 1 Score", "Cutoff = 1 Rank", "Cutoff = 0.25 Score", "Cutoff = 0.25 Rank"};
c2xData = [...
    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vdFeatureNumber(vdCutoff1RankingSort)'),...
    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vsFeatureNamesForAnalysis(vdCutoff1RankingSort)),...
    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(round(vdFeatureImportanceScoreAtCutoff1_sorted',3)),...
    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vdFeatureRankAtCutoff1PerFeature(vdCutoff1RankingSort)),...
    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(round(vdFeatureImportanceScoreAtCutoff0_25_sorted',3)),...
    CellArrayUtils.MatrixOfObjects2CellArrayOfObjects(vdFeatureRankAtCutoff0_25PerFeature(vdCutoff1RankingSort))];

writecell([c1xHeader; c2xData], fullfile(Experiment.GetResultsDirectory(), 'Top Feature Analysis Summary.xlsx'));