classdef Gender
    %Gender
    
    properties
        chAbbreviation
        chName
        chDatabaseLabel
        dFeatureValuesCategoryNumber        
    end
    
    enumeration
        male('M', 'Male', 'male', 0);
        female('F', 'Female', 'female', 1);
    end
    
    methods
        function enum = Gender(chAbrev, chName, chDatabaseLabel, dFeatureValuesCategoryNumber)
            enum.chAbbreviation = chAbrev;
            enum.chName = chName;
            enum.chDatabaseLabel = chDatabaseLabel;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function chString = getString(enum)
            chString = enum.chAbbreviation;
        end
        
        function dFeatureValuesCategoryNumber = GetFeatureValuesCategoryNumber(obj)
            dFeatureValuesCategoryNumber = obj.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseLabel(chLabel)
            switch chLabel
                case Gender.male.chDatabaseLabel
                    enum = Gender.male;
                case Gender.female.chDatabaseLabel
                    enum = Gender.female;
                otherwise
                    error(['Invalid database Gender label: ', chLabel]);
            end
        end
    end
end

