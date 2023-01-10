% Feature importance rankings
Experiment.StartNewSection('Analysis');

vsRadiomicFeatureValueCodes = ["FV-705-001","FV-705-002","FV-705-005","FV-705-006","FV-705-007","FV-705-008","FV-705-009"];
sLabelsCode = "LBL-201";

sVolumeFeatureName = "original_shape_VoxelVolume";

oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);
dNumRadiomicFeatures = oRadiomicDataSet.GetNumberOfFeatures();

dVolumeFeatureIndex = find(oRadiomicDataSet.GetFeatureNames() == sVolumeFeatureName);
oVolume = oRadiomicDataSet(:, dVolumeFeatureIndex);

vdVolume = oVolume.GetFeatures();
vdVolumeCubeRoot = vdVolume.^(1/3);

% Radiomic Features:
m2dFeatures = oRadiomicDataSet.GetFeatures();

[m2dCorrelationMatrix, m2dPValueMatrix] = corr(m2dFeatures);

vdCorrelationCoefficientToVolume = m2dCorrelationMatrix(dVolumeFeatureIndex,:);
vdPValuePerRadiomicFeatureForVolume = m2dPValueMatrix(dVolumeFeatureIndex,:);

m2dFeatures(:,dVolumeFeatureIndex) = m2dFeatures(:,dVolumeFeatureIndex).^(1/3);

[m2dCorrelationMatrix, m2dPValueMatrix] = corr(m2dFeatures);

vdCorrelationCoefficientToVolumeCubeRoot = m2dCorrelationMatrix(dVolumeFeatureIndex,:);
vdPValuePerRadiomicFeatureForVolumeCubeRoot = m2dPValueMatrix(dVolumeFeatureIndex,:);


% Clinical Features:
oClinicalDataSet = ExperimentManager.GetLabelledFeatureValues(...
    "FV-500-104",...
    sLabelsCode);

vdPValuePerClinicalFeature = zeros(1, oClinicalDataSet.GetNumberOfFeatures());

% Gender
disp("Gender");
oSex = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Gender");
vdSex = oSex.GetFeatures();

dPVal = ranksum(vdVolume(vdSex == 0), vdVolume(vdSex == 1));
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Gender") = dPVal;

disp(dPVal);

% Age
disp("Age")
oAge = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Age");
vdAge = oAge.GetFeatures();

[m2dCorrMatrix, m2dPValueMatrixVolume] = corr([vdAge vdVolume]);
dVolumeCorrCoeff = abs(m2dCorrMatrix(1,2));
    
disp("Volume: " + string(dVolumeCorrCoeff));

[m2dCorrMatrix, m2dPValueMatrixVolumeCubeRoot] = corr([vdAge vdVolumeCubeRoot]);
dVolumeCutRootCorrCoeff = abs(m2dCorrMatrix(1,2));

disp("Volume Cube Root: " + string(dVolumeCutRootCorrCoeff));
disp(" ");

vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Age") = min(m2dPValueMatrixVolume(1,2), m2dPValueMatrixVolumeCubeRoot(1,2));

% Primary Cancer Active
disp("Primary Cancer Active");

oPrimaryCancerActive = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Primary Cancer Active");
vdPrimaryCancerActive = oPrimaryCancerActive.GetFeatures();

dPVal = ranksum(vdVolume(vdPrimaryCancerActive == 0), vdVolume(vdPrimaryCancerActive == 1));
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Primary Cancer Active") = dPVal;

disp(dPVal);

% Primary Cancer Site
disp("Primary Cancer Site");
oPrimaryCancerSite = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Primary Cancer Site");
vdPrimaryCancerSite = oPrimaryCancerSite.GetFeatures();

dPVal = kruskalwallis(vdVolume, vdPrimaryCancerSite);
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Primary Cancer Site") = dPVal;
    
disp(dPVal);

% Primary Cancer Histology
disp("Primary Cancer Histology");
oPrimaryCancerHistology = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Primary Cancer Histology");
vdPrimaryCancerHistology = oPrimaryCancerHistology.GetFeatures();

dPVal = kruskalwallis(vdVolume, vdPrimaryCancerHistology);
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Primary Cancer Histology") = dPVal;

disp(dPVal);

% Systemic Metastases Status
disp("Systemic Metastases Status");
oSystemicMetastasesStatus = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Systemic Metastases Status");
vdSystemicMetastasesStatus = oSystemicMetastasesStatus.GetFeatures();

dPVal = ranksum(vdVolume(vdSystemicMetastasesStatus == 0), vdVolume(vdSystemicMetastasesStatus == 1));
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Systemic Metastases Status") = dPVal;

disp(dPVal);

% Systemic Therapy Status
disp("Systemic Therapy Status");
oSystemicTherapyStatus = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Systemic Therapy Status");
vdSystemicTherapyStatus = oSystemicTherapyStatus.GetFeatures();

dPVal = kruskalwallis(vdVolume, vdSystemicTherapyStatus);
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Systemic Therapy Status") = dPVal;

disp(dPVal);

% Steroid Status
disp("Steroid Status");
oSteroidStatus = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Steroid Status");
vdSteroidStatus = oSteroidStatus.GetFeatures();

dPVal = kruskalwallis(vdVolume, vdSteroidStatus);
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Steroid Status") = dPVal;

disp(dPVal);

% WHO Score
disp("WHO Score");
oWHOScore = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "WHO Score");
vdWHOScore = oWHOScore.GetFeatures();

dPVal = kruskalwallis(vdVolume, vdWHOScore);
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "WHO Score") = dPVal;

disp(dPVal);

% Location
disp("Location");
oLocation = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Location");
vdLocation = oLocation.GetFeatures();

dPVal = ranksum(vdVolume(vdLocation == 0), vdVolume(vdLocation == 1));
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Location") = dPVal;

disp(dPVal);

% Dose And Fractionation
disp("Dose And Fractionation");
oDoseFx = oClinicalDataSet(:, oClinicalDataSet.GetFeatureNames() == "Dose And Fractionation");
vdDoseFx = oDoseFx.GetFeatures();

dPVal = kruskalwallis(vdVolume, vdDoseFx);
vdPValuePerClinicalFeature(oClinicalDataSet.GetFeatureNames() == "Dose And Fractionation") = dPVal;

disp(dPVal);


% Save p-values and correlation coefficient
FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'P-Values And Correlation Coefficients Per Feature.mat'), ...
    'vdCorrelationCoefficientToVolume', vdCorrelationCoefficientToVolume,...
    'vdPValuePerRadiomicFeatureForVolume', vdPValuePerRadiomicFeatureForVolume,...
    'vdCorrectedPValuePerRadiomicFeatureForVolume', vdPValuePerRadiomicFeatureForVolume*(oRadiomicDataSet.GetNumberOfFeatures() + oClinicalDataSet.GetNumberOfFeatures() - 1),... % Bonferroni correction (exclude primary cancer site feature in count)
    ...
    'vdCorrelationCoefficientToVolumeCubeRoot', vdCorrelationCoefficientToVolumeCubeRoot,...
    'vdPValuePerRadiomicFeatureForVolumeCubeRoot', vdPValuePerRadiomicFeatureForVolumeCubeRoot,...
    'vdCorrectedPValuePerRadiomicFeatureForVolumeCubeRoot', vdPValuePerRadiomicFeatureForVolumeCubeRoot*(oRadiomicDataSet.GetNumberOfFeatures() + oClinicalDataSet.GetNumberOfFeatures() - 1),... % Bonferroni correction (exclude primary cancer site feature in count)
    ...
    'vdPValuePerClinicalFeature', vdPValuePerClinicalFeature,...
    'vdCorrectedPValuePerClinicalFeature', vdPValuePerClinicalFeature*(oRadiomicDataSet.GetNumberOfFeatures() + oClinicalDataSet.GetNumberOfFeatures() - 1)); % Bonferroni correction (exclude primary cancer site feature in count)
