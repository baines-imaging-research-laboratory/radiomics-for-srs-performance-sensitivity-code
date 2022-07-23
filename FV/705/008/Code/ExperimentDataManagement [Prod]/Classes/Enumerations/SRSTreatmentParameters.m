classdef SRSTreatmentParameters
    %SRSTreatmentParameters
    
    properties
        dDose_Gy
        dNumberOfFractions
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        e15in1 (15, 1, 1)
        e18in1 (18, 1, 2)
        e21in1 (21, 1, 3)
        e24in3 (24, 3, 4)
    end
    
    methods
        function enum = SRSTreatmentParameters(dDose_Gy, dNumberOfFractions, dFeatureValuesCategoryNumber)
            enum.dDose_Gy = dDose_Gy;
            enum.dNumberOfFractions = dNumberOfFractions;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function chString = getString(enum)
            chString = [num2str(enum.dDose_Gy), 'Gy in ', num2str(enum.dNumberOfFractions)];
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseValues(dDose_Gy, dNumberOfFractions)
            veOptions = enumeration('SRSTreatmentParameters');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).dDose_Gy == dDose_Gy && veOptions(dOptionIndex).dNumberOfFractions == dNumberOfFractions
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'SRSTreatmentParameters:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given dose and fractionation scheme.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

