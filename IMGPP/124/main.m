oDB = ExperimentManager.Load('DB-001');
oSS = ExperimentManager.Load('SS-001');

sBaseIMGPP = 'IMGPP-103';

sIMGPP = 'IMGPP-124';

[vdPatientIds, c1vdBMNumbers] = oSS.GetPatientIdsAndBrainMetastasisNumbersPerPatient();

dNumPatients = length(vdPatientIds);

dNumberOfStDevs = 3;

sImageDBRoot = Experiment.GetDataPath('ImagingDatabaseRoot_v2');

for dPatientIndex=1:dNumPatients
    dPatientId = vdPatientIds(dPatientIndex);
    disp(dPatientId);
    
    oPatient = oDB.GetPatientByPrimaryId(dPatientId);
        
    vdBMNumbers = c1vdBMNumbers{dPatientIndex};
    dNumBMs = length(vdBMNumbers);
    
    sImageVolumePath = oPatient.GetPreTreatmentT1wCEMRIFilePath();
    [chFolderPath, chFilename] = FileIOUtils.SeparateFilePathAndFilename(sImageVolumePath);
    
    oEntireImage = ImageVolume.Load(fullfile(Experiment.GetDataPath('ImagingDatabaseRoot'), chFolderPath,  "IMGPP-011", strrep(chFilename, ' [Contoured]', '')));
    oBrainMask = LabelMapRegionsOfInterest.Load(fullfile(Experiment.GetDataPath('ImagingDatabaseRoot'), chFolderPath, "ROIPP-006", strrep(chFilename, ' [Contoured]', ' [Contours Only]')));
    
    m3dImageData = double(oEntireImage.GetImageData());
    m3bBrainMask = oBrainMask.GetMaskByRegionOfInterestNumber(1);
    
    dMean = mean(m3dImageData(m3bBrainMask));
    dStDev = std(m3dImageData(m3bBrainMask));
    
    for dBMIndex=1:dNumBMs
        dBMNumber = vdBMNumbers(dBMIndex);
        oBrainMetastasis = oPatient.GetBrainMetastasis(dBMNumber);
        dROINumber = oBrainMetastasis.GetRegionOfInterestNumberInPreTreatmentImaging();
        
        oIV = oPatient.LoadImageVolume(sBaseIMGPP, 'BrainMetastasisNumber', dBMNumber);
        
        oIV.NormalizeIntensityWithZScoreTransform(dNumberOfStDevs, 'CustomMean', dMean, 'CustomStandardDeviation', dStDev);
        oIV.ForceApplyAllTransforms();
                
        oPatient.SaveImageVolume(oIV, sIMGPP, 'SaveVarargin', {'-v7', '-nocompression'}, 'BrainMetastasisNumber', dBMNumber);
    end
end