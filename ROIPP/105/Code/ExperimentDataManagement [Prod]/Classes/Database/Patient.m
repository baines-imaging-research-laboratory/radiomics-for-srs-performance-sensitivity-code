classdef Patient < handle
    %Patient
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dPrimaryId double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger}
        dSecondaryId double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger} % set from where data is coming from
        
        eGender Gender {ValidationUtils.MustBeEmptyOrScalar} = Gender.empty
        dAge double {ValidationUtils.MustBeEmptyOrScalar} = []
        
        ePrimaryCancerActive PrimaryCancerActive
        ePrimaryCancerSite PrimarySite
        ePrimaryCancerHistology HistologyResult
        eSystemicMetastasesStatus SystemicMetastasesStatus
        eExtracranialDiseaseActive ExtracranialDiseaseActive
        eSystemicTherapyStatus SystemicTherapyStatus
        eSteroidStatus SteroidStatus
        eWHOScore WHOScore
        
        dtFirstSRSTreatmentDate datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty
        dtOutOfFieldProgressionDate datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty
        
        dtDateOfDeath datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty
        eCauseOfDeath CauseOfDeath
        
        
        
        
        
        
        
%         
%         oDiagnosis Diagnosis {ValidationUtils.MustBeEmptyOrScalar} = Diagnosis.empty
%         oTreatment Treatment {ValidationUtils.MustBeEmptyOrScalar} = Treatment.empty
%         oTreatmentOutcomes TreatmentOutcomes {ValidationUtils.MustBeEmptyOrScalar} = TreatmentOutcomes.empty
        
        
        voBrainMetastases (:,1) BrainMetastasis = BrainMetastasis.empty(0,1)
        
        sPreTreatmentT1wCEMRIFilePath (1,1) string
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Patient(dPrimaryId, dSecondaryId, eGender, dAge, ePrimaryCancerActive, ePrimaryCancerSite, ePrimaryCancerHistology, eSystemicMetastasesStatus, eExtracranialDiseaseActive, eSystemicTherapyStatus, eSteroidStatus, eWHOScore, dtFirstSRSTreatmentDate, dtOutOfFieldProgressionDate, dtDateOfDeath, eCauseOfDeath, voBrainMetastases, sPreTreatmentT1wCEMRIFilePath)
            arguments
                dPrimaryId (1,1) double {mustBeInteger, mustBePositive}
                dSecondaryId (1,1) double {mustBeInteger, mustBePositive}
                eGender Gender {ValidationUtils.MustBeEmptyOrScalar}
                dAge double {ValidationUtils.MustBeEmptyOrScalar}
                ePrimaryCancerActive PrimaryCancerActive
                ePrimaryCancerSite PrimarySite
                ePrimaryCancerHistology HistologyResult
                eSystemicMetastasesStatus SystemicMetastasesStatus
                eExtracranialDiseaseActive ExtracranialDiseaseActive
                eSystemicTherapyStatus SystemicTherapyStatus
                eSteroidStatus SteroidStatus
                eWHOScore WHOScore
                dtFirstSRSTreatmentDate datetime
                dtOutOfFieldProgressionDate datetime
                dtDateOfDeath datetime
                eCauseOfDeath CauseOfDeath
                voBrainMetastases (:,1) BrainMetastasis
                sPreTreatmentT1wCEMRIFilePath (1,1) string
            end
            
            % validate
            if isnat(dtOutOfFieldProgressionDate)
                dtOutOfFieldProgressionDate = datetime.empty;
            end
            
            dNumBMs = length(voBrainMetastases);
            
            vdBMNumbers = zeros(dNumBMs,1);
            vdROINumbers = zeros(dNumBMs,1);
            
            for dBMIndex=1:dNumBMs
                % validate dates eventually
                
                vdBMNumbers(dBMIndex) = voBrainMetastases(dBMIndex).GetBrainMetastasisNumber();
                vdROINumbers(dBMIndex) = voBrainMetastases(dBMIndex).GetRegionOfInterestNumberInPreTreatmentImaging();
            end
            
            if any(unique(vdBMNumbers) ~= (1:dNumBMs)')
                error('Not valid BM numbers');
            end
            
            if length(unique(vdROINumbers)) ~= length(vdROINumbers)
                error('Repeated ROI number');
            end
            
            % set
            obj.dPrimaryId = dPrimaryId;
            obj.dSecondaryId = dSecondaryId;
            
            obj.eGender = eGender;
            obj.dAge = dAge;
            obj.ePrimaryCancerActive = ePrimaryCancerActive;
            obj.ePrimaryCancerSite = ePrimaryCancerSite;
            obj.ePrimaryCancerHistology = ePrimaryCancerHistology;
            obj.eSystemicMetastasesStatus = eSystemicMetastasesStatus;
            obj.eExtracranialDiseaseActive = eExtracranialDiseaseActive;
            obj.eSystemicTherapyStatus = eSystemicTherapyStatus;
            obj.eSteroidStatus = eSteroidStatus;
            obj.eWHOScore = eWHOScore;            
            
            obj.dtFirstSRSTreatmentDate = dtFirstSRSTreatmentDate;
            obj.dtOutOfFieldProgressionDate = dtOutOfFieldProgressionDate;
            obj.dtDateOfDeath = dtDateOfDeath;
            obj.eCauseOfDeath = eCauseOfDeath;
            
            obj.voBrainMetastases = voBrainMetastases;
            obj.sPreTreatmentT1wCEMRIFilePath = sPreTreatmentT1wCEMRIFilePath;
        end
        
        function Update(obj)      
        end
        
        function dtDateOfDeath = GetDateOfDeath(obj)
            dtDateOfDeath = obj.dtDateOfDeath;
        end
        
        function dtFirstSRSTreatmentDate = GetFirstSRSTreatmentDate(obj)
            dtFirstSRSTreatmentDate = obj.dtFirstSRSTreatmentDate;
        end
        
        function [dtDateOfFirstProgression, oLargestBrainMetastasis] = GetDateAndLargestBrainMetastasisOfFirstProgression(obj)
            dNumBMs = length(obj.voBrainMetastases);
            vdNumDaysToProgression = inf(dNumBMs,1);
            
            oLargestBrainMetastasis = BrainMetastasis.empty;
            
            for dBMIndex=1:dNumBMs
                dtInFieldProgressionDate = obj.voBrainMetastases(dBMIndex).GetInFieldProgressionDate();
                
                if ~isempty(dtInFieldProgressionDate)
                    vdNumDaysToProgression(dBMIndex) = days(dtInFieldProgressionDate - obj.dtFirstSRSTreatmentDate);
                end
            end
            
            [~,dMinIndex] = min(vdNumDaysToProgression);
            
            dtDateOfFirstProgression = obj.voBrainMetastases(dMinIndex).GetInFieldProgressionDate();
            
            if ~isempty(dtDateOfFirstProgression)
                vbBMsToFirstProgress = vdNumDaysToProgression == (vdNumDaysToProgression(dMinIndex));
                voBMsToFirstProgress = obj.voBrainMetastases(vbBMsToFirstProgress);
                
                dNumBMs = length(voBMsToFirstProgress);
                vdVolumes_mm3 = zeros(dNumBMs,1);
                
                for dBMIndex=1:dNumBMs
                    vdVolumes_mm3(dBMIndex) = voBMsToFirstProgress(dBMIndex).GetGrossTumourVolume_mm3();
                end
                
                [~,dMaxIndex] = max(vdVolumes_mm3);
                oLargestBrainMetastasis = voBMsToFirstProgress(dMaxIndex);
            end
        end
        
        function oLargestBrainMetastasis = GetLargestBrainMetastasis(obj)
            dNumBMs = length(obj.voBrainMetastases);
            vdVolumes_mm3 = zeros(dNumBMs,1);
            
            for dBMIndex=1:dNumBMs
                vdVolumes_mm3(dBMIndex) = obj.voBrainMetastases(dBMIndex).GetGrossTumourVolume_mm3();
            end
            
            [~,dMaxIndex] = max(vdVolumes_mm3);
            oLargestBrainMetastasis = obj.voBrainMetastases(dMaxIndex);
        end
        
        function sPath = GetPreTreatmentT1wCEMRIFilePath(obj)
            sPath = obj.sPreTreatmentT1wCEMRIFilePath;
        end
        
        function oImageVolume = GetPreTreatmentT1wCEMRIImageVolume(obj)
            oImageVolume = DicomImageVolume.Load(fullfile(Experiment.GetDataPath('ImagingDatabaseRoot'), obj.sPreTreatmentT1wCEMRIFilePath));
        end
        
        function dtOutOfFieldProgressionDate = GetOutOfFieldProgressionDate(obj)
            dtOutOfFieldProgressionDate = obj.dtOutOfFieldProgressionDate;
        end
        
        function dNumMonths = GetSurvivalTime_months(obj)
            dNumMonths = months(datenum(obj.dtFirstSRSTreatmentDate), datenum(obj.dtDateOfDeath));
        end
        
        function oViewerApp = ViewBrainMetastasis(obj, dBMNumber, oDB, oViewerApp)
            arguments
                obj
                dBMNumber
                oDB
                oViewerApp = []
            end
            
            dROINumber = obj.GetBrainMetastasis(dBMNumber).GetRegionOfInterestNumberInPreTreatmentImaging();
            
            oPatient = oDB.GetPatientByPrimaryId(obj.dPrimaryId);
            
            vdDispThreshold = oPatient.GetPreTreatmentImagingStudy().GetContouredImageVolume().vdPreferredImageVolumeDisplayThreshold;
            
            oImageVolume = DicomImageVolume.Load(fullfile(Experiment.GetDataPath('ImagingDatabaseRoot'), obj.sPreTreatmentT1wCEMRIFilePath));
            
            if isempty(oViewerApp)
                oViewerApp = oImageVolume.View();
            else
                oViewerApp.SetNewImageVolume(oImageVolume);
            end
            
            if dROINumber == 0
                warning('BM not contoured');
            else
                oViewerApp.CentreOnRegionOfInterest(dROINumber);
            end
            
            oViewerApp.SetImageDataDisplayThreshold(vdDispThreshold);
        end
        
        function [dFeatureValue, bFeatureIsCategorical] = GetFeatureValue(obj, sFeatureName, c1veCategoryGroups)
            
            switch sFeatureName
                case "Gender"
                    bFeatureIsCategorical = true;
                    
                    dFeatureValue = obj.eGender.GetFeatureValuesCategoryNumber();
                case "Age"
                    bFeatureIsCategorical = false;
                    
                    dFeatureValue = obj.dAge;
                case "Primary Cancer Active"
                    bFeatureIsCategorical = true;
                    
                    dFeatureValue = obj.ePrimaryCancerActive.GetFeatureValuesCategoryNumber();
                case "Primary Cancer Site"
                    bFeatureIsCategorical = true;
                    
                    if isempty(c1veCategoryGroups)
                        dFeatureValue = obj.ePrimaryCancerSite.GetFeatureValuesCategoryNumber();
                    else
                        dFeatureValue = Patient.RecategorizeVariable(obj.ePrimaryCancerSite, c1veCategoryGroups);
                    end
                case "Primary Cancer Histology"
                    bFeatureIsCategorical = true;
                    
                    if isempty(c1veCategoryGroups)
                        dFeatureValue = obj.ePrimaryCancerHistology.GetFeatureValuesCategoryNumber();
                    else
                        dFeatureValue = Patient.RecategorizeVariable(obj.ePrimaryCancerHistology, c1veCategoryGroups);
                    end                    
                case "Systemic Metastases Status"
                    bFeatureIsCategorical = true;
                    
                    dFeatureValue = obj.eSystemicMetastasesStatus.GetFeatureValuesCategoryNumber();
                case "Extracranial Disease Active"
                    bFeatureIsCategorical = true;
                    
                    dFeatureValue = obj.eExtracranialDiseaseActive.GetFeatureValuesCategoryNumber();
                case "Systemic Therapy Status"
                    bFeatureIsCategorical = true;
                    
                    if isempty(c1veCategoryGroups)
                        dFeatureValue = obj.eSystemicTherapyStatus.GetFeatureValuesCategoryNumber();
                    else
                        dFeatureValue = Patient.RecategorizeVariable(obj.eSystemicTherapyStatus, c1veCategoryGroups);
                    end                           
                case "Steroid Status"
                    bFeatureIsCategorical = true;
                    
                    if isempty(c1veCategoryGroups)
                        dFeatureValue = obj.eSteroidStatus.GetFeatureValuesCategoryNumber();
                    else
                        dFeatureValue = Patient.RecategorizeVariable(obj.eSteroidStatus, c1veCategoryGroups);
                    end                     
                case "WHO Score"
                    bFeatureIsCategorical = false;
                    
                    if isempty(c1veCategoryGroups)
                        dFeatureValue = obj.eWHOScore.GetScore();
                    else
                        dFeatureValue = Patient.RecategorizeVariable(obj.eWHOScore, c1veCategoryGroups);
                    end                                         
                otherwise
                    dFeatureValue = [];
                    bFeatureIsCategorical = [];
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> TUMOUR GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dNumberOfBMs = GetNumberOfBrainMetastases(obj)
            dNumberOfBMs = length(obj.voBrainMetastases);
        end
        
        function voBrainMetastases = GetBrainMetastases(obj)
            voBrainMetastases = obj.voBrainMetastases;
        end
        
        function oBM = GetBrainMetastasis(obj, dBMNumber)
            oBM = [];
            
            for dBMIndex=1:length(obj.voBrainMetastases)
                if obj.voBrainMetastases(dBMIndex).GetBrainMetastasisNumber() == dBMNumber
                    oBM = obj.voBrainMetastases(dBMIndex);
                    break;
                end
            end
            
            if isempty(oBM)
                error(...
                    'Patient:GetBrainMetastasis:BMNumberNotFound',...
                    'No BM with the provided BM number was found.');
            end
        end
        
        function oIV = LoadImageVolume(obj, sIMGPPCode, NameValueArgs)
            arguments
                obj (1,1) Patient
                sIMGPPCode (1,1) string
                NameValueArgs.BrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
                        
            if sIMGPPCode == "IMGPP-000"
                chImagingDatabaseRootPath = Experiment.GetDataPath('ImagingDatabaseRoot');
                sFilePath = fullfile(chImagingDatabaseRootPath, obj.sPreTreatmentT1wCEMRIFilePath);
            else
                chImagingDatabaseRootPath = Experiment.GetDataPath('ImagingDatabaseRoot_v2');
                
                sFolder = sIMGPPCode;
                
                if isfield(NameValueArgs, 'BrainMetastasisNumber')
                    sFolder = sFolder + " (BM " + string(NameValueArgs.BrainMetastasisNumber) + ")";
                end
                
                sPreTreatmentT1wCEMRIFilePath = obj.sPreTreatmentT1wCEMRIFilePath;
                
                sPreTreatmentT1wCEMRIFilePath = strrep(sPreTreatmentT1wCEMRIFilePath, ' [Contoured]', '');
                
                [sPreTreatmentT1wCEMRIToFilePath, sPreTreatmentT1wCEMRIFilenamePath] = FileIOUtils.SeparateFilePathAndFilename(sPreTreatmentT1wCEMRIFilePath);
                
                sFilePath = fullfile(chImagingDatabaseRootPath, sPreTreatmentT1wCEMRIToFilePath, sFolder, sPreTreatmentT1wCEMRIFilenamePath);                
            end
            
            oIV = ImageVolume.Load(sFilePath);
        end
        
        function oROIs = LoadRegionsOfInterest(obj, sROIPPCode, NameValueArgs)
            arguments
                obj (1,1) Patient
                sROIPPCode (1,1) string
                NameValueArgs.BrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
            
            chImagingDatabaseRootPath = Experiment.GetDataPath('ImagingDatabaseRoot');
                        
            if sROIPPCode == "ROIPP-000"
                sFilePath = fullfile(chImagingDatabaseRootPath, obj.sPreTreatmentT1wCEMRIFilePath);
                
                oIV = ImageVolume.Load(sFilePath);
                oROIs = oIV.GetRegionsOfInterest();
            else
                chImagingDatabaseRootPath = Experiment.GetDataPath('ImagingDatabaseRoot_v2');
                
                sFolder = sROIPPCode;
                
                if isfield(NameValueArgs, 'BrainMetastasisNumber')
                    sFolder = sFolder + " (BM " + string(NameValueArgs.BrainMetastasisNumber) + ")";
                end
                
                sPreTreatmentT1wCEMRIFilePath = obj.sPreTreatmentT1wCEMRIFilePath;
                
                sPreTreatmentT1wCEMRIFilePath = strrep(sPreTreatmentT1wCEMRIFilePath, ' [Contoured]', ' [Contours Only]');
                
                [sPreTreatmentT1wCEMRIToFilePath, sPreTreatmentT1wCEMRIFilenamePath] = FileIOUtils.SeparateFilePathAndFilename(sPreTreatmentT1wCEMRIFilePath);
                
                sFilePath = fullfile(chImagingDatabaseRootPath, sPreTreatmentT1wCEMRIToFilePath, sFolder, sPreTreatmentT1wCEMRIFilenamePath);       
                
                oROIs = RegionsOfInterest.Load(sFilePath);
            end
        end
        
        function SaveImageVolume(obj, oImageVolume, sIMGPPCode, NameValueArgs)
            arguments
                obj (1,1) Patient
                oImageVolume (1,1) ImageVolume
                sIMGPPCode (1,1) string
                NameValueArgs.SaveVarargin
                NameValueArgs.BrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
                        
            chImagingDatabaseRootPath = Experiment.GetDataPath('ImagingDatabaseRoot_v2');
                        
            sPreTreatmentT1wCEMRIFilePath = obj.sPreTreatmentT1wCEMRIFilePath;
            [chPreTreatmentT1wCEMRIFolderPath, chPreTreatmentT1wCEMRIFilename] = FileIOUtils.SeparateFilePathAndFilename(sPreTreatmentT1wCEMRIFilePath);
                        
            sFolderName = sIMGPPCode;
            
            if isfield(NameValueArgs, 'BrainMetastasisNumber')
                sFolderName = sFolderName + " (BM " + string(NameValueArgs.BrainMetastasisNumber) + ")";
            end
            
            if isfolder(fullfile(chImagingDatabaseRootPath, chPreTreatmentT1wCEMRIFolderPath, sFolderName))
                error(...
                    'Patient:SaveImageVolume:ImageVolumeDirectoryAlreadyExists',...
                    'The directory already exists');
            end
            
            mkdir(fullfile(chImagingDatabaseRootPath, chPreTreatmentT1wCEMRIFolderPath), sFolderName);
            
            if oImageVolume.GetNumberOfRegionsOfInterest() == 0
                chPreTreatmentT1wCEMRIFilename = strrep(chPreTreatmentT1wCEMRIFilename, ' [Contoured]', '');
            end
            
            oImageVolume.Save(fullfile(chImagingDatabaseRootPath, chPreTreatmentT1wCEMRIFolderPath, sFolderName, chPreTreatmentT1wCEMRIFilename));
        end
        
        function SaveRegionsOfInterest(obj, oROIs, sROIPPCode, NameValueArgs)
            arguments
                obj (1,1) Patient
                oROIs (1,1) RegionsOfInterest
                sROIPPCode (1,1) string
                NameValueArgs.SaveVarargin
                NameValueArgs.BrainMetastasisNumber (1,1) double {mustBePositive, mustBeInteger}
            end
                        
            chImagingDatabaseRootPath = Experiment.GetDataPath('ImagingDatabaseRoot_v2');
                        
            sPreTreatmentT1wCEMRIFilePath = obj.sPreTreatmentT1wCEMRIFilePath;
            [chPreTreatmentT1wCEMRIFolderPath, chPreTreatmentT1wCEMRIFilename] = FileIOUtils.SeparateFilePathAndFilename(sPreTreatmentT1wCEMRIFilePath);
                        
            sFolderName = sROIPPCode;
            
            if isfield(NameValueArgs, 'BrainMetastasisNumber')
                sFolderName = sFolderName + " (BM " + string(NameValueArgs.BrainMetastasisNumber) + ")";
            end
            
            if isfolder(fullfile(chImagingDatabaseRootPath, chPreTreatmentT1wCEMRIFolderPath, sFolderName))
                warning(...
                    'Patient:SaveRegionsOfInterest:RegionsOfInterestDirectoryAlreadyExists',...
                    'The directory already exists, so it will be overwritten');
                rmdir(fullfile(chImagingDatabaseRootPath, chPreTreatmentT1wCEMRIFolderPath, sFolderName), 's');
            end
            
            mkdir(fullfile(chImagingDatabaseRootPath, chPreTreatmentT1wCEMRIFolderPath), sFolderName);
            
            chPreTreatmentT1wCEMRIFilename = strrep(chPreTreatmentT1wCEMRIFilename, ' [Contoured]', ' [Contours Only]');
                        
            oROIs.Save(fullfile(chImagingDatabaseRootPath, chPreTreatmentT1wCEMRIFolderPath, sFolderName, chPreTreatmentT1wCEMRIFilename));
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                
        function dPrimaryId = GetPrimaryId(obj)
            dPrimaryId = obj.dPrimaryId;
        end
        
        function dSecondaryId = GetSecondaryId(obj)
            dSecondaryId = obj.dSecondaryId;
        end
        
    end
    
    
    methods (Access = public, Static = true)
        
        function oPatient = CreateFromStudyDatabaseSpreadsheet(dPatientId, c2xPerPatientData, c2xPerBMData)
            % per patient data
            vdPatientIdPerRow = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xPerPatientData(:,2));
            
            dPatientRowIndex = find(vdPatientIdPerRow == dPatientId);
            
            dSecondaryId = c2xPerPatientData{dPatientRowIndex, 3};
            sPreTreatmentT1wCEMRIFilePath = c2xPerPatientData{vdPatientIdPerRow == dPatientId, 34};
            
            % per BM data
            vdPatientRows = find(CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xPerBMData(:,2)) == dPatientId);
            
            dNumBMs = length(vdPatientRows);
            c1oBMs = cell(dNumBMs,1);
            
            for dBMIndex=1:dNumBMs
                dRowIndex = vdPatientRows(dBMIndex);
                                
                c1oBMs{dBMIndex} = BrainMetastasis(...
                    c2xPerBMData{dRowIndex, 4}, c2xPerBMData{dRowIndex, 5}, c2xPerBMData{dRowIndex, 6},...
                    c2xPerBMData{dRowIndex, 7},...
                    BrainMetastasisLocation.getEnumFromDatabaseLabel(c2xPerBMData{dRowIndex, 8}),...
                    BrainMetastasisAppearanceScore.getEnumFromDatabaseCode(c2xPerBMData{dRowIndex, 9}),...
                    SRSTreatmentParameters.getEnumFromDatabaseValues(c2xPerBMData{dRowIndex, 10}, c2xPerBMData{dRowIndex, 11}),...
                    c2xPerBMData{dRowIndex, 12}, c2xPerBMData{dRowIndex, 13});                    
            end
            
            % create
            oPatient = Patient(...
                dPatientId, dSecondaryId,...
                Gender.getEnumFromDatabaseLabel(c2xPerPatientData{dPatientRowIndex,4}),...
                c2xPerPatientData{dPatientRowIndex,5},...
                PrimaryCancerActive.getEnumFromDatabaseValues(c2xPerPatientData{dPatientRowIndex,7}),...
                PrimarySite.getEnumFromDatabaseLabel(c2xPerPatientData{dPatientRowIndex,8}),...
                HistologyResult.getEnumFromDatabaseLabel(c2xPerPatientData{dPatientRowIndex,9}),...
                SystemicMetastasesStatus.getEnumFromDatabaseValues(c2xPerPatientData{dPatientRowIndex,10}),...
                ExtracranialDiseaseActive.getEnumFromDatabaseValues(c2xPerPatientData{dPatientRowIndex,11}),...
                SystemicTherapyStatus.getEnumFromDatabaseValues(c2xPerPatientData{dPatientRowIndex,12}),...
                SteroidStatus.getEnumFromDatabaseCode(c2xPerPatientData{dPatientRowIndex,13}),...      
                WHOScore.getEnumFromDatabaseValues(c2xPerPatientData{dPatientRowIndex,14}),...  
                c2xPerPatientData{dPatientRowIndex,28},...
                c2xPerPatientData{dPatientRowIndex,29},...
                c2xPerPatientData{dPatientRowIndex,32},...
                CauseOfDeath.getEnumFromDatabaseValues(c2xPerPatientData{dPatientRowIndex,33}),...
                CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oBMs),...
                sPreTreatmentT1wCEMRIFilePath);
        end
        
        function voPatients = LoadPatientsFromStudyDatabaseSpreadsheet(sFilePath)
            c2xDataPerPatient = readcell(sFilePath, 'Sheet', 'Per Patient');
            c2xDataPerBM = readcell(sFilePath, 'Sheet', 'Per BM');
            
            c2xDataPerPatient = c2xDataPerPatient(3:end,:);
            c2xDataPerBM = c2xDataPerBM(3:end,:);
            
            vdPatientIds = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c2xDataPerPatient(:,2));
            dNumPatients = length(vdPatientIds);
            
            c1oPatients = cell(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                c1oPatients{dPatientIndex} = Patient.CreateFromStudyDatabaseSpreadsheet(vdPatientIds(dPatientIndex), c2xDataPerPatient, c2xDataPerBM);
            end
            
            voPatients = CellArrayUtils.CellArrayOfObjects2MatrixOfObjects(c1oPatients);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = {?Patient, ?BrainMetastasis}, Static = true)
                
        function dFeatureValue = RecategorizeVariable(eCategory, c1veCategoryRegroupings)
            dFeatureValue = [];
            
            for dSearchIndex=1:length(c1veCategoryRegroupings)
                if any(c1veCategoryRegroupings{dSearchIndex} == eCategory)
                    if ~isempty(dFeatureValue)
                        error(...
                            'Patient:RecategorizeVariable:MultipleMatches',...
                            'Category value found in multiple groups.');
                    end
                    
                    dFeatureValue = dSearchIndex;
                end
            end
            
            if isempty(dFeatureValue)
                error(...
                    'Patient:RecategorizeVariable:NoMatch',...
                    'Category value not found in any groups.');
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
