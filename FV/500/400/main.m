Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oIVH = ExperimentManager.Load("IVH-200");
oFV = ExperimentFeatureValues("FV-500-400");

voImageVolumeHandlers = oIVH.GetImageVolumeHandlers();

oParameters  = FeatureExtractionParameters('Parameters\FeatureExtractionParameters.xlsx');
    
voFeatures = F020001_Volume;

oFeatureValues = Feature.ExtractFeaturesForImageVolumeHandlers(...
    voImageVolumeHandlers, voFeatures,...
    oParameters, oFV.GetIdTag(),...
    2);

oFeatureValues = oFeatureValues.UnloadImageVolumeHandlersFromFeatureExtractionRecord(1, {oIVH.GetImageVolumeHandlerFilePaths()}, 'HandlersAlreadySaved', true);

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();