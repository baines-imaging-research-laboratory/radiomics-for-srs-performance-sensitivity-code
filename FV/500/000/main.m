Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oDB = ExperimentManager.Load("DB-001");
oSS = ExperimentManager.Load("SS-001");

vsFeatureNames = [
    "MR Scanner"
    "MR Scan Orientation"
    "In-plane Voxel Size"
    "Slice Thickness"
    "In-plane Voxel Size (Rounded)"
    "Slice Thickness (Rounded)"];

vbIsCategorical = [
    true
    true
    false
    false
    false
    false];

[vdPatientIdsPerSample, vdBrainMetastasisNumberPerSample] = oSS.GetPatientIdAndBrainMetastasisNumberPerSample();

dNumSamples = length(vdPatientIdsPerSample);

m2dFeatures = zeros(dNumSamples, length(vsFeatureNames));

viGroupIds = zeros(dNumSamples,1,'uint8');
viSubGroupIds = zeros(dNumSamples,1,'uint8');

vsUserDefinedSampleStrings = strings(dNumSamples,1);



for dSampleIndex=1:dNumSamples
    disp(dSampleIndex);
    
    oPatient = oDB.GetPatientByPrimaryId(vdPatientIdsPerSample(dSampleIndex));
    
    oIV = ImageVolume.Load(fullfile(Experiment.GetDataPath('ImagingDatabaseRoot'), oPatient.GetPreTreatmentT1wCEMRIFilePath()));
    
    eMRScanner = MRScanner.getEnumFromImageMetadata(oIV.GetFileMetadata().Manufacturer, oIV.GetFileMetadata().ManufacturerModelName);
    
    [~,dMaxIndex] = max(abs(oIV.GetFileMetadata().ImageOrientationPatient(1:3)));
    eMRScanOrientation = MRScanOrientation.getEnumFromRowAxisUnitVectorMaxDimension(dMaxIndex);
    
    dInPlaneVoxelSize = oIV.GetFileMetadata().PixelSpacing(1);
    dSliceThickness = oIV.GetFileMetadata().SliceThickness;
    
    % set for feature values
    m2dFeatures(dSampleIndex,1) = eMRScanner.GetFeatureValuesCategoryNumber;
    m2dFeatures(dSampleIndex,2) = eMRScanOrientation.GetFeatureValuesCategoryNumber;
    m2dFeatures(dSampleIndex,3) = dInPlaneVoxelSize;
    m2dFeatures(dSampleIndex,4) = dSliceThickness;
    m2dFeatures(dSampleIndex,5) = round(dInPlaneVoxelSize,1);
    m2dFeatures(dSampleIndex,6) = round(dSliceThickness,1);
    
    viGroupIds(dSampleIndex) = vdPatientIdsPerSample(dSampleIndex);
    viSubGroupIds(dSampleIndex) = vdBrainMetastasisNumberPerSample(dSampleIndex);
    
    vsUserDefinedSampleStrings(dSampleIndex) = string(vdPatientIdsPerSample(dSampleIndex)) + "-" + string(vdBrainMetastasisNumberPerSample(dSampleIndex));
end


oFeatureValues = FeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames',...
    'FeatureIsCategorical', vbIsCategorical');

oFV = ExperimentFeatureValues("FV-500-000");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();