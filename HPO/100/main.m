
Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oHPO = ExperimentHyperParameterOptimizer("HPO-100", @MATLABBayesianHyperParameterOptimizer, "Parameters\HPO Parameters.mat");

oHPO.Save();