classdef SteroidStatus
    %SteroidStatus
    
    properties
        sStatusName
        dDatabaseCode
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        good ("Good", 1, 1)
        moderate ("Moderate", 2, 2)
        little ("Little", 3, 3)
        unknown ("Unknown", 4, 4)
        none ("None", 5, 5) % listed as "no symptoms, no dexa"
    end
    
    methods
        function enum = SteroidStatus(sStatusName, dDatabaseCode, dFeatureValuesCategoryNumber)
            enum.sStatusName = sStatusName;
            enum.dDatabaseCode = dDatabaseCode;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function sString = getString(enum)
            sString = enum.sStatusName;
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseCode(dCode)
            veOptions = enumeration('SteroidStatus');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).dDatabaseCode == dCode
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'SteroidStatus:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given database code.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

