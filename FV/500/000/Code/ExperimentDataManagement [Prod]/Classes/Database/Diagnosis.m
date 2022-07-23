classdef Diagnosis
    %Diagnosis
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        ePrimarySite %PrimarySite enumeration class
        dtDiagnosisDate % MATLAB dateTime
        ePrimarySiteHistologyResult % HistologyResult enumeration class
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Diagnosis(ePrimarySite, dtDiagnosisDate, ePrimarySiteHistologyResult)
            %obj = Diagnosis(primarySite, diagnosisDate, primarySiteHistologyResult)
            obj.ePrimarySite = ePrimarySite;
            obj.dtDiagnosisDate = dtDiagnosisDate;
            obj.ePrimarySiteHistologyResult = ePrimarySiteHistologyResult;
        end
        
        function obj = Update(obj)
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function ePrimarySite = GetPrimarySite(obj)
            ePrimarySite = obj.ePrimarySite;
        end
        
        function dtDiagnosisDate = GetDiagnosisDate(obj)
            dtDiagnosisDate = obj.dtDiagnosisDate;
        end
        
        function ePrimarySiteHistologyResult = GetPrimarySiteHistologyResult(obj)
            ePrimarySiteHistologyResult = obj.ePrimarySiteHistologyResult;
        end
    end
    
    
    methods (Access = public, Static)
        
        function obj = createFromDatabaseEntries_SRS_VUMC(chPrimarySiteEntry, chDiagnosisDateEntry, chHistologyEntry)
            %obj = createFromDatabaseEntries_SRS_VUMC(primarySiteEntry, diagnosisDateEntry, histologyEntry)
            %   Takes in raw text from database entries and creates the
            %   Diagnosis object from there
            ePrimarySite = PrimarySite.getEnumFromDatabaseLabel(chPrimarySiteEntry);
            dtDiagnosisDate = datetime(chDiagnosisDateEntry, 'InputFormat', 'dd/MM/yyyy');
            eHistologyResult = HistologyResult.getEnumFromDatabaseLabel(chHistologyEntry);
            
            obj = Diagnosis(ePrimarySite, dtDiagnosisDate, eHistologyResult);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
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

