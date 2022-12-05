classdef DSGPAGroup
    %DSGPAGroup
    
    properties
        dGroupNumber
        dDatabaseCode        
    end
    
    enumeration
        Group1 (1, 1)
        Group2 (2, 2)       
        Group3 (3, 3)
        Group4 (4, 4)
    end
    
    methods
        function enum = DSGPAGroup(dGroupNumber, dDatabaseCode)
            enum.dGroupNumber = dGroupNumber;
            enum.dDatabaseCode = dDatabaseCode;
        end
        
        function sStatusString = getString(enum)
            sStatusString = string(num2str(enum.dGroupNumber));
        end
        
        function dGroupNumber = GetGroupNumber(enum)
            dGroupNumber = enum.dGroupNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseValues(dDatabaseCode)
            veOptions = enumeration('DSGPAGroup');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).dDatabaseCode == dDatabaseCode
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'DSGPAGroup:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given database code.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

