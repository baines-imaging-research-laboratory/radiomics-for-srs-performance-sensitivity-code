classdef DicomRTStructClosedPolygonStructure < matlab.mixin.Copyable
    % DicomRTStructClosedPolygonStructure
    %
    % TODO
        
    properties (SetAccess = immutable, GetAccess = public)
        chRegionOfInterestName (1,:) char
        chRegionOfInterestObservationLabel (1,:) char
        chRegionOfInterestInterpretedType (1,:) char
    end
        
    properties (SetAccess = private, GetAccess = public)        
        oImageVolumeGeometry ImageVolumeGeometry {ValidationUtils.MustBeEmptyOrScalar} = ImageVolumeGeometry.empty
        bIsRASObject logical {ValidationUtils.MustBeEmptyOrScalar}
        
        vdDefaultRenderColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector} = [0 0 0]
        
        voClosedPlanarPolygons (:,1) ClosedPlanarPolygon = ClosedPlanarPolygon.empty(0,1)
        vbClosedPlanarPolygonEnabled (:,1) logical
    end
    
    
    
    methods (Access = public)
        
        function obj = DicomRTStructClosedPolygonStructure(stFileMetadata, dContourNumber, oImageVolumeGeometry)
            %obj = DicomContour(dContourNumber, c1m2dPolygonCoords, chRoiName, chObservationLabel, chInterpretedType,  chRtStructFilePath, )
            %obj = DicomContour(dContourNumber, c1m2dPolygonCoords, chRoiName, chObservationLabel, chInterpretedType,  chRtStructFilePath, oDicomImageVolume)
            
            chItemField = ['Item_',num2str(dContourNumber)];
            
            if ~isfield(stFileMetadata.ROIContourSequence.(chItemField), 'ContourSequence')
                warning(...
                    'DicomRTStructLabelMapRegionsOfInterest:Constructor:NoContouringStructures',...
                    'The field ContourSequence was not defined with the RT Struct metadata. Therefore there are no polyons for the ROI.');
                
                voClosedPlanarPolygons = ClosedPlanarPolygon.empty(0,1);
                dNumPolygons = 0;
            else
                stContourSequence = stFileMetadata.ROIContourSequence.(chItemField).ContourSequence;
                
                dNumPolygons = length(fieldnames(stContourSequence));
                
                if dNumPolygons == 0
                    error(...
                        'DicomRTStructLabelMapRegionsOfInterest:Constructor:NoPolygons',...
                        'No polygons were defined for the ROI.');
                end
                
                oFirstPolygon = DicomRTStructClosedPolygonStructure.CreateClosedPlanarPolygonFromContourSequenceMetadata(stContourSequence, 1, oImageVolumeGeometry);
                voClosedPlanarPolygons = repmat(oFirstPolygon, dNumPolygons, 1);
                
                for dPolygonIndex=2:dNumPolygons
                    voClosedPlanarPolygons(dPolygonIndex) = DicomRTStructClosedPolygonStructure.CreateClosedPlanarPolygonFromContourSequenceMetadata(stContourSequence, dPolygonIndex, oImageVolumeGeometry);
                end
                
                % figure out if they align to the same image volume plane
                % dimensions
                vbNotAligned = false(dNumPolygons,1);
                vdPlaneDimension = zeros(dNumPolygons,1);
                
                for dPolygonIndex=1:dNumPolygons
                    dPlaneDimension = voClosedPlanarPolygons(dPolygonIndex).GetImageVolumePlaneDimension();
                    
                    if isempty(dPlaneDimension)
                        vbNotAligned(dPolygonIndex) = true;
                    else
                        vdPlaneDimension(dPolygonIndex) = dPlaneDimension;
                    end
                end
                
                if any(vbNotAligned)
                    warning(...
                        'DicomRTStructClosedPolygonStructure:Constructor:PolygonsNotAlignedWithImageVolume',...
                        'One or more polygons were found to not be aligned with the image volume voxel matrix.');
                else
                    dNumRow = sum(vdPlaneDimension == 1);
                    dNumCol = sum(vdPlaneDimension == 2);
                    dNumSlice = sum(vdPlaneDimension == 3);
                    
                    vdNumPolygonsPerDim = [dNumRow, dNumCol, dNumSlice];
                    
                    [dMaxNum, dMaxDim] = max(vdNumPolygonsPerDim);
                    
                    if dMaxNum ~= dNumPolygons % not already all in same dim
                        if dMaxNum < 0.5*dNumPolygons % if less than half are all the same dim
                            warning(...
                                'DicomRTStructClosedPolygonStructure:Constructor:PolygonsInMultipleDimensions',...
                                'Polygons were found to be contoured in multiple planes in a similar number in each dimension, and so they can not all be reassigned to be in the same plane.');
                        else
                            bValidToSwitch = true;
                            
                            for dPolygonIndex=1:dNumPolygons
                                if ~voClosedPlanarPolygons(dPolygonIndex).IsValidToSetImageVolumePlaneDimensionTo(dMaxDim)
                                    bValidToSwitch = false;
                                    break;
                                end
                            end
                            
                            if ~bValidToSwitch
                                warning(...
                                    'DicomRTStructClosedPolygonStructure:Constructor:PolygonsInMultipleDimensionsCannotBeFixed',...
                                    'The majority of polygons were found to be contoured in the same dimension, but the other polygons cannot be switched to this plane, as it would invalidate the coplanar restrictions.');
                            else
                                for dPolygonIndex=1:dNumPolygons
                                    voClosedPlanarPolygons(dPolygonIndex).SetImageVolumePlaneDimension(dMaxDim);
                                end
                            end
                        end
                    end
                end
            end
            
            % Set properities
            obj.chRegionOfInterestName = stFileMetadata.StructureSetROISequence.(chItemField).ROIName;
            
            if isfield(stFileMetadata, 'RTROIObservationsSequence')                
                if isfield(stFileMetadata.RTROIObservationsSequence.(chItemField), 'ROIObservationLabel')
                    obj.chRegionOfInterestObservationLabel = stFileMetadata.RTROIObservationsSequence.(chItemField).ROIObservationLabel;
                else
                    obj.chRegionOfInterestObservationLabel = '';
                end
                
                obj.chRegionOfInterestInterpretedType = stFileMetadata.RTROIObservationsSequence.(chItemField).RTROIInterpretedType;
            else
                obj.chRegionOfInterestObservationLabel = '';
                obj.chRegionOfInterestInterpretedType = '';
            end
            
            if isfield(stFileMetadata.ROIContourSequence.(chItemField), 'ROIDisplayColor')
                obj.vdDefaultRenderColour_rgb = transpose(stFileMetadata.ROIContourSequence.(chItemField).ROIDisplayColor ./ 255);
            else
                obj.vdDefaultRenderColour_rgb = [1 1 1]; % white
            end
                        
            obj.voClosedPlanarPolygons = voClosedPlanarPolygons;
            obj.vbClosedPlanarPolygonEnabled = true(dNumPolygons,1);
                        
            obj.oImageVolumeGeometry = oImageVolumeGeometry;
        end 
        
        function RestoreToOnDiskGeometry(obj, oOnDiskObj)
            obj.oImageVolumeGeometry = oOnDiskObj.oImageVolumeGeometry;
            obj.bIsRASObject = oOnDiskObj.bIsRASObject;
            
            for dPolygonIndex=1:length(obj.voClosedPlanarPolygons)
                obj.voClosedPlanarPolygons(dPolygonIndex).RestoreToOnDiskGeometry(oOnDiskObj.voClosedPlanarPolygons(dPolygonIndex));
            end
        end
        
        function dRecist_mm = GetRecistFromPolygons(obj)
            dRecist_mm = 0;
            
            for dPolygonIndex = 1:length(obj.voClosedPlanarPolygons)
                if obj.vbClosedPlanarPolygonEnabled(dPolygonIndex)
                    dRecist_mm = max(dRecist_mm, obj.voClosedPlanarPolygons(dPolygonIndex).GetRecist());
                end
            end
        end
        
        function bBool = IsRAS(obj)
            if isempty(obj.bIsRASObject)
                obj.bIsRASObject = obj.oImageVolumeGeometry.IsRAS();
            end
            
            bBool = obj.bIsRASObject;
        end
        
        function dNumPolygons = GetNumberOfEnabledPolygons(obj)
            dNumPolygons = sum(obj.vbClosedPlanarPolygonEnabled);
        end
        
        function dNumPolygons = GetNumberOfPolygons(obj)
            dNumPolygons = length(obj.voClosedPlanarPolygons);
        end
        
        function bEnabled = IsPolygonEnabledByPolygonIndex(obj, dPolygonIndex)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure
                dPolygonIndex (1,1) double {MustBeValidPolygonIndices(obj, dPolygonIndex)}
            end
            
            bEnabled = obj.vbClosedPlanarPolygonEnabled(dPolygonIndex);
        end
        
        function vbEnabled = IsPolygonEnabled(obj)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure
            end
            
            vbEnabled = obj.vbClosedPlanarPolygonEnabled;
        end
        
        function c1m2dPolygonCoords_mm = GetAllPolygonCoordinates_mm(obj)
            dNumEnabledPolygons = obj.GetNumberOfEnabledPolygons();
            
            c1m2dPolygonCoords_mm = cell(1,dNumEnabledPolygons);
            
            vdPolygonIndices = obj.GetAllEnabledPolygonIndices();
            
            for dPolygonIndex=1:dNumEnabledPolygons
                c1m2dPolygonCoords_mm{dPolygonIndex} = obj.voClosedPlanarPolygons(vdPolygonIndices(dPolygonIndex)).GetVertexCoordinates_mm();                
            end
        end
        
        function m2dPolygonCoords_mm = GetPolygonCoordinatesForPolygonNumber_mm(obj, dPolygonNumber)
            dLookupIndex = obj.GetClosedPlanarPolygonIndexFromRegionOfPolygonNumber(dPolygonNumber);
            
            m2dPolygonCoords_mm = obj.voClosedPlanarPolygons{dLookupIndex}.GetVertexCoordinates_mm();
        end     
        
        function dCurrentIndex = GetCurrentClosedPlanarPolygonIndex(obj)
            dCurrentIndex = obj.dCurrentClosedPlanarPolygonIndex;
        end
        
        function ApplyReassignFirstVoxel(obj, oNewImageVolumeGeometry, vdVolumeDimensionReassignment)
            for dPolygonIndex=1:length(obj.voClosedPlanarPolygons)
                obj.voClosedPlanarPolygons(dPolygonIndex).ApplyReassignFirstVoxel(oNewImageVolumeGeometry, vdVolumeDimensionReassignment);
            end
            
            obj.oImageVolumeGeometry = oNewImageVolumeGeometry;
        end
        
        function ApplyNewVoxelResolution(obj, oNewImageVolumeGeometry)
            for dPolygonIndex=1:length(obj.voClosedPlanarPolygons)
                obj.voClosedPlanarPolygons(dPolygonIndex).ApplyNewVoxelResolution(oNewImageVolumeGeometry);
            end
            
            obj.oImageVolumeGeometry = oNewImageVolumeGeometry;
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function chRegionOfInterestName = GetRegionOfInterestName(obj)
            chRegionOfInterestName = obj.chRegionOfInterestName;
        end
        
        function chRegionOfInterestObservationLabel = GetRegionOfInterestObservationLabel(obj)
            chRegionOfInterestObservationLabel = obj.chRegionOfInterestObservationLabel;
        end
            
        function chRegionOfInterestInterpretedType = GetRegionOfInterestInterpretedType(obj)
            chRegionOfInterestInterpretedType = obj.chRegionOfInterestInterpretedType;
        end
        
        function vdDefaultRenderColour_rgb = GetDefaultRenderColour_rgb(obj)
            vdDefaultRenderColour_rgb = obj.vdDefaultRenderColour_rgb;
        end
        
        function m3bMask = GetMask(obj)
            vdVolumeDimensions = obj.oImageVolumeGeometry.GetVolumeDimensions();
            
            m3bMask = false(vdVolumeDimensions);
            
            for dPolygonIndex=1:length(obj.voClosedPlanarPolygons)
                if obj.vbClosedPlanarPolygonEnabled(dPolygonIndex)
                    m3bMask = obj.voClosedPlanarPolygons(dPolygonIndex).AddToMask(m3bMask);
                end
            end
        end
        
        function voClosedPlanarPolygons = GetEnabledClosedPlanarPolygons(obj)
            voClosedPlanarPolygons = obj.voClosedPlanarPolygons(obj.vbClosedPlanarPolygonEnabled);
        end
        
        % >>>> Get polygon vertex coords
        function c1m2dVertexPositionCoords_mm = GetAllEnabledPolygonVertexPositionCoordinates(obj)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure
            end
            
            dNumEnabledPolygons = obj.GetNumberOfEnabledClosedPlanarPolygons;
            
            c1m2dVertexPositionCoords_mm = cell(dNumEnabledPolygons,1);
            
            vdEnabledPolygonIndices = obj.GetEnabledPolygonIndices();
            
            for dPolygonIndex=1:dNumEnabledPolygons
                c1m2dVertexPositionCoords_mm{dPolygonIndex} = obj.voClosedPlanarPolygons(vdEnabledPolygonIndices(dPolygonIndex)).GetVertexPositionCoordinates_mm();
            end
        end
        
        function c1m2dVertexVoxelIndices = GetAllEnabledPolygonVertexVoxelIndices(obj)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure
            end
            
            dNumEnabledPolygons = obj.GetNumberOfEnabledClosedPlanarPolygons;
            
            c1m2dVertexVoxelIndices = cell(dNumEnabledPolygons,1);
            
            vdEnabledPolygonIndices = obj.GetEnabledPolygonIndices();
            
            for dPolygonIndex=1:dNumEnabledPolygons
                c1m2dVertexVoxelIndices{dPolygonIndex} = obj.voClosedPlanarPolygons(vdEnabledPolygonIndices(dPolygonIndex)).GetVertexVoxelIndices();
            end
        end
        
        function c1m2dVertexVoxelIndices = GetAllEnabledPolygonVertexVoxelIndicesInSlice(obj, vdAnatomicalPlaneIndices, eImagingPlaneType)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure {MustBeRAS(obj)}
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger}
                eImagingPlaneType (1,1) ImagingPlaneTypes
            end
            
            dNumEnabledPolygons = obj.GetNumberOfEnabledClosedPlanarPolygons;
            
            c1m2dVertexVoxelIndices = cell(dNumEnabledPolygons,1);
            vbInSlice = false(dNumEnabledPolygons,1);
            
            vdEnabledPolygonIndices = obj.GetEnabledPolygonIndices();
            
            for dPolygonIndex=1:dNumEnabledPolygons
                if obj.voClosedPlanarPolygons(vdEnabledPolygonIndices(dPolygonIndex)).IsInSlice(vdAnatomicalPlaneIndices, eImagingPlaneType)
                    vbInSlice(dPolygonIndex) = true;
                    c1m2dVertexVoxelIndices{dPolygonIndex} = obj.voClosedPlanarPolygons(vdEnabledPolygonIndices(dPolygonIndex)).GetVertexVoxelIndices();
                end
            end
            
            % only select cell array indices that were in slice
            c1m2dVertexVoxelIndices = c1m2dVertexVoxelIndices(vbInSlice);
        end
        
        
        function [c1m2dVertexPositionCoords_mm, vbEnabled] = GetAllPolygonVertexPositionCoordinates(obj)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure {MustBeRAS(obj)}
            end
            
            dNumPolygons = length(obj.voClosedPlanarPolygons);
            
            c1m2dVertexPositionCoords_mm = cell(dNumPolygons,1);
            
            for dPolyIndex=1:dNumPolygons
                c1m2dVertexPositionCoords_mm{dPolyIndex} = obj.voClosedPlanarPolygons(dPolyIndex).GetVertexPositionCoordinates_mm();
            end
            
            vbEnabled = obj.vbClosedPlanarPolygonEnabled;
        end
        
        function [c1m2dVertexVoxelIndices, vbEnabled] = GetAllPolygonVertexVoxelIndices(obj)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure {MustBeRAS(obj)}
            end
            
            dNumPolygons = length(obj.voClosedPlanarPolygons);
            
            c1m2dVertexVoxelIndices = cell(dNumPolygons,1);
            
            for dPolyIndex=1:dNumPolygons
                c1m2dVertexVoxelIndices{dPolyIndex} = obj.voClosedPlanarPolygons(dPolyIndex).GetVertexVoxelIndices();
            end
            
            vbEnabled = obj.vbClosedPlanarPolygonEnabled;
        end
        
        
        function [c1m2dVertexVoxelIndices, vbEnabled, vdPolygonIndices] = GetAllPolygonVertexVoxelIndicesInSlice(obj, vdAnatomicalPlaneIndices, eImagingPlaneType)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure {MustBeRAS(obj)}
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger}
                eImagingPlaneType (1,1) ImagingPlaneTypes
            end
            
            dNumPolygons = length(obj.voClosedPlanarPolygons);
            
            c1m2dVertexVoxelIndices = cell(dNumPolygons,1);
            vbInSlice = false(dNumPolygons,1);
            
            for dPolygonIndex=1:dNumPolygons
                if obj.voClosedPlanarPolygons(dPolygonIndex).IsInSlice(vdAnatomicalPlaneIndices, eImagingPlaneType)
                    vbInSlice(dPolygonIndex) = true;
                    c1m2dVertexVoxelIndices{dPolygonIndex} = obj.voClosedPlanarPolygons(dPolygonIndex).GetVertexVoxelIndices();
                end
            end
            
            % only select cell array indices that were in slice
            c1m2dVertexVoxelIndices = c1m2dVertexVoxelIndices(vbInSlice);
            vbEnabled = obj.vbClosedPlanarPolygonEnabled(vbInSlice);
            vdPolygonIndices = find(vbInSlice);
        end
        
        function [m2dVertexVoxelIndices, bEnabled] = GetPolygonVertexVoxelIndicesByPolygonIndex(obj, dPolygonIndex)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure
                dPolygonIndex (1,1) double {MustBeValidPolygonIndices(obj, dPolygonIndex)}
            end
            
            m2dVertexVoxelIndices = obj.voClosedPlanarPolygons(dPolygonIndex).GetVertexVoxelIndices();
            bEnabled = obj.vbClosedPlanarPolygonEnabled(dPolygonIndex);
        end
        
        
        % >>>> Number of polygons
        function dNumberOfPolygons = GetNumberOfClosedPlanarPolygons(obj)
            dNumberOfPolygons = length(obj.voClosedPlanarPolygons);
        end
                
        function dNumberOfPolygons = GetNumberOfEnabledClosedPlanarPolygons(obj)
            dNumberOfPolygons = sum(obj.vbClosedPlanarPolygonEnabled);
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> SETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function SetPolygonEnabledByPolygonIndex(obj, dPolygonIndex, bEnabled)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure
                dPolygonIndex (1,1) double {MustBeValidPolygonIndices(obj, dPolygonIndex)}
                bEnabled (1,1) logical
            end
            
            obj.vbClosedPlanarPolygonEnabled(dPolygonIndex) = bEnabled;            
        end
        
        function SetPolygonsEnabled(obj, vbEnabled)
            arguments
                obj (1,1) DicomRTStructClosedPolygonStructure
                vbEnabled (:,1) logical
            end
            
            obj.vbClosedPlanarPolygonEnabled(:) = vbEnabled;            
        end
    end
    
        
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
                        
            cpObj.voClosedPlanarPolygons = copy(obj.voClosedPlanarPolygons);            
        end
    end
    
    methods (Access = private)
        function dIndex = GetClosedPlanarPolygonIndexFromRegionOfPolygonNumber(obj, dPolygonNumber)
            vdIndices = 1:length(obj.voClosedPlanarPolygons);
            vdIndices = vdIndices(obj.vbClosedPlanarPolygonEnabled);
            
            dIndex = vdIndices(dPolygonNumber);
        end
        
        function MustBeRAS(obj)
            if ~obj.IsRAS()
                error(...
                    'DicomRTStructClosedPolygonStructure:MustBeRAS:Invalid',...
                    'The object must be in an RAS image volume geometry.');
            end
        end
        
        function MustBeValidPolygonIndices(obj, vdPolygonIndices)
            arguments
                obj
                vdPolygonIndices (1,:) double {mustBePositive, mustBeInteger}
            end
            
            mustBeLessThanOrEqual(vdPolygonIndices, length(obj.voClosedPlanarPolygons));
        end
    end
    
    methods (Access = private, Static = true)
        function oPolygon = CreateClosedPlanarPolygonFromContourSequenceMetadata(stContourSequence, dPolygonIndex, oImageVolumeGeometry)
            
            if ~strcmp(stContourSequence.(['Item_', num2str(dPolygonIndex)]).ContourGeometricType, 'CLOSED_PLANAR') && ~strcmp(stContourSequence.(['Item_', num2str(dPolygonIndex)]).ContourGeometricType, 'POINT')
                error(...
                    'DicomRTStructLabelMapRegionsOfInterest:Constructor:InvalidPolygonType',...
                    'Only CLOSED_PLANAR polygon RT Structs are supported.');
            end
            
            vdCoords_mm = stContourSequence.(['Item_', num2str(dPolygonIndex)]).ContourData;
            
            m2dCoords_mm = reshape(vdCoords_mm,[3,length(vdCoords_mm)/3])';
            
            % convert from LPS to RAS:
            m2dCoords_mm(:,1) = -m2dCoords_mm(:,1);
            m2dCoords_mm(:,2) = -m2dCoords_mm(:,2);
            
            oPolygon = ClosedPlanarPolygon(m2dCoords_mm, oImageVolumeGeometry);
        end
    end
end
