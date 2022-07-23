classdef MRScanner
    %MRScanner
    
    properties
        sMRScannerString
        sImageMetadataManufacturer
        sImageMetadataModel
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        SiemensAvanto ("Siemens Avanto", "SIEMENS", "Avanto", 0)
        SiemensMagnetomExpert ("Siemens Magnetom Expert", "SIEMENS", "MAGNETOM EXPERT", 1)
        SiemensMagnetomVision ("Siemens Magnetom Vision", "SIEMENS", "MAGNETOM VISION", 2)
        SiemensSonata ("Siemens Sonata", "SIEMENS", "Sonata", 3)
        GESignaHDxt ("GE Signa HDxt", "GE MEDICAL SYSTEMS", "Signa HDxt", 4)
    end
    
    methods
        function enum = MRScanner(sMRScannerString, sImageMetadataManufacturer, sImageMetadataModel, dFeatureValuesCategoryNumber)
            enum.sMRScannerString = sMRScannerString;
            enum.sImageMetadataManufacturer = sImageMetadataManufacturer;
            enum.sImageMetadataModel = sImageMetadataModel;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function sMRScannerString = getString(enum)
            sMRScannerString = string(num2str(enum.sMRScannerString));
        end
        
        function dNumber = GetFeatureValuesCategoryNumber(obj)
            dNumber = obj.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromImageMetadata(sManufacturer, sModel)
            arguments
                sManufacturer (1,1) string
                sModel (1,1) string
            end
            
            veOptions = enumeration('MRScanner');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).sImageMetadataManufacturer == sManufacturer && veOptions(dOptionIndex).sImageMetadataModel == sModel
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'MRScanner:getEnumFromImageMetadata:NoMatch',...
                    'No match found to the given metadata.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

