classdef StudyDatabase_v2 < handle
    %StudyDatabase_v2
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voPatients (1,:) Patient = Patient.empty(1,0)
    end
    
    properties (Constant = true, GetAccess = private)
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = StudyDatabase_v2(voPatients)
            arguments
                voPatients (1,:) Patient
            end
            
            % validate
            dNumPatients = length(voPatients);
            vdPatientIds = zeros(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                vdPatientIds(dPatientIndex) = voPatients(dPatientIndex).GetPrimaryId();
            end
            
            if length(vdPatientIds) ~= length(unique(vdPatientIds))
                error(...
                    'StudyDatabase_v2:Constructor:InvalidPatientIds',...
                    'No primary patient IDs can be repeated.');
            end
            
            % set
            obj.voPatients = voPatients;
        end
        
        function Update(obj)
        end
                
        
        % >>>>>>>>>>>>>>>>>>>>> PATIENT GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<
          
        
        function voPatients = GetAllPatients(obj)
            voPatients = obj.voPatients;
        end
        
        function voPatients = GetPatientsByPrimaryIds(obj, vdPrimaryIds)
            dNumIds = length(vdPrimaryIds);
            
            % pre-allocate
            voPatients = repmat(obj.voPatients(1), dNumIds, 1);
            
            % find patients
            for dIdIndex=1:dNumIds
                oFoundPatient = obj.GetPatientByPrimaryId(vdPrimaryIds(dIdIndex));
                
                if isempty(oFoundPatient)
                    error(...
                        'StudyDatabase_v2:GetPatientsByPrimaryIds:IdNotFound',...
                        ['No Patient with the Primary ID: ', num2str(vdPrimaryIds(dIdIndex)), ' was found in the database.']);
                else
                    voPatients(dIdIndex) = oFoundPatient;
                end
            end
            
        end
        
        function oFoundPatient = GetPatientByPrimaryId(obj, dPrimaryId)
            oFoundPatient = Patient.empty;
            
            for dPatientIndex=1:length(obj.voPatients)
                if obj.voPatients(dPatientIndex).GetPrimaryId() == dPrimaryId
                    oFoundPatient = obj.voPatients(dPatientIndex);
                    break;
                end
            end
        end
        
        function voImageVolumeHandlers = CreateImageVolumeHandlers(obj, vdPatientIdsPerSample, vdBMNumberPerSample)
            dNumPatients = length(unique(vdPatientIdsPerSample));
            
            c1oHandlers = cell(dNumPatients,1);
            dPatientIdIndex = 1;
                        
            for dHandlerIndex=1:dNumPatients
                dPatientId = vdPatientIdsPerSample(dPatientIdIndex);
                vdSampleIndices = find(vdPatientIdsPerSample == dPatientId);
                
                if any(vdSampleIndices' ~= min(vdSampleIndices):min(vdSampleIndices) + length(vdSampleIndices) - 1)
                    error('Patient IDs need to be grouped together');
                end
                
                oPatient = obj.GetPatientByPrimaryId(dPatientId);
                
                dNumBMs = length(vdSampleIndices);
                vdBMNumbersForPatient = vdBMNumberPerSample(vdSampleIndices);
                
                vdROINumbers = zeros(dNumBMs,1);
                
                for dBMIndex=1:dNumBMs
                    vdROINumbers(dBMIndex) = oPatient.GetBrainMetastasis(vdBMNumbersForPatient(dBMIndex)).GetRegionOfInterestNumberInPreTreatmentImaging();
                end
                
                c1oHandlers{dHandlerIndex} = FeatureExtractionImageVolumeHandler(...
                    oPatient.GetPreTreatmentT1wCEMRIImageVolume,...
                    "Pre-Treatment T1wCE MRI",...
                    "SampleOrder", vdROINumbers,...
                    'GroupIds', uint8(dPatientId),...
                    'SubGroupIds', uint8(vdBMNumbersForPatient),...
                    'UserDefinedSampleStrings', "Pt. " + string(num2str(dPatientId)) + " - BM " + string(num2str(vdBMNumbersForPatient)),...
                    "ImageInterpretation", "3D");
                                
                dPatientIdIndex = max(vdSampleIndices) + 1;
            end
            
            voImageVolumeHandlers = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oHandlers);
        end
        
        function oFeatureValues = CreateFeatureValues(obj, vdPatientIdsPerSample, vdBMNumbersPerSample, vsFeatureNames, c1vePrimaryCancerSiteGroups, c1vePrimaryCancerHistologyGroups, c1veSystemicTherapyGroups, c1veSteroidStatusGroups, c1veWHOScoreGroups, c1veScoredMRIAppearanceGroups, c1veDoseAndFractionationGroups)
            arguments
                obj (1,1) StudyDatabase_v2
                vdPatientIdsPerSample
                vdBMNumbersPerSample
                vsFeatureNames
                c1vePrimaryCancerSiteGroups = {}
                c1vePrimaryCancerHistologyGroups = {}
                c1veSystemicTherapyGroups = {}
                c1veSteroidStatusGroups = {}
                c1veWHOScoreGroups = {}
                c1veScoredMRIAppearanceGroups = {}
                c1veDoseAndFractionationGroups = {}
            end
            
            dNumFeatures = length(vsFeatureNames);            
            dNumSamples = length(vdPatientIdsPerSample);
            
            m2dFeatureValues = zeros(dNumSamples, dNumFeatures);
            vbFeatureIsCategorical = zeros(1, dNumFeatures);
                        
            for dSampleIndex=1:dNumSamples
                dPatientId = vdPatientIdsPerSample(dSampleIndex);
                dBMNumber = vdBMNumbersPerSample(dSampleIndex);
                
                oPatient = obj.GetPatientByPrimaryId(dPatientId);
                oBM = oPatient.GetBrainMetastasis(dBMNumber);
                
                for dFeatureIndex=1:dNumFeatures
                    switch vsFeatureNames(dFeatureIndex)
                        case "Primary Cancer Site"
                            c1veCategoryGroups = c1vePrimaryCancerSiteGroups;
                        case "Primary Cancer Histology"
                            c1veCategoryGroups = c1vePrimaryCancerHistologyGroups;
                        case "Systemic Therapy Status"
                            c1veCategoryGroups = c1veSystemicTherapyGroups;
                        case "Steroid Status"
                            c1veCategoryGroups = c1veSteroidStatusGroups;
                        case "WHO Score"
                            c1veCategoryGroups = c1veWHOScoreGroups;
                        case "Scored MRI Appearance"
                            c1veCategoryGroups = c1veScoredMRIAppearanceGroups;
                        case "Dose And Fractionation"
                            c1veCategoryGroups = c1veDoseAndFractionationGroups;
                        otherwise
                            c1veCategoryGroups = {};
                    end
                    
                    [dFeatureValue, bFeatureIsCategorical] = oPatient.GetFeatureValue(vsFeatureNames(dFeatureIndex), c1veCategoryGroups);
                    
                    if isempty(dFeatureValue)
                        [dFeatureValue, bFeatureIsCategorical] = oBM.GetFeatureValue(vsFeatureNames(dFeatureIndex), c1veCategoryGroups);
                    end
                    
                    if isempty(dFeatureValue)
                        error(...
                            'StudyDatabase_v2:CreateFeatureValues:NoFeatureMatch',...
                            'The feature name was not found.');
                    end
                    
                    m2dFeatureValues(dSampleIndex, dFeatureIndex) = dFeatureValue;
                    vbFeatureIsCategorical(dFeatureIndex) = bFeatureIsCategorical;
                end
            end
            
            
            vsUserDefinedSampleStrings = "Pt. " + string(num2str(vdPatientIdsPerSample)) + " - BM " + string(num2str(vdBMNumbersPerSample));
            
            oFeatureExtractionRecord = CustomFeatureExtractionRecord("Clinical Data", "Clinical data points from VUMC", m2dFeatureValues);
            
            oFeatureValues = FeatureValuesByValue(...
                m2dFeatureValues, uint8(vdPatientIdsPerSample), uint8(vdBMNumbersPerSample), vsUserDefinedSampleStrings, vsFeatureNames',...
                'FeatureExtractionRecord', oFeatureExtractionRecord,...
                'FeatureIsCategorical', vbFeatureIsCategorical);
        end
        
        function vbLabels = CreateLabels(obj, vdPatientIdsPerSample, vdBMNumbersPerSample, sEndpointName)
            dNumSamples = length(vdPatientIdsPerSample);
            
            vbLabels = false(dNumSamples,1);
            
            for dSampleIndex=1:dNumSamples
                dPatientId = vdPatientIdsPerSample(dSampleIndex);
                dBMNumber = vdBMNumbersPerSample(dSampleIndex);
                
                oPatient = obj.GetPatientByPrimaryId(dPatientId);
                oBM = oPatient.GetBrainMetastasis(dBMNumber);
                
                switch sEndpointName
                    case "In-field Progression Occurrence"
                        vbLabels(dSampleIndex) = ~isempty(oBM.GetInFieldProgressionDate());  
                    case "Out-of-field Progression Occurrence"
                        vbLabels(dSampleIndex) = ~isempty(oPatient.GetOutOfFieldProgressionDate());
                    case "Overall Survival >= 3 months"
                        vbLabels(dSampleIndex) = oPatient.GetSurvivalTime_months() >= 3;
                    case "Overall Survival >= 6 months"
                        vbLabels(dSampleIndex) = oPatient.GetSurvivalTime_months() >= 6;
                    case "Overall Survival >= 9 months"
                        vbLabels(dSampleIndex) = oPatient.GetSurvivalTime_months() >= 9;
                    case "Overall Survival >= 12 months"
                        vbLabels(dSampleIndex) = oPatient.GetSurvivalTime_months() >= 12;
                    otherwise
                        error(...
                            'StudyDatabase_v2:CreateLabels:UnknownEndpoint',...
                            'The provided endpoint name is unknown.');
                end
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                
        function dNumPatients = GetNumberOfPatients(obj)
            dNumPatients = length(obj.voPatients);
        end
    end
    
    methods (Access = public, Static)
        
        
        function obj = Load(sPath)
            arguments
                sPath (1,1) string
            end
            
            sPath = strrep(sPath, '.mat', '.xlsx');
            
            obj = StudyDatabase_v2.LoadFromStudyDatabaseSpreadsheet(sPath);
        end
        
        function obj = LoadFromStudyDatabaseSpreadsheet(chLoadPath)
            arguments
                chLoadPath (1,:) char
            end
            
            if Experiment.IsRunning() && Experiment.IsInDebugMode()
                global CachedDatabaseForDebug;
                global CachedDatabaseForDebugLoadPath;
                
                if ~isempty(CachedDatabaseForDebug) && strcmp(chLoadPath, CachedDatabaseForDebugLoadPath)
                    obj = CachedDatabaseForDebug;
                    
                    warning(...
                        'StudyDatabase_v2:Load:UsingCachedDatabase',...
                        'Since an Experiment was running in debug mode, instead of loading the database, a cached version was found and used.');
                else
                    obj = StudyDatabase_v2(Patient.LoadPatientsFromStudyDatabaseSpreadsheet(chLoadPath));
                    
                    CachedDatabaseForDebug = obj;
                    CachedDatabaseForDebugLoadPath = chLoadPath;
                end
            else
                obj = StudyDatabase_v2(Patient.LoadPatientsFromStudyDatabaseSpreadsheet(chLoadPath));
            end
        end
        
        function [vdPatientIdsPerSample, vdBMNumbersPerSample] = LoadSampleSelectionFromSpreadsheet(sSampleSelectionFilePath)
            c2xRawData = readcell(sSampleSelectionFilePath, 'Sheet', 'Sample Selection');
            
            c2xData = c2xRawData(3:end,:);
            
            dNumSamples = size(c2xData,1);
            
            vdPatientIdsPerSample = zeros(dNumSamples,1);
            vdBMNumbersPerSample = zeros(dNumSamples,1);
            vbIncludeSample = true(dNumSamples,1);
            
            for dSampleIndex=1:dNumSamples
                vdPatientIdsPerSample(dSampleIndex) = c2xData{dSampleIndex,1};
                vdBMNumbersPerSample(dSampleIndex) = c2xData{dSampleIndex,3};
                
                if strcmp(c2xData{dSampleIndex,4}, "X")
                    vbIncludeSample(dSampleIndex) = false;
                end
            end
            
            vdPatientIdsPerSample = vdPatientIdsPerSample(vbIncludeSample);
            vdBMNumbersPerSample = vdBMNumbersPerSample(vbIncludeSample);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static)
                
        function vdPrimaryIds = GetAllPrimaryIds(obj)
            dNumPatients = length(obj.voPatients);
            
            vdPrimaryIds = zeros(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                vdPrimaryIds(dPatientIndex) = obj.voPatients{dPatientIndex}.GetPrimaryId();
            end
        end 
    end
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)        
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end

