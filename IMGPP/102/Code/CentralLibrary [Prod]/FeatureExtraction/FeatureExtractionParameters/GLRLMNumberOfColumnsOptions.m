classdef GLRLMNumberOfColumnsOptions
    %TODO
    
    properties (SetAccess = immutable, GetAccess = private)
        chParameterFileString        
        bTrimNumberOfColumns
    end
    
    enumeration
        MaxRegionOfInterestDimension ('Max ROI Dimension',          false)
        MaxImageVolumeDimension      ('Max Image Volume Dimension', false)
        LongestRunLength             ('Longest Run Length',         true)
    end
    
    methods (Access = public)
        
        function enum = GLRLMNumberOfColumnsOptions(chParameterFileString, bTrimNumberOfColumns)
            enum.chParameterFileString = chParameterFileString;       
            enum.bTrimNumberOfColumns = bTrimNumberOfColumns;
        end
        
        function chParameterFileString = GetParameterFileString(enum)
            chParameterFileString = enum.chParameterFileString;
        end
        
        function dNumberOfColumns = GetNumberOfColumns(enum, oFeatureExtractionImageVolumeHandler)
            if enum == GLRLMNumberOfColumnsOptions.MaxRegionOfInterestDimension || enum == GLRLMNumberOfColumnsOptions.LongestRunLength
                [vdRowBounds, vdColumnBounds, vdSliceBounds] = oFeatureExtractionImageVolumeHandler.GetCurrentRegionOfInterestMinimalBounds();
                
                dNumberOfColumns = max([...
                    vdRowBounds(2) - vdRowBounds(1) + 1,...
                    vdColumnBounds(2) - vdColumnBounds(1) + 1,...
                    vdSliceBounds(2) - vdSliceBounds(1) + 1]);
            elseif enum == GLRLMNumberOfColumnsOptions.MaxImageVolumeDimension
                dNumberOfColumns = max(oFeatureExtractionImageVolumeHandler.GetRASImageVolume().GetVolumeDimensions());
            else
                error(...
                    'GLRLMNumberOfColumnsOptions:GetNumberOfColumns:InvalidEnum',...
                    'Invalid enumeration option.');
            end
        end
        
        function bTrimNumberOfColumns = GetTrimNumberOfColumns(enum)
            bTrimNumberOfColumns = enum.bTrimNumberOfColumns;
        end
    end
end

