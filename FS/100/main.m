Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

sFilePath = "Parameters\Feature Selector Parameters.mat";

oFS = ExperimentFeatureSelector("FS-100", @CorrelationFilterFeatureSelector, sFilePath);

oFS.Save();