
Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oObjFn = OutOfBagSampleValidationObjectiveFunction(...
    'Parameters\Error Metric Parameters.mat',...
    'Parameters\Objective Function Parameters.mat');

oOFN = ExperimentObjectiveFunction("OFN-100", oObjFn);

oOFN.Save();