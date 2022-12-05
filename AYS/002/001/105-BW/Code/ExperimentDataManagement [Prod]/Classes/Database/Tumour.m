classdef Tumour
    %Tumour
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dTumourNumber        
        dGrossTumourVolume_mm3 % (GTV) in mm^3    
        
        bTumourIsSupratentorial logical {ValidationUtils.MustBeEmptyOrScalar} = logical.empty
        
        dtInFieldProgressionDate datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty % empty means no progression in field
        
        dtRadiationNecrosisDate datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty % empty means no radiation necrosis
        
        oRecistMeasurements = []
        
        dDose_Gy (1,1) double {mustBeInteger, mustBePositive} = 1
        dNumberOfFractions (1,1) double {mustBeInteger, mustBePositive} = 1
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = Tumour(dTumourNum, dGrossTumourVolume_mm3)
            %obj = Tumour(dTumourNum, dGrossTumourVolume_mm3)
            
            obj.dTumourNumber = dTumourNum;
            obj.dGrossTumourVolume_mm3 = dGrossTumourVolume_mm3;
        end       
        
        function obj = Update(obj, dDose_Gy, dNumberOfFractions)
            obj.dDose_Gy = dDose_Gy;
            obj.dNumberOfFractions = dNumberOfFractions;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function dTumourNumber = GetTumourNumber(obj)
            dTumourNumber = obj.dTumourNumber;
        end
        
        function dGrossTumourVolume_mm3 = GetGrossTumourVolume_mm3(obj)
            dGrossTumourVolume_mm3 = obj.dGrossTumourVolume_mm3;
        end
        
        function bDidProgress = DidProgressInField(obj)
            bDidProgress = ~isempty(obj.dtInFieldProgressionDate);
        end
        
        function bIsSupratentorial = IsSupratentorial(obj)
            bIsSupratentorial = obj.bTumourIsSupratentorial;
        end
        
        function dDose_Gy = GetDose_Gy(obj)
            dDose_Gy = obj.dDose_Gy;
        end
        
        function dNumFx = GetNumberOfFractions(obj)
            dNumFx = obj.dNumberOfFractions;
        end
    end
    
    
    methods (Access = public, Static)
        
        function obj = createFromDatabaseEntries_SRS_VUMC(dTumourNum, dGrossTumourVolumeEntry)
            obj = Tumour(dTumourNum, dGrossTumourVolumeEntry);
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

