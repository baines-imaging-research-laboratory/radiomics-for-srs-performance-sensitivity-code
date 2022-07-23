classdef BrainMetastasisAppearanceScore
    %BrainMetastasisAppearanceScore
    
    properties
        chScoreName
        dDatabaseCode
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        homogeneous ('Homogeneous', 1, 1)
        heterogeneous ('Heterogeneous', 2, 2)
        cysticSimple ('Cystic - Simple', 3, 3)
        cysticComplex ('Cystic - Complex', 4, 4)
        necrosis ('Necrosis', 5, 5)
    end
    
    methods
        function enum = BrainMetastasisAppearanceScore(chScoreName, dDatabaseCode, dFeatureValuesCategoryNumber)
            enum.chScoreName = chScoreName;
            enum.dDatabaseCode = dDatabaseCode;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function chString = getString(enum)
            chString = enum.chScoreName;
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseCode(dCode)
            switch dCode
                case BrainMetastasisAppearanceScore.homogeneous.dDatabaseCode
                    enum = BrainMetastasisAppearanceScore.homogeneous;
                case BrainMetastasisAppearanceScore.heterogeneous.dDatabaseCode
                    enum = BrainMetastasisAppearanceScore.heterogeneous;
                case BrainMetastasisAppearanceScore.cysticSimple.dDatabaseCode
                    enum = BrainMetastasisAppearanceScore.cysticSimple;
                case BrainMetastasisAppearanceScore.cysticComplex.dDatabaseCode
                    enum = BrainMetastasisAppearanceScore.cysticComplex;
                case BrainMetastasisAppearanceScore.necrosis.dDatabaseCode
                    enum = BrainMetastasisAppearanceScore.necrosis;
                otherwise
                    error(['Invalid database code: ', num2str(dCode)]);
            end
        end
    end
end

