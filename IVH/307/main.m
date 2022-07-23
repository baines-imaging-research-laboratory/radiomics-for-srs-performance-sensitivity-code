Experiment.StartNewSection('Experiment Assets');

oDB = ExperimentManager.Load('DB-001');
oSS = ExperimentManager.Load('SS-001');

sIMGPP = 'IMGPP-124';
sROIPP = 'ROIPP-105';

sIVH = 'IVH-307';

sImageSource = "Pre-Treatment T1wCE MRI - 0.5x0.5x0.5mm Interpolation - Whole Brain Z-Score Normalization (3 st. dev.)";

[vdPatientIdsPerSample, vdBMNumbersPerSample] = oSS.GetPatientIdAndBrainMetastasisNumberPerSample();

dNumSamples = length(vdPatientIdsPerSample);

vsHandlerFilePaths = strings(dNumSamples,1);

chHandlerRoot = Experiment.GetDataPath('ImageVolumeHandlersRoot');

mkdir(chHandlerRoot, sIVH);

for dSampleIndex=1:dNumSamples
    dPatientId = vdPatientIdsPerSample(dSampleIndex);
    dBMNumber = vdBMNumbersPerSample(dSampleIndex);
    
    disp(dSampleIndex);
    
    oPatient = oDB.GetPatientByPrimaryId(dPatientId);
    oBrainMetastasis = oPatient.GetBrainMetastasis(dBMNumber);
    dROINumber = oBrainMetastasis.GetRegionOfInterestNumberInPreTreatmentImaging();
        
    oIV = oPatient.LoadImageVolume(sIMGPP, 'BrainMetastasisNumber', dBMNumber);
    oROIs = oPatient.LoadRegionsOfInterest(sROIPP, 'BrainMetastasisNumber', dBMNumber);
    oIV.SetRegionsOfInterest(oROIs);
    
    oHandler = FeatureExtractionImageVolumeHandler(...
         oIV, sImageSource,...
         'SampleOrder', dROINumber,...
         'GroupId', uint8(dPatientId),...
         'SubGroupId', uint8(dBMNumber),...
         'UserDefinedSampleStrings', string(dPatientId) + "-" + string(dBMNumber),...
         'ImageInterpretation', '3D');
     
     sFilePath = fullfile(chHandlerRoot, sIVH, "Pt. " + string(StringUtils.num2str_PadWithZeros(dPatientId, 3)) + " BM " + string(dBMNumber) + ".mat");
     
     FileIOUtils.SaveMatFile(sFilePath, 'oHandler', oHandler, '-v7', '-nocompression');
     
     vsHandlerFilePaths(dSampleIndex) = sFilePath;
end

oIVH = ImageVolumeHandlers(sIVH, vsHandlerFilePaths);
oIVH.Save();