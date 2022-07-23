classdef PrimaryCancerActive
    %PrimaryCancerActive
    
    properties
        sString
        sDatabaseString
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        no ("No", "no", 0)
        yes ("Yes", "yes", 1)        
    end
    
    methods
        function enum = PrimaryCancerActive(sString, sDatabaseString, dFeatureValuesCategoryNumber)
            enum.sString = sString;
            enum.sDatabaseString = sDatabaseString;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function sString = getString(enum)
            sString = enum.sString;
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseValues(sDatabaseString)
            veOptions = enumeration('PrimaryCancerActive');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).sDatabaseString == sDatabaseString
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'PrimaryCancerActive:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given database code.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

