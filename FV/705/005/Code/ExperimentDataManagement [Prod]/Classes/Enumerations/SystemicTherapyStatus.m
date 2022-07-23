classdef SystemicTherapyStatus
    %SystemicTherapyStatus
    
    properties
        sStatusString
        dDatabaseCode
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        none ("None", 1, 1)
        palliative ("Palliative", 2, 2)        
        radical ("Radical", 3, 3)
    end
    
    methods
        function enum = SystemicTherapyStatus(sStatusString, dDatabaseCode, dFeatureValuesCategoryNumber)
            enum.sStatusString = sStatusString;
            enum.dDatabaseCode = dDatabaseCode;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function sStatusString = getString(enum)
            sStatusString = enum.sStatusString;
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseValues(dDatabaseCode)
            veOptions = enumeration('SystemicTherapyStatus');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).dDatabaseCode == dDatabaseCode
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'SystemicTherapyStatus:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given database code.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

