classdef StudyDatabase < handle
    %StudyDatabase
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        voPatients (1,:) DatabasePatient = DatabasePatient.empty(1,0)
    end
    
    properties (Constant = true, GetAccess = private)
        chDatabaseMatfileVarName = 'database'
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = StudyDatabase()
            %obj = PatientDatabase()
        end
        
        function Update(obj, chPatientExcelFilePath)
            % update contained objects
            c1xExcelData = readcell(chPatientExcelFilePath);
            vsPatientIdStrings = string(c1xExcelData(:,1));
            
            % update contained objects
            
            for dPatientIndex=1:length(obj.voPatients)
                disp(['Patient : ', num2str(dPatientIndex)]);
                                
                obj.voPatients(dPatientIndex).Update(c1xExcelData(vsPatientIdStrings=="Patient"+string(num2str(obj.voPatients(dPatientIndex).dPrimaryId)),:));
            end
        end
        
        function oSelectedClassObject = QuickSelect(obj, varargin)
            if nargin > 1
                oSelectedClassObject = obj.GetPatientByPrimaryId(varargin{1});
            end
            
            if nargin > 2
                oSelectedClassObject = oSelectedClassObject.GetImagingStudyByStudyNumber(varargin{2});
            end
            
            if nargin > 3
                oSelectedClassObject = oSelectedClassObject.GetImageVolumeByVolumeNumber(varargin{3});
            end
            
            if nargin > 4
                oSelectedClassObject = oSelectedClassObject.GetRegionOfInterestByIndex(varargin{4});
            end
        end
        
        function AddPatient(obj, oPatient)
            %addPatients(obj, patient)
            
            if isempty(obj.FindPatient(oPatient))
                obj.voPatients = [obj.voPatients, oPatient];
            else
                error(['Patient with same Primary/Secondary ID already exists: ', num2str(oPatient.GetPrimaryId())]);
            end
        end
        
        function AddPatients(obj, voPatients)
            %addPatients(obj, patients)
            
            for dNewPatientIndex=1:length(voPatients)
                obj.AddPatient(voPatients(dNewPatientIndex));
            end
        end
        
        function oFoundPatient = FindPatient(obj, oPatient)
            oFoundPatient = [];
            
            for dPatientIndex=1:length(obj.voPatients)
                if obj.voPatients(dPatientIndex).GetPrimaryId() == oPatient.GetPrimaryId() ||...
                        strcmp(obj.voPatients(dPatientIndex).GetSecondaryId(), oPatient.GetSecondaryId())
                    oFoundPatient = obj.voPatients(dPatientIndex);
                    break;
                end
            end
        end
        
        function SortPatientsByPrimaryId(obj)
            vdPrimaryIds = obj.GetAllPrimaryIds();
            dNumPatients = length(obj.voPatients);
            
            [~,vdSortIndex] = sort(vdPrimaryIds, 'ascend');
            
            obj.voPatients = obj.voPatients(vdSortIndex);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> DATABASE QUERYING <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function [c2xQueryResults, c2chColumnHeaders] = ExecuteQuery(obj, oDatabaseQuery)
            [c2xQueryResults, c2chColumnHeaders] = oDatabaseQuery.Execute(obj);
        end
        
        function ExportQueryToXls(obj, chWritePath, varargin)
            
            for dSheetIndex=1:2:length(varargin)
                [c2xQueryResults, c2chColumnHeaders] = obj.ExecuteQuery(varargin{dSheetIndex+1});
                
                c2xQueryResults = DatabaseQuery.ConvertResultsToStringOrNumeric(c2xQueryResults);
                
                % write sheet
                writecell(...
                    [c2chColumnHeaders; c2xQueryResults],...
                    chWritePath,...
                    'FileType', 'spreadsheet',...
                    'Sheet', varargin{dSheetIndex});
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>> LOAD / SAVE <<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function Save(obj, chSavePath)
            FileIOUtils.SaveMatFile(chSavePath, StudyDatabase.chDatabaseMatfileVarName, obj);
        end
        
        % See Public, Static methods for "Load"
        
        
        % >>>>>>>>>>>>>>>>>>>>> PATIENT GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<
          
        
        function voPatients = GetPatients(obj)
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
                        'StudyDatabase:GetPatientsByPrimaryIds:IdNotFound',...
                        ['No Patient with the Primary ID: ', num2str(vdPrimaryIds(dIdIndex)), ' was found in the database.']);
                else
                    voPatients(dIdIndex) = oFoundPatient;
                end
            end
            
        end
        
        function oFoundPatient = GetPatientByPrimaryId(obj, dPrimaryId)
            oFoundPatient = DatabasePatient.empty;
            
            for dPatientIndex=1:length(obj.voPatients)
                if obj.voPatients(dPatientIndex).GetPrimaryId() == dPrimaryId
                    oFoundPatient = obj.voPatients(dPatientIndex);
                    break;
                end
            end
        end
        
        function voPatients = GetPatientsWithImagingStudiesWithinTimepointsFromTreatment(obj, dTimepointStarts_days, dTimepointBracket_days)
            dNumPatients = length(obj.voPatients);
            
            vbIncludePatients = false(dNumPatients,1);
            
            for dPatientIndex=1:dNumPatients
                vbIncludePatients(dPatientIndex) = obj.voPatients(dPatientIndex).DoesPatientHaveImagingStudiesWithinTimepointsFromTreatment(dTimepointStarts_days, dTimepointBracket_days);
            end
            
            voPatients = obj.voPatients(vbIncludePatients);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                
        function dNumPatients = GetNumberOfPatients(obj)
            dNumPatients = length(obj.voPatients);
        end
    end
    
    methods (Access = public, Static)
        
        function obj = Load(chLoadPath)
            if Experiment.IsRunning() && Experiment.IsInDebugMode()
                global CachedDatabaseForDebug;
                global CachedDatabaseForDebugLoadPath;
                
                if ~isempty(CachedDatabaseForDebug) && strcmp(chLoadPath, CachedDatabaseForDebugLoadPath)
                    obj = CachedDatabaseForDebug;
                    
                    warning(...
                        'StudyDatabase:Load:UsingCachedDatabase',...
                        'Since an Experiment was running in debug mode, instead of loading the database, a cached version was found and used.');
                else
                    obj = FileIOUtils.LoadMatFile(chLoadPath, StudyDatabase.chDatabaseMatfileVarName);
                    
                    CachedDatabaseForDebug = obj;
                    CachedDatabaseForDebugLoadPath = chLoadPath;
                end
            else
                obj = FileIOUtils.LoadMatFile(chLoadPath, StudyDatabase.chDatabaseMatfileVarName);
            end
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

