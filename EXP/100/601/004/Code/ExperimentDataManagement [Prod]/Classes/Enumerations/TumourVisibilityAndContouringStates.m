classdef TumourVisibilityAndContouringStates
    %TumourVisibilityAndContouringStates
    
    properties
        bNotValidForStudy
    end
    
    enumeration
        TumourVisible               (false)
        TumourNotVisible            (false)
        
        TumourVisibleMiscontoured   (true)
        TumourVisibleNotContoured   (true)  
        
        TumourNeverContoured        (true)
    end
    
    methods
        function enum = TumourVisibilityAndContouringStates(bNotValidForStudy)
            enum.bNotValidForStudy = bNotValidForStudy;
        end
    end
end

