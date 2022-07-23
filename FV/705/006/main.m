Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oSS = ExperimentManager.Load('SS-001');
[vdPatientIdPerSample, vdBrainMetastasisNumberPerSample] = oSS.GetPatientIdAndBrainMetastasisNumberPerSample();

sBaseFVValues = "FV-705-000";

sNewFVCode = "FV-705-006";
sFeatureNameMatchString = "original_glrlm";

[m2dBaseFeatureValuesPerSamplePerFeature, c1chBaseFeatureNames] = FileIOUtils.LoadMatFile(...
    fullfile(ExperimentManager.GetPathToExperimentAssetResultsDirectory(sBaseFVValues), '01 Experiment Assets', 'FeatureValuesAndNames.mat'),...
    'm2dFeatureValuesPerSamplePerFeature', 'c1chFeatureNames');
vsFeatureNames = string(c1chBaseFeatureNames);

vbSelectFeatures = contains(vsFeatureNames, sFeatureNameMatchString);
disp("Num Features: " + string(sum(vbSelectFeatures)));

oRecord = CustomFeatureExtractionRecord(sNewFVCode, "PyRadiomics features matching search string: " + sFeatureNameMatchString, m2dBaseFeatureValuesPerSamplePerFeature(:,vbSelectFeatures));

oFeatureValues = FeatureValuesByValue(...
    m2dBaseFeatureValuesPerSamplePerFeature(:,vbSelectFeatures),...
    uint8(vdPatientIdPerSample), uint8(vdBrainMetastasisNumberPerSample),...
    string(vdPatientIdPerSample) + "-" + string(vdBrainMetastasisNumberPerSample),...
    vsFeatureNames(vbSelectFeatures),...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues(sNewFVCode);

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();
