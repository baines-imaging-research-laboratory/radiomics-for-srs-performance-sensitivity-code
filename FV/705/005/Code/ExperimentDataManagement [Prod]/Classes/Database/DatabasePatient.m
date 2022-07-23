classdef DatabasePatient < handle
    %Patient
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dPrimaryId double {ValidationUtils.MustBeEmptyOrScalar, mustBeInteger} % should be sequential 1 through number of patients
        chSecondaryId (1,:) char % set from where data is coming from
        
        dAge double {ValidationUtils.MustBeEmptyOrScalar} = [];
        eGender Gender {ValidationUtils.MustBeEmptyOrScalar} = Gender.empty
        
        oDiagnosis Diagnosis {ValidationUtils.MustBeEmptyOrScalar} = Diagnosis.empty
        oTreatment Treatment {ValidationUtils.MustBeEmptyOrScalar} = Treatment.empty
        oTreatmentOutcomes TreatmentOutcomes {ValidationUtils.MustBeEmptyOrScalar} = TreatmentOutcomes.empty
        voTumours (1,:) Tumour = Tumour.empty(1,0)
        
        
        
        voDatabaseImagingStudies (1,:) DatabaseImagingStudy = DatabaseImagingStudy.empty(1,0)
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = DatabasePatient(dPrimaryId, chSecondaryId, dAge, eGender, oDiagnosis, oTreatment, voTumours, voDatabaseImagingStudies)
            %obj = DatabasePatient(dPrimaryId, chSecondaryId, dAge, eGender, oDiagnosis, oTreatment, voTumours, voDatabaseImagingStudies)
            obj.dPrimaryId = dPrimaryId;
            obj.chSecondaryId = chSecondaryId;
            obj.dAge = dAge;
            obj.eGender = eGender;
            obj.oDiagnosis = oDiagnosis;
            obj.oTreatment = oTreatment;
            obj.voTumours = voTumours;
            obj.voDatabaseImagingStudies = voDatabaseImagingStudies;
        end
        
        function Update(obj, c1xRowsFromExcel)               
            dNumTumours = length(obj.voTumours);
            
            vdTumourDose_Gy = zeros(dNumTumours,1);
            vdTumourNumFx = zeros(dNumTumours,1);
            
            for dTumourIndex=1:length(obj.voTumours)
                vdTumourDose_Gy(dTumourIndex) = str2double(c1xRowsFromExcel{dTumourIndex,7});
                vdTumourNumFx(dTumourIndex) = c1xRowsFromExcel{dTumourIndex,8};
            end
            
            % update contained objects
            
            obj.oDiagnosis = obj.oDiagnosis.Update();
            obj.oTreatment = obj.oTreatment.Update();
            obj.oTreatmentOutcomes = obj.oTreatmentOutcomes.Update();
                        
            for dTumourIndex=1:length(obj.voTumours)
                obj.voTumours(dTumourIndex) = obj.voTumours(dTumourIndex).Update(vdTumourDose_Gy(dTumourIndex), vdTumourNumFx(dTumourIndex));
            end
            
            for dStudyIndex=1:length(obj.voDatabaseImagingStudies)
                obj.voDatabaseImagingStudies(dStudyIndex).Update();
            end
        end
        
        function SetImagingStudies(obj, voDatabaseImagingStudies)
            %setImagingStudies(obj, voDatabaseImagingStudies)
            obj.voDatabaseImagingStudies = voDatabaseImagingStudies;
        end
        
        function bBool = DoesPatientHaveImagingStudiesWithinTimepointsFromTreatment(obj, vdTimepointStarts_days, vdTimepointBracket_days)
            bBool = true;
            
            for dTimepointIndex=1:length(vdTimepointStarts_days)
                c1oStudies = getAllStudiesFromDateWithinTimepoints(...
                    obj, obj.oTreatment.oTreatmentDate,...
                    vdTimepointStarts_days(dTimepointIndex), vdTimepointStarts_days(dTimepointIndex) + vdTimepointBracket_days);
                
                if isempty(c1oStudies)
                    bBool = false;
                    break;
                end
            end
        end
                
        
        % >>>>>>>>>>>>>>>>>>> IMAGING STUDY GETTERS <<<<<<<<<<<<<<<<<<<<<<<
             
        function dNumStudies = GetNumberOfImagingStudies(obj)
            dNumStudies = length(obj.voDatabaseImagingStudies);
        end
        
        function voDatabaseImagingStudies = GetImagingStudies(obj)
            voDatabaseImagingStudies = obj.voDatabaseImagingStudies;
        end
                
        function oImagingStudy = GetImagingStudyByStudyNumber(obj, dStudyNumber)
            oImagingStudy = [];
            
            for dStudyIndex=1:length(obj.voDatabaseImagingStudies)
                if obj.voDatabaseImagingStudies(dStudyIndex).GetStudyNumber() == dStudyNumber
                    oImagingStudy = obj.voDatabaseImagingStudies(dStudyIndex);
                    break;
                end
            end
        end
        
        function voStudies = GetImagingStudiesInChronologicalOrder(obj)
            % from earliest to latest (farthest from recent to most recent)
            
            dNumStudies = length(obj.voDatabaseImagingStudies);
            
            vdtImagingDates = NaT(dNumStudies,1);
            
            for dStudyIndex=1:dNumStudies
                vdtImagingDates(dStudyIndex) = obj.voDatabaseImagingStudies(dStudyIndex).getImagingDate();
            end
            
            [~,vdSortIndex] = sort(vdtImagingDates,'ascend');
            
            voStudies = obj.voDatabaseImagingStudies(vdSortIndex);
        end
        
        function oStudy = GetPreTreatmentImagingStudy(obj)
            voStudies = obj.GetImagingStudiesBeforeDate(obj.oTreatment.GetTreatmentDate());
            
            if length(voStudies) ~= 1
                error(...
                    'DatabasePatient:GetPreTreatmentImagingStudy:SingleStudyNotFound',...
                    'There is either no or multiple pre-treatment imaging studies.');
            end
            
            oStudy = voStudies(1);
        end
        
        function voStudies = GetAllPostTreatmentImagingStudies(obj)
            voStudies = obj.GetImagingStudiesAfterDate(obj.oTreatment.GetTreatmentDate());
        end
        
        function oImagingStudy = GetPostTreatmentImagingStudy(obj)
            % finds imaging study closest to treatment date without going
            % before
            
            dtTreatmentDate = obj.oTreatment.GetTreatmentDate();
            
            oImagingStudy = [];
            dDifference = -Inf;
            
            for dStudyIndex=1:length(obj.voDatabaseImagingStudies)
                dNewDiff = dtTreatmentDate - obj.voDatabaseImagingStudies(dStudyIndex).GetImagingDate();
                
                if dNewDiff <= 0 && dNewDiff > dDifference % a new closer date that isn't before the oTreatment date
                    oImagingStudy = obj.voDatabaseImagingStudies(dStudyIndex);
                    dDifference = dNewDiff;
                end
            end
        end
        
        function voImagingStudies = GetPostTreatmentImagingStudies(obj)
            % finds imaging study closest to treatment date without going
            % before
            
            dtTreatmentDate = obj.oTreatment.GetTreatmentDate();
            
            oImagingStudy = [];
            dDifference = -Inf;
            
            dNumStudies = length(obj.voDatabaseImagingStudies);
            vbStudyAfterTreatment = false(1,dNumStudies);
            
            for dStudyIndex=1:dNumStudies
                dNewDiff = dtTreatmentDate - obj.voDatabaseImagingStudies(dStudyIndex).GetImagingDate();
                
                vbStudyAfterTreatment(dStudyIndex) = dNewDiff <= 0;
            end
            
            voImagingStudies = obj.voDatabaseImagingStudies(vbStudyAfterTreatment);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> TUMOUR GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function voTumours = GetTumours(obj)
            voTumours = obj.voTumours;
        end
        
        function oTumour = GetTumourByTumourNumber(obj, dTumourNumber)
            oTumour = [];
            
            for dTumourIndex=1:length(obj.voTumours)
                if dTumourNumber == obj.voTumours(dTumourIndex).getTumourNumber()
                    oTumour = obj.voTumours(dTumourIndex);
                    break;
                end
            end
        end
        
        function dNumTumours = GetNumberOfTumours(obj)
            dNumTumours = length(obj.voTumours);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> OUTCOME GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function bDidProgress = DidProgressOutOfField(obj)
            bDidProgress = obj.oTreatmentOutcomes.DidProgressOutOfField();
        end
        
        function dtSurvival = GetSurvivalDurationAfterTreatment(obj)
            dtSurvival = obj.oTreatmentOutcomes.GetDateDeceased() - obj.oTreatment.GetTreatmentDate();
        end
        
        function dNumMonths = GetSurvivalDurationAfterTreatment_months(obj)
            dtOneMonth = calendarDuration(0,1,0);
            
            dtSearchDate = obj.oTreatment.GetTreatmentDate();
            dNumMonths = 0;
            
            while dtSearchDate <= obj.oTreatmentOutcomes.GetDateDeceased()
                dNumMonths = dNumMonths + 1;
                dtSearchDate = dtSearchDate + dtOneMonth;
            end
            
            dNumMonths = dNumMonths - 1; % round down (e.g. 1 month and 15 days, is 1 month)
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
                
        function dPrimaryId = GetPrimaryId(obj)
            dPrimaryId = obj.dPrimaryId;
        end
        
        function chSecondaryId = GetSecondaryId(obj)
            chSecondaryId = obj.chSecondaryId;
        end
        
        function dAge = GetAge(obj)
            dAge = obj.dAge;
        end
        
        function eGender = GetGender(obj)
            eGender = obj.eGender;
        end
        
        function oDiagnosis = GetDiagnosis(obj)
            oDiagnosis = obj.oDiagnosis;
        end
        
        function oTreatment = GetTreatment(obj)
            oTreatment = obj.oTreatment;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
                
        function voStudies = GetAllStudiesFromDateWithinTimepoints(obj, dtFromDate, dStartTimepoint_days, dEndTimepoint_days)
            vdTimeFromTimepoint_days = obj.GetImagingStudiesDaysFromTimepoint(dtFromDate);
                        
            vbIncludeStudies = (vdTimeFromTimepoint_days >= dStartTimepoint_days) & (vdTimeFromTimepoint_days <= dEndTimepoint_days);
            
            voStudies = obj.voDatabaseImagingStudies(vbIncludeStudies);
        end
        
        function voStudies = GetImagingStudiesBeforeDate(obj, dtDate)
            dNumStudies = length(obj.voDatabaseImagingStudies);
            vbSelectStudy = false(dNumStudies,1);
            
            for dStudyIndex=1:dNumStudies
                vbSelectStudy(dStudyIndex) = obj.voDatabaseImagingStudies(dStudyIndex).GetImagingDate() <= dtDate;                
            end
            
            voStudies = obj.voDatabaseImagingStudies(vbSelectStudy);
        end
        
        function voStudies = GetImagingStudiesAfterDate(obj, dtDate)            
            dNumStudies = length(obj.voDatabaseImagingStudies);
            vbSelectStudy = false(dNumStudies,1);
            
            for dStudyIndex=1:dNumStudies
                vbSelectStudy(dStudyIndex) = obj.voDatabaseImagingStudies(dStudyIndex).GetImagingDate() > dtDate;                
            end
            
            voStudies = obj.voDatabaseImagingStudies(vbSelectStudy);
        end
        
        function vdDaysFromTimepoint = GetImagingStudiesDaysFromTimepoint(obj, dtTimepoint)
            voStudies = obj.voDatabaseImagingStudies;
            dNumStudies = length(voStudies);
            
            vdDaysFromTimepoint = duration(NaN(dNumStudies,3));
            
            for dStudyIndex=1:dNumStudies
                vdDaysFromTimepoint(dStudyIndex) = voStudies(dStudyIndex).GetImagingDate() - dtTimepoint;
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
