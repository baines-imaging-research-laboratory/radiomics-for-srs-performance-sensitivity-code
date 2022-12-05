classdef TreatmentType
    %TreatmentType
    
    properties
        chName
        chLongName
    end
    
    enumeration
        SRS('SRS', 'Stereotactic Radiosurgery');
        WBRT('WBRT', 'Whole-Brain Radiotherapy');
        SIB('SIB', 'Simultaneous Infield Boost');
    end
    
    methods
        function enum = TreatmentType(chName, chLongName)
            enum.chName = chName;
            enum.chLongName = chLongName;
        end
        
        function chString = getString(enum)
            chString = enum.chName;
        end
    end
end

