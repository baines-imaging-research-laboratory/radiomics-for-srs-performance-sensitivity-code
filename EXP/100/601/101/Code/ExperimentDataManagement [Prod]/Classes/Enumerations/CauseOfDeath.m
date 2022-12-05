classdef CauseOfDeath
    %CauseOfDeath
    
    properties
        sCauseString
        sDatabaseString
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        neurological ("Neurological", "Neurological", 1)
        extracranial ("Extracranial", "Extracranial", 2)
        neurologicalAndExtracranial ("Neurological & Extracranial", "Neurological+extracranial", 3)
        alive ("Alive", "Alive", 4)
        unknown ("Unknown", "Unknown", 5)
    end
    
    methods
        function enum = CauseOfDeath(sCauseString, sDatabaseString, dFeatureValuesCategoryNumber)
            enum.sCauseString = sCauseString;
            enum.sDatabaseString = sDatabaseString;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function sString = getString(enum)
            sString = enum.sCauseString;
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseValues(sDatabaseString)
            veOptions = enumeration('CauseOfDeath');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).sDatabaseString == sDatabaseString
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'CauseOfDeath:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given database string.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

