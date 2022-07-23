oDB = ExperimentManager.Load('DB-001');
oSS = ExperimentManager.Load('SS-001');

sBaseIMGPP = 'IMGPP-102';
sIMGPP = 'IMGPP-103';

[vdPatientIds, c1vdBMNumbers] = oSS.GetPatientIdsAndBrainMetastasisNumbersPerPatient();

dNumPatients = length(vdPatientIds);

for dPatientIndex=1:dNumPatients
    dPatientId = vdPatientIds(dPatientIndex);
    disp(dPatientId);
    
    oPatient = oDB.GetPatientByPrimaryId(dPatientId);
        
    vdBMNumbers = c1vdBMNumbers{dPatientIndex};
    dNumBMs = length(vdBMNumbers);
    
    for dBMIndex=1:dNumBMs
        dBMNumber = vdBMNumbers(dBMIndex);
        
        oIV = oPatient.LoadImageVolume(sBaseIMGPP, 'BrainMetastasisNumber', dBMNumber);
        
        chOriginalDataType = class(oIV.GetImageData());
        
        oIV.InterpolateToIsotropicVoxelResolution(0.5, 'linear', 0);
        oIV.CastImageDataToType(chOriginalDataType);
        oIV.ForceApplyAllTransforms();
        
        oPatient.SaveImageVolume(oIV, sIMGPP, 'SaveVarargin', {'-v7', '-nocompression'}, 'BrainMetastasisNumber', dBMNumber);
    end
end