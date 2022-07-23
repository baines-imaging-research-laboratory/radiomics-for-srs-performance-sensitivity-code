oDB = ExperimentManager.Load('DB-001');
oSS = ExperimentManager.Load('SS-001');

sBaseIMGPP = 'IMGPP-000';
sIMGPP = 'IMGPP-102';

[vdPatientIds, c1vdBMNumbers] = oSS.GetPatientIdsAndBrainMetastasisNumbersPerPatient();

dNumPatients = length(vdPatientIds);

dCropBuffer_mm = 25;

for dPatientIndex=1:dNumPatients
    dPatientId = vdPatientIds(dPatientIndex);
    disp(dPatientId);
    
    oPatient = oDB.GetPatientByPrimaryId(dPatientId);
    
    oIV = oPatient.LoadImageVolume(sBaseIMGPP);
    oROIs = oIV.GetRegionsOfInterest();
    oIV.RemoveRegionsOfInterest();
    
    vdBMNumbers = c1vdBMNumbers{dPatientIndex};
    dNumBMs = length(vdBMNumbers);
    
    for dBMIndex=1:dNumBMs
        dBMNumber = vdBMNumbers(dBMIndex);
        
        dROINumber = oPatient.GetBrainMetastasis(dBMNumber).GetRegionOfInterestNumberInPreTreatmentImaging();
        
        [vdRowBounds, vdColBounds, vdSliceBounds] = oROIs.GetMinimalBoundsByRegionOfInterestNumber(dROINumber);
        
        vdVoxelDimensions_mm = oIV.GetImageVolumeGeometry().GetVoxelDimensions_mm();
        
        vdNumBufferVoxelsPerDim = ceil(dCropBuffer_mm ./ vdVoxelDimensions_mm);
        
        vdRowCropBounds = vdRowBounds + [-1 1] * vdNumBufferVoxelsPerDim(1);
        vdColCropBounds = vdColBounds + [-1 1] * vdNumBufferVoxelsPerDim(2);
        vdSliceCropBounds = vdSliceBounds + [-1 1] * vdNumBufferVoxelsPerDim(3);
        
        oIVCrop = copy(oIV);
        
        oIVCrop.Crop(vdRowCropBounds, vdColCropBounds, vdSliceCropBounds);
        oIVCrop.ForceApplyAllTransforms();
        
        oPatient.SaveImageVolume(oIVCrop, sIMGPP, 'SaveVarargin', {'-v7', '-nocompression'}, 'BrainMetastasisNumber', dBMNumber);
    end
end