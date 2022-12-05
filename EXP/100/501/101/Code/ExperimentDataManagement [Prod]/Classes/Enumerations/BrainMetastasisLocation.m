classdef BrainMetastasisLocation
    %BrainMetastasisLocation
    
    properties
        sLocationString
        sDatabaseLabel     
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        infratentorial ("Infratentorial", "infra", 0)
        supratentorial ("Supratentorial", "supra", 1)        
    end
    
    methods
        function enum = BrainMetastasisLocation(sLocationString, sDatabaseLabel, dFeatureValuesCategoryNumber)
            enum.sLocationString = sLocationString;
            enum.sDatabaseLabel = sDatabaseLabel;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function sLocationString = getString(enum)
            sLocationString = string(num2str(enum.sLocationString));
        end
        
        function dNumber = GetFeatureValuesCategoryNumber(obj)
            dNumber = obj.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseLabel(sDatabaseLabel)
            veOptions = enumeration('BrainMetastasisLocation');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).sDatabaseLabel == sDatabaseLabel
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'BrainMetastasisLocation:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given database label.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

