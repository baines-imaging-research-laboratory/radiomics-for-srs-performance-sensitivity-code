Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oIVH = ExperimentManager.Load("IVH-307");
voIVHs = oIVH.GetImageVolumeHandlers();

dNumSamples = length(voIVHs);

c1chImageVolumePathPerSample = cell(dNumSamples,1);
c1chRegionsOfInterestPathPerSample = cell(dNumSamples,1);
vdRegionOfInterestNumberPerSample = zeros(dNumSamples,1);

for dSampleIndex=1:dNumSamples
    oImageVolume = voIVHs(dSampleIndex).GetRASImageVolume();
    
    c1chImageVolumePathPerSample{dSampleIndex} = oImageVolume.GetMatFilePath();
    c1chRegionsOfInterestPathPerSample{dSampleIndex} = oImageVolume.GetRegionsOfInterest().GetMatFilePath();
    vdRegionOfInterestNumberPerSample(dSampleIndex) = voIVHs(dSampleIndex).GetRegionsOfInterestNumbersInOrderOfExtraction();
end

chManifestPath = fullfile(Experiment.GetResultsDirectory(), 'ImageAndRegionsOfInterestManifest.mat');

FileIOUtils.SaveMatFile(chManifestPath,...
    'c1chImageVolumePathPerSample', c1chImageVolumePathPerSample,...
    'c1chRegionsOfInterestPathPerSample', c1chRegionsOfInterestPathPerSample,...
    'vdRegionOfInterestNumberPerSample', vdRegionOfInterestNumberPerSample);

[chAnacondaInstallPath, chAnacondaEnvironmentName] = Experiment.GetAnacondaInstallPathAndEnvironmentNameSettings();

PythonUtils.ExecutePythonScriptInAnacondaEnvironment(...
    FileIOUtils.GetAbsolutePath('ComputePyRadiomicsFeaturesForImageVolumes.py'),...
    {...
    chManifestPath,...
    fullfile(Experiment.GetResultsDirectory(), 'FeatureValuesAndNames.mat')
    },...
    chAnacondaInstallPath, chAnacondaEnvironmentName);