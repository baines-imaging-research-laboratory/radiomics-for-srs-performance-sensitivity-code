classdef BrainMetastasis
    %BrainMetastasis
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
    
    properties (SetAccess = private, GetAccess = public)
        dBrainMetastasisNumber        
        dGrossTumourVolume_mm3 % (GTV) in mm^3    
        
        eLocation BrainMetastasisLocation
        
        dtInFieldProgressionDate datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty % empty means no progression in field
        
        dtRadiationNecrosisDate datetime {ValidationUtils.MustBeEmptyOrScalar} = datetime.empty % empty means no radiation necrosis
        
        eSRSTreatmentParameters SRSTreatmentParameters
        
        ePreTreatmentAppearanceScore BrainMetastasisAppearanceScore
        
        dRegionOfInterestNumberInPreTreatmentImaging (1,1) double
        sRegionOfInterestNameInPreTreatmentImaging (1,1) string
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = public)
        
        function obj = BrainMetastasis(dBrainMetastasisNum, dRegionOfInterestNumberInPreTreatmentImaging, sRegionOfInterestNameInPreTreatmentImaging, dGrossTumourVolume_mm3, eLocation, ePreTreatmentAppearanceScore, eSRSTreatmentParameters, dtInFieldProgressionDate, dtRadiationNecrosisDate)
            arguments
                dBrainMetastasisNum (1,1) double  {mustBeInteger, mustBePositive}
                dRegionOfInterestNumberInPreTreatmentImaging (1,1) double  {mustBeInteger, mustBeNonnegative} % can be 0 if not contoured
                sRegionOfInterestNameInPreTreatmentImaging (1,1) string
                dGrossTumourVolume_mm3 (1,1) double {mustBePositive, mustBeFinite}
                eLocation (1,1) BrainMetastasisLocation
                ePreTreatmentAppearanceScore (1,1) BrainMetastasisAppearanceScore
                eSRSTreatmentParameters (1,1) SRSTreatmentParameters
                dtInFieldProgressionDate datetime {ValidationUtils.MustBeEmptyOrScalar}
                dtRadiationNecrosisDate datetime {ValidationUtils.MustBeEmptyOrScalar}
            end
            
            if isnat(dtInFieldProgressionDate)
                dtInFieldProgressionDate = datetime.empty;
            end
            
            if isnat(dtRadiationNecrosisDate)
                dtRadiationNecrosisDate = datetime.empty;
            end
            
            obj.dBrainMetastasisNumber = dBrainMetastasisNum;
            obj.dRegionOfInterestNumberInPreTreatmentImaging = dRegionOfInterestNumberInPreTreatmentImaging;
            obj.sRegionOfInterestNameInPreTreatmentImaging = sRegionOfInterestNameInPreTreatmentImaging;
            obj.dGrossTumourVolume_mm3 = dGrossTumourVolume_mm3;
            obj.eLocation = eLocation;
            obj.ePreTreatmentAppearanceScore = ePreTreatmentAppearanceScore;
            obj.eSRSTreatmentParameters = eSRSTreatmentParameters;
            obj.dtInFieldProgressionDate = dtInFieldProgressionDate;
            obj.dtRadiationNecrosisDate = dtRadiationNecrosisDate;
        end       
        
        function obj = Update(obj)
        end
        
        function [dFeatureValue, bFeatureIsCategorical] = GetFeatureValue(obj, sFeatureName, c1veCategoryGroups)
            
            switch sFeatureName
                case "GTV Volume"
                    bFeatureIsCategorical = false;
                    
                    dFeatureValue = obj.dGrossTumourVolume_mm3;
                case "Location"
                    bFeatureIsCategorical = true;
                    
                    dFeatureValue = obj.eLocation.GetFeatureValuesCategoryNumber();
                case "Scored MRI Appearance"
                    bFeatureIsCategorical = true;
                    
                    if isempty(c1veCategoryGroups)
                        dFeatureValue = obj.ePreTreatmentAppearanceScore.GetFeatureValuesCategoryNumber();
                    else
                        dFeatureValue = Pateint.RecategorizeVariable(obj.ePreTreatmentAppearanceScore, c1veCategoryGroups);
                    end
                case "Dose And Fractionation"
                    bFeatureIsCategorical = true;
                    
                    if isempty(c1veCategoryGroups)
                        dFeatureValue = obj.eSRSTreatmentParameters.GetFeatureValuesCategoryNumber();
                    else
                        dFeatureValue = Patient.RecategorizeVariable(obj.eSRSTreatmentParameters, c1veCategoryGroups);
                    end                                          
                otherwise
                    dFeatureValue = [];
                    bFeatureIsCategorical = [];
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>> PROPERTY GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<
        
        function eSRSTreatmentParameters = GetSRSTreatmentParameters(obj)
            eSRSTreatmentParameters = obj.eSRSTreatmentParameters;
        end
        
        function dBrainMetastasisNumber = GetBrainMetastasisNumber(obj)
            dBrainMetastasisNumber = obj.dBrainMetastasisNumber;
        end
        
        function dGrossTumourVolume_mm3 = GetGrossTumourVolume_mm3(obj)
            dGrossTumourVolume_mm3 = obj.dGrossTumourVolume_mm3;
        end
        
        function bDidProgress = DidProgressInField(obj)
            bDidProgress = ~isempty(obj.dtInFieldProgressionDate);
        end
        
        function eLocation = GetLocation(obj)
            eLocation = obj.eLocation;
        end
        
        function ePreTreatmentAppearanceScore = GetPreTreatmentAppearanceScore(obj)
            ePreTreatmentAppearanceScore = obj.ePreTreatmentAppearanceScore;
        end
        
        function dRegionOfInterestNumberInPreTreatmentImaging = GetRegionOfInterestNumberInPreTreatmentImaging(obj)
            dRegionOfInterestNumberInPreTreatmentImaging = obj.dRegionOfInterestNumberInPreTreatmentImaging;
        end
        
        function dtInFieldProgressionDate = GetInFieldProgressionDate(obj)
            dtInFieldProgressionDate = obj.dtInFieldProgressionDate;
        end
    end
    
    
    methods (Access = public, Static)
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

