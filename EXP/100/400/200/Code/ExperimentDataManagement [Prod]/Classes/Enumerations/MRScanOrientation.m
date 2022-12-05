classdef MRScanOrientation
    %MRScanOrientation
    
    properties
        sMRScanOrientationString
        dRowAxisUnitVectorMaxDimension
        dFeatureValuesCategoryNumber
    end
    
    enumeration
        Axial ("Axial", 1, 1)
        Sagittal ("Sagittal", 2, 2)
        Coronal ("Coronal", 3, 3)
    end
    
    methods
        function enum = MRScanOrientation(sMRScanOrientationString, dRowAxisUnitVectorMaxDimension, dFeatureValuesCategoryNumber)
            enum.sMRScanOrientationString = sMRScanOrientationString;
            enum.dRowAxisUnitVectorMaxDimension = dRowAxisUnitVectorMaxDimension;
            enum.dFeatureValuesCategoryNumber = dFeatureValuesCategoryNumber;
        end
        
        function sMRScanOrientationString = getString(enum)
            sMRScanOrientationString = string(num2str(enum.sMRScanOrientationString));
        end
        
        function dNumber = GetFeatureValuesCategoryNumber(obj)
            dNumber = obj.dFeatureValuesCategoryNumber;
        end
    end
    
    methods (Static)
        function enum = getEnumFromRowAxisUnitVectorMaxDimension(dRowAxisUnitVectorMaxDimension)
            veOptions = enumeration('MRScanOrientation');
            
            dMatch = [];
            
            for dOptionIndex=1:length(veOptions)
                if veOptions(dOptionIndex).dRowAxisUnitVectorMaxDimension == dRowAxisUnitVectorMaxDimension
                    dMatch = dOptionIndex;
                    break;
                end
            end
            
            if isempty(dMatch)
                error(...
                    'MRScanOrientation:getEnumFromRowAxisUnitVectorMaxDimension:NoMatch',...
                    'No match found to the given metadata.');
            end
            
            enum = veOptions(dMatch);
        end
    end
end

