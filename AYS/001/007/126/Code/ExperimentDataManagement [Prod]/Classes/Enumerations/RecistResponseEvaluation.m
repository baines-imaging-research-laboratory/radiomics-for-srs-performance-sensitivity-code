classdef RecistResponseEvaluation
    %RecistResponseEvaluation
    
    properties
        chAbbreviation
        chName
    end
    
    enumeration
        CR('CR', 'Complete Response');   % No longer visible
        PR('PR', 'Partial Response');    % 30% decrease in diameter
        PD('PD', 'Progressive Disease'); % 20% increase in diameter
        SD('SD', 'Stable Disease');      % None of the above
    end
    
    methods
        function enum = RecistResponseEvaluation(chAbrev, chName)
            enum.chAbbreviation = chAbrev;
            enum.chName = chName;
        end
        
        function chString = GetString(enum)
            chString = enum.chAbbreviation;
        end
        
        function chAbbreviation = GetAbbreviation(enum)
            chAbbreviation = enum.chAbbreviation;
        end
    end
    
    methods (Static = true)
        
        function enum = Score(dStartRecist_mm, dEndRecist_mm)
            if dEndRecist_mm == 0 % No longeder visible
                enum = RecistResponseEvaluation.CR;
            else
                if dEndRecist_mm <= 0.7*dStartRecist_mm % 30% decrease
                    enum = RecistResponseEvaluation.PR;
                elseif dEndRecist_mm >= 1.2*dStartRecist_mm % 20% increase
                    enum = RecistResponseEvaluation.PD;
                else
                    enum = RecistResponseEvaluation.SD; % None of the above
                end
            end
        end
    end
end

