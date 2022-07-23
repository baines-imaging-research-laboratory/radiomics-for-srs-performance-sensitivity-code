Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oDB = ExperimentManager.Load("DB-001");
oSS = ExperimentManager.Load("SS-001");

vsFeatureNames = "Dummy Variable";

[vdPatientIdsPerSample, vdBrainMetastasisNumberPerSample] = oSS.GetPatientIdAndBrainMetastasisNumberPerSample();

dNumSamples = length(vdPatientIdsPerSample);

m2dFeatures = zeros(dNumSamples, 1);

viLabels = zeros(dNumSamples,1,'uint8');

viGroupIds = zeros(dNumSamples,1,'uint8');
viSubGroupIds = zeros(dNumSamples,1,'uint8');

vsUserDefinedSampleStrings = strings(dNumSamples,1);



for dSampleIndex=1:dNumSamples
    disp(dSampleIndex);
    
    oPatient = oDB.GetPatientByPrimaryId(vdPatientIdsPerSample(dSampleIndex));
    oBM = oPatient.GetBrainMetastasis(vdBrainMetastasisNumberPerSample(dSampleIndex));
    
    % set for feature values
    viLabels(dSampleIndex) = ~isempty(oBM.GetInFieldProgressionDate());        
     
    viGroupIds(dSampleIndex) = vdPatientIdsPerSample(dSampleIndex);
    viSubGroupIds(dSampleIndex) = vdBrainMetastasisNumberPerSample(dSampleIndex);
    
    vsUserDefinedSampleStrings(dSampleIndex) = string(vdPatientIdsPerSample(dSampleIndex)) + "-" + string(vdBrainMetastasisNumberPerSample(dSampleIndex));
end

oRecord = CustomFeatureExtractionRecord("LBL-201", "In-field Progression from DB-001", m2dFeatures);

oLabelledFeatureValues = LabelledFeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames',...
    viLabels, uint8(1), uint8(0),...
    'FeatureExtractionRecord', oRecord);

disp("Num +: " + string(sum(viLabels==1)));
disp("Num -: " + string(sum(viLabels==0)));

oLBL = Labels("LBL-201");

oLBL.SaveLabelledFeatureValuesAsMat(oLabelledFeatureValues);
oLBL.Save();