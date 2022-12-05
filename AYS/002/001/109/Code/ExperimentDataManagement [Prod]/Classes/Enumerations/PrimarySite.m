classdef PrimarySite
    %PrimarySite
    
    properties
        chSiteName
        chDatabaseLabel
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        lung('Lung', 'lung', 0)
        renal('Renal', 'grawitz', 1)
        melanoma('Melanoma','melanoma', 2)
        breast('Breast','breast', 3)
        colorectal('Colon','colon', 4)
        oesophageal('Oesophageal','oesofagu', 5)
        thyroid('Thyroid','thyroid', 6)
        other('Other','other', 7)
    end
    
    methods
        function enum = PrimarySite(chSiteName, chDatabaseLabel, dFeatureValuesCategoryNumber)
            enum.chSiteName = chSiteName;
            enum.chDatabaseLabel = chDatabaseLabel;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function chString = getString(enum)
            chString = enum.chSiteName;
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseLabel(chLabel)
            switch chLabel
                case PrimarySite.lung.chDatabaseLabel
                    enum = PrimarySite.lung;
                case PrimarySite.renal.chDatabaseLabel
                    enum = PrimarySite.renal;
                case PrimarySite.melanoma.chDatabaseLabel
                    enum = PrimarySite.melanoma;
                case PrimarySite.breast.chDatabaseLabel
                    enum = PrimarySite.breast;
                case PrimarySite.colorectal.chDatabaseLabel
                    enum = PrimarySite.colorectal;
                case PrimarySite.oesophageal.chDatabaseLabel
                    enum = PrimarySite.oesophageal;
                case PrimarySite.thyroid.chDatabaseLabel
                    enum = PrimarySite.thyroid;
                case PrimarySite.other.chDatabaseLabel
                    enum = PrimarySite.other;
                otherwise
                    error(['Invalid database Primary Site label: ', chLabel]);
            end
        end
    end
end

