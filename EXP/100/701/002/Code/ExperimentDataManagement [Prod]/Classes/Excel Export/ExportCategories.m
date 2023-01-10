classdef ExportCategories
    %ExportCategories
    
    properties
        columnHeader
        associatedClass % for which class this information can be gathered
    end
    
    enumeration
        % STANDARD (Direct from objects)
        PrimaryId('ID', Patient.empty)
        SecondaryId('Sec. ID', Patient.empty)
        Age('Age', Patient.empty)
        Gender('Gender', Patient.empty)
        
        DiagnosisPrimarySite('Primary Site', Diagnosis.empty)
        DiagnosisDate('Diagnosis Date', Diagnosis.empty)
        DiagnosisHistologyResult('Histology', Diagnosis.empty)
        
        TreatmentType('Treatment', Treatment.empty)
        TreatmentDose('Dose', Treatment.empty)
        TreatmentFractions('Fractions', Treatment.empty)
        TreatmentDate('Treatment Date', Treatment.empty)
        
        GrossTumourVolume('GTV', Tumour.empty)
        
        ImagingStudyDate('Imaging Date', ImagingStudy.empty)
        
        ImagingSeriesDirectoryName('Imaging Dir.', ImagingSeries.empty)
        ImagingSeriesDescription('Description', ImagingSeries.empty)
        ImagingSeriesContrast('Contrast', ImagingSeries.empty)
        ImagingSeriesImageOrientation('Image Orientation', ImagingSeries.empty)    
        ImagingSeriesInPlaneResolution('In Plane Resolution', ImagingSeries.empty)
        ImagingSeriesInPlaneDimensions('In Plane Dimensions', ImagingSeries.empty)
        ImagingSeriesSliceThickness('Slice Thickness', ImagingSeries.empty)
        ImagingSeriesSliceSpacing('Slice Spacing', ImagingSeries.empty)
        ImagingSeriesNumberOfSlices('Number of Slices', ImagingSeries.empty)
        
        ContourNumber('Contour Num.', Contour.empty)        
        ContourName('Contour Name', Contour.empty)
        ContourLabel('Contour Label', Contour.empty)
        ContourType('Contour Type', Contour.empty)
        
        % COMPLEX (More in-depth analysis
        %NumberOfTumours('Num. Tumours', Patient.empty)
    end
    
    methods
        function enum = ExportCategories(columnHeader, associatedClass)
            %enum = ExportCategories(columnHeader, associatedClass)
            enum.columnHeader = columnHeader;
            enum.associatedClass = associatedClass;
        end
        
        function bool = in(obj, columns)
            bool = false;
            
            for i=1:length(columns)
                if obj == columns(i).category
                    bool = true;
                    break;
                end
            end
        end
        
        function col = getColumn(obj, columns)
            col = [];
            
            for i=1:length(columns)
                if obj == columns(i).category
                    col = i;
                    break;
                end
            end
            
            if isempty(col)
                error('ExportCategory not in category list');
            end
        end
    end
    
    methods (Static)
        function sheetHeaders = categoriesToHeaders(categories)
            numCategories = length(categories);
            
            sheetHeaders = cell(1, numCategories);
            
            for i=1:numCategories
                sheetHeaders{1,i} = categories(i).columnHeader;
            end
        end
    end
end

