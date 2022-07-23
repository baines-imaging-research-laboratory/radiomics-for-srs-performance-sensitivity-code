
Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oMDL = ExperimentModel("MDL-100", @MATLABTreeBagger, "Parameters\Model Hyper Parameters.mat");

oMDL.Save();