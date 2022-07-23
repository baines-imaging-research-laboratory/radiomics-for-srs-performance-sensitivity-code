% Feature importance rankings
Experiment.StartNewSection('Analysis');

vsRadiomicFeatureValueCodes = ["FV-705-001","FV-705-002","FV-705-005","FV-705-006","FV-705-007","FV-705-008","FV-705-009"];
sLabelsCode = "LBL-201";

sVolumeFeatureName = "original_shape_VoxelVolume";

oRadiomicDataSet = ExperimentManager.GetLabelledFeatureValues(...
    vsRadiomicFeatureValueCodes,...
    sLabelsCode);

dVolumeFeatureIndex = find(oRadiomicDataSet.GetFeatureNames() == sVolumeFeatureName);

m2dFeatures = oRadiomicDataSet.GetFeatures();

m2dCorrelationMatrix = corr(m2dFeatures);

vdCorrelationCoefficientToVolume = m2dCorrelationMatrix(dVolumeFeatureIndex,:);

m2dFeatures(:,dVolumeFeatureIndex) = m2dFeatures(:,dVolumeFeatureIndex).^(1/3);

m2dCorrelationMatrix = corr(m2dFeatures);

vdCorrelationCoefficientToVolumeCubeRoot = m2dCorrelationMatrix(dVolumeFeatureIndex,:);


FileIOUtils.SaveMatFile(fullfile(Experiment.GetResultsDirectory(), 'FV-705-XXX Volume Correlation Coefficients.mat'),...
    'vdCorrelationCoefficientToVolume', vdCorrelationCoefficientToVolume,...
    'vdCorrelationCoefficientToVolumeCubeRoot', vdCorrelationCoefficientToVolumeCubeRoot);
