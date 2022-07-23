classdef HistologyResult
    %HistologyResult
    
    properties
        chResultName
        chDatabaseLabel
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        adenocarcinoma('Adenocarcinoma', 'adeno', 0)
        nonSmallCellLungCarcinoma('Non-Small Cell Lung Carcinoma', 'nsclc', 1)
        squamousCarcinoma('Squamous Call Carcinoma','squamous', 2)
        melanoma('Melanoma','melanoma', 3)
        urothelialCarcinoma('Urothelial Carcinoma','urotheel', 4)
        renal('Renal','grawitz', 5)
        papillary('Papillary','papilair', 6)
        smallCell('Small Cell Lung Carcinoma','smallcel', 7)
        sarcoma('Sarcoma','sarcoom', 8)
    end
    
    methods
        function enum = HistologyResult(chResultName, chDatabaseLabel, dFeatureValuesCategoryNumber)
            enum.chResultName = chResultName;
            enum.chDatabaseLabel = chDatabaseLabel;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function chString = getString(enum)
            chString = enum.chResultName;
        end
        
        function dCode = GetFeatureValuesCategoryNumber(enum)
            dCode = enum.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromDatabaseLabel(chLabel)
            switch chLabel
                case HistologyResult.adenocarcinoma.chDatabaseLabel
                    enum = HistologyResult.adenocarcinoma;
                case HistologyResult.nonSmallCellLungCarcinoma.chDatabaseLabel
                    enum = HistologyResult.nonSmallCellLungCarcinoma;
                case HistologyResult.squamousCarcinoma.chDatabaseLabel
                    enum = HistologyResult.squamousCarcinoma;
                case HistologyResult.melanoma.chDatabaseLabel
                    enum = HistologyResult.melanoma;
                case HistologyResult.urothelialCarcinoma.chDatabaseLabel
                    enum = HistologyResult.urothelialCarcinoma;
                case HistologyResult.renal.chDatabaseLabel
                    enum = HistologyResult.renal;
                case HistologyResult.papillary.chDatabaseLabel
                    enum = HistologyResult.papillary;
                case HistologyResult.smallCell.chDatabaseLabel
                    enum = HistologyResult.smallCell;
                case HistologyResult.sarcoma.chDatabaseLabel
                    enum = HistologyResult.sarcoma;
                otherwise
                    error(['Invalid database Histology Result label: ', chLabel]);
            end
        end
    end
end

