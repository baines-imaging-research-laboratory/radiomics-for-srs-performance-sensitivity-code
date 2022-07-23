Experiment.StartNewSection(ExperimentManager.chExperimentAssetsSectionName);

oDB = ExperimentManager.Load("DB-001");
oSS = ExperimentManager.Load("SS-001");

vsFeatureNames = [
    "Gender"
    "Age"
    "Primary Cancer Active"
    "Primary Cancer Site"
    "Primary Cancer Histology"
    "Systemic Metastases Status"
    "Systemic Therapy Status"
    "Steroid Status"
    "WHO Score"
    "GTV Volume"
    "Location"
    "Dose And Fractionation"];

dNumFeatures = length(vsFeatureNames);

vbIsCategorical = false(1, dNumFeatures);

c1c1vdCategoryGroups = {
    {},...
    {},...
    {},...
    {
    PrimarySite.lung,...
    PrimarySite.breast,...
    PrimarySite.renal,...
    PrimarySite.colorectal,...
    PrimarySite.melanoma,...
    [PrimarySite.oesophageal, PrimarySite.thyroid, PrimarySite.other]},...
    {
    HistologyResult.adenocarcinoma,...
    HistologyResult.nonSmallCellLungCarcinoma,...
    HistologyResult.melanoma,...
    HistologyResult.squamousCarcinoma,...
    HistologyResult.renal,...
    [HistologyResult.urothelialCarcinoma, HistologyResult.papillary, HistologyResult.smallCell, HistologyResult.sarcoma]},...
    {},...
    {},...
    {},...
    {},...
    {},...
    {},...
    {}...
    };

[vdPatientIdsPerSample, vdBrainMetastasisNumberPerSample] = oSS.GetPatientIdAndBrainMetastasisNumberPerSample();

dNumSamples = length(vdPatientIdsPerSample);

m2dFeatures = zeros(dNumSamples, length(vsFeatureNames));

viGroupIds = zeros(dNumSamples,1,'uint8');
viSubGroupIds = zeros(dNumSamples,1,'uint8');

vsUserDefinedSampleStrings = strings(dNumSamples,1);



for dSampleIndex=1:dNumSamples
    disp(dSampleIndex);
    
    oPatient = oDB.GetPatientByPrimaryId(vdPatientIdsPerSample(dSampleIndex));
    oBM = oPatient.GetBrainMetastasis(vdBrainMetastasisNumberPerSample(dSampleIndex));
    
    % set for feature values
    for dFeatureIndex=1:dNumFeatures
        if dFeatureIndex <= 9
            [m2dFeatures(dSampleIndex, dFeatureIndex), vbIsCategorical(dFeatureIndex)] = oPatient.GetFeatureValue(vsFeatureNames(dFeatureIndex), c1c1vdCategoryGroups{dFeatureIndex});        
        else
            [m2dFeatures(dSampleIndex, dFeatureIndex), vbIsCategorical(dFeatureIndex)] = oBM.GetFeatureValue(vsFeatureNames(dFeatureIndex), c1c1vdCategoryGroups{dFeatureIndex});        
        end
    end

    viGroupIds(dSampleIndex) = vdPatientIdsPerSample(dSampleIndex);
    viSubGroupIds(dSampleIndex) = vdBrainMetastasisNumberPerSample(dSampleIndex);
    
    vsUserDefinedSampleStrings(dSampleIndex) = string(vdPatientIdsPerSample(dSampleIndex)) + "-" + string(vdBrainMetastasisNumberPerSample(dSampleIndex));
end

oRecord = CustomFeatureExtractionRecord("FV-500-100", "Clinical features from DB-001 with categorical groupings for primary cancer site & histology matching Rodrigues 2013", m2dFeatures);

oFeatureValues = FeatureValuesByValue(...
    m2dFeatures, viGroupIds, viSubGroupIds, vsUserDefinedSampleStrings, vsFeatureNames',...
    'FeatureIsCategorical', vbIsCategorical',...
    'FeatureExtractionRecord', oRecord);

oFV = ExperimentFeatureValues("FV-500-100");

oFV.SaveFeatureValuesAsMat(oFeatureValues);
oFV.Save();