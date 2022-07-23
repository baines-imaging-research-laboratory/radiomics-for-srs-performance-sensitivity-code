oDB = ExperimentManager.Load('DB-001');
oSS = ExperimentManager.Load('SS-001');

sBaseROIPP = 'ROIPP-102';
sROIPP = 'ROIPP-105';

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
        
        oROIs = oPatient.LoadRegionsOfInterest(sBaseROIPP, 'BrainMetastasisNumber', dBMNumber);
        
        oROIs.InterpolateToIsotropicVoxelResolution(0.5, 'interpolate3D', 'linear');        
        oROIs.ForceApplyAllTransforms();
        
        oPatient.SaveRegionsOfInterest(oROIs, sROIPP, 'SaveVarargin', {'-v7', '-nocompression'}, 'BrainMetastasisNumber', dBMNumber);
    end
end