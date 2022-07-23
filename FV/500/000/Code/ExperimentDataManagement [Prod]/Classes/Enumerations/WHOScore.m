classdef WHOScore
    %WHOScore
    
    properties
        dScore
        dDatabaseCode        
    end
    
    enumeration
        e0 (0, 0)
        e1 (1, 1)        
        e2 (2, 2)
        e3 (3, 3)
    end
    
    methods
        function enum = WHOScore(dScore, dDatabaseCode)
            enum.dScore = dScore;
            enum.dDatabaseCode = dDatabaseCode;
        end
        
        function sStatusString = getString(enum)
            sStatusString = string(num2str(enum.dScore));
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseValues(dDatabaseCode)
            veOptions = enumeration('WHOScore');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).dDatabaseCode == dDatabaseCode
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'WHOScore:getEnumFromDatabaseValues:NoMatch',...
                    'No match found to the given database code.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

