oDB = ExperimentManager.Load('DB-001');
oSS = ExperimentManager.Load('SS-001');

sBaseROIPP = 'IMGPP-000';
sROIPP = 'ROIPP-102';

[vdPatientIds, c1vdBMNumbers] = oSS.GetPatientIdsAndBrainMetastasisNumbersPerPatient();

dNumPatients = length(vdPatientIds);

dCropBuffer_mm = 25;

for dPatientIndex=1:dNumPatients
    dPatientId = vdPatientIds(dPatientIndex);
    disp(dPatientId);
    
    oPatient = oDB.GetPatientByPrimaryId(dPatientId);
    
    oROIs = oPatient.LoadRegionsOfInterest('ROIPP-000');
    
    vdBMNumbers = c1vdBMNumbers{dPatientIndex};
    dNumBMs = length(vdBMNumbers);
    
    for dBMIndex=1:dNumBMs
        dBMNumber = vdBMNumbers(dBMIndex);
        
        dROINumber = oPatient.GetBrainMetastasis(dBMNumber).GetRegionOfInterestNumberInPreTreatmentImaging();
        
        [vdRowBounds, vdColBounds, vdSliceBounds] = oROIs.GetMinimalBoundsByRegionOfInterestNumber(dROINumber);
        
        vdVoxelDimensions_mm = oROIs.GetImageVolumeGeometry().GetVoxelDimensions_mm();
        vdVolumeDimensions = oROIs.GetImageVolumeGeometry().GetVolumeDimensions();
        
        vdNumBufferVoxelsPerDim = ceil(dCropBuffer_mm ./ vdVoxelDimensions_mm);
        
        vdRowCropBounds = vdRowBounds + [-1 1] * vdNumBufferVoxelsPerDim(1);
        vdColCropBounds = vdColBounds + [-1 1] * vdNumBufferVoxelsPerDim(2);
        vdSliceCropBounds = vdSliceBounds + [-1 1] * vdNumBufferVoxelsPerDim(3);
        
        vdRowCropBounds(vdRowCropBounds < 1) = 1;
        vdRowCropBounds(vdRowCropBounds > vdVolumeDimensions(1)) = vdVolumeDimensions(1);
        
        vdColCropBounds(vdColCropBounds < 1) = 1;
        vdColCropBounds(vdColCropBounds > vdVolumeDimensions(2)) = vdVolumeDimensions(2);
        
        vdSliceCropBounds(vdSliceCropBounds < 1) = 1;
        vdSliceCropBounds(vdSliceCropBounds > vdVolumeDimensions(3)) = vdVolumeDimensions(3);
        
        oROIsCrop = copy(oROIs);
        
        oROIsCrop.Crop(vdRowCropBounds, vdColCropBounds, vdSliceCropBounds);
        oROIsCrop.ForceApplyAllTransforms();
        
        oPatient.SaveRegionsOfInterest(oROIsCrop, sROIPP, 'SaveVarargin', {'-v7', '-nocompression'}, 'BrainMetastasisNumber', dBMNumber);
    end
end