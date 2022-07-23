classdef DicomRTStructLabelMapRegionsOfInterest < LabelMapRegionsOfInterest & RegionsOfInterestFromPolygons
    %DicomRTStructLabelMapRegionsOfInterest
    %
    % ???
    
    % Primary Author: David DeVries
    % Created: Apr 22, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
     
    properties (SetAccess = private, GetAccess = public)
        voClosedPolygonStructures (:,1) DicomRTStructClosedPolygonStructure = DicomRTStructClosedPolygonStructure.empty(0,1)
        vbClosedPolygonStructureEnabled (:,1) logical
        
        vdSelectedRegionsOfInterest (:,1) double
        
        dLastImagingObjectTransformBasedOnPolygons = 1        
    end
    
    properties (SetAccess = immutable, GetAccess = public)
        chFilePath = []
        stFileMetadata = []
        dNumberOfRegionsOfInterestInFile (1,1) double = 0
    end    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
           
    methods (Access = public)
        
        function obj = DicomRTStructLabelMapRegionsOfInterest(chFilePath, oDicomImageVolume)
            %obj = NIfTILabelMapRegionsOfInterest(chFilePath)
            %
            % SYNTAX:
            %  obj = NIfTILabelMapRegionsOfInterest(chFilePath, oImageVolume)            
            %
            % DESCRIPTION:
            %  Constructor for NewClass
            %
            % INPUT ARGUMENTS:
            %  input1: What input1 is
            %  input2: What input2 is. If input2's description is very, very
            %         long wrap it with tabs to align the second line, and
            %         then the third line will automatically be in line
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
                         
            % read in dimensions, num. ROIs from file
            arguments
                chFilePath (1,:) char
                oDicomImageVolume (1,1) DicomImageVolume
            end
            
            
            stFileMetadata = dicominfo(chFilePath);
            
            if ~strcmp(stFileMetadata.Modality, 'RTSTRUCT')
                error(...
                    'DicomRTStructLabelMapRegionsOfInterest:Constructor:InvalidFile',...
                    'The provided file path is not a valid RT Structure file.');
            end
            
            stImageVolumeMetadata = oDicomImageVolume.GetFileMetadata();
            chReferenceSeriesUID = stImageVolumeMetadata.SeriesInstanceUID;
            
            % Validate Series UID
            chSeriesInstanceUID = stFileMetadata.ReferencedFrameOfReferenceSequence.Item_1.RTReferencedStudySequence.Item_1.RTReferencedSeriesSequence.Item_1.SeriesInstanceUID;
            
            if ~strcmp(chSeriesInstanceUID, chReferenceSeriesUID)
                warning(...
                    'DicomRTStructLabelMapRegionsOfInterest:Constructor:SeriesInstanceUIDMismatch',...
                    'The series instance UID of the Dicom image volume and RT Struct file do not match. This may mean the two files use different coordinate systems.');
            end
            
            dNumberOfRois = length(fieldnames(stFileMetadata.ROIContourSequence));
            
            % super-class constructor
            oImageVolumeGeometry = oDicomImageVolume.GetOnDiskImageVolumeGeometry();
            obj@LabelMapRegionsOfInterest(oImageVolumeGeometry, dNumberOfRois);            
            
            % set properities
            obj.chFilePath = chFilePath;
            obj.stFileMetadata = stFileMetadata;
            
            voClosedPolygonStructures = DicomRTStructLabelMapRegionsOfInterest.GetClosedPolygonStructuresFromFileMetadata(stFileMetadata, oImageVolumeGeometry, dNumberOfRois);
            
            obj.voClosedPolygonStructures = voClosedPolygonStructures;
            obj.vbClosedPolygonStructureEnabled = true(length(voClosedPolygonStructures),1); % default by having all structure "on"
            
            obj.vdSelectedRegionsOfInterest = 1:dNumberOfRois;
            obj.dNumberOfRegionsOfInterestInFile = dNumberOfRois;
        end
        
        function SelectRegionsOfInterest(obj, vdRegionOfInterestNumbers)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                vdRegionOfInterestNumbers (:,1) double {MustBeValidRegionOfInterestNumbers(obj, vdRegionOfInterestNumbers)}
            end
            
            if ~isscalar(obj.voAppliedImagingObjectTransforms)
                error(...
                    'DicomRTStructLabelMapRegionsOfInterest:SelectRegionsOfInterest:InvalidState',...
                    'ROIs can only be selected before any transforms have been applied.');
            end
            
            obj.vdSelectedRegionsOfInterest = obj.vdSelectedRegionsOfInterest(vdRegionOfInterestNumbers);
            
            obj.voClosedPolygonStructures = obj.voClosedPolygonStructures(vdRegionOfInterestNumbers);
            obj.vbClosedPolygonStructureEnabled = obj.vbClosedPolygonStructureEnabled(vdRegionOfInterestNumbers);
            
            obj.dNumberOfRegionsOfInterest = length(vdRegionOfInterestNumbers);
        end
        
        function chFilePath = GetOriginalFilePath(obj)
            chFilePath = obj.chFilePath;
        end
                
        function m2dColours_rgb = GetDefaultRenderColours_rgb(obj)
            dNumRois = obj.GetNumberOfRegionsOfInterest();
            
            m2dColours_rgb = zeros(dNumRois,3);
            
            for dRoiIndex=1:dNumRois
                m2dColours_rgb(dRoiIndex,:) = obj.GetDefaultRenderColourByRegionOfInterestNumber_rgb(dRoiIndex);                    
            end
        end
        
        function vdColour_rgb = GetDefaultRenderColourByRegionOfInterestNumber_rgb(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            vdColour_rgb = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetDefaultRenderColour_rgb();
        end
        
        function oRenderer = GetRenderer(obj)
            oRenderer = GetRenderer@RegionsOfInterestFromPolygons(obj);
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> GETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                
        function vsRoiNames = GetRegionsOfInterestNames(obj)
            vsRoiNames = strings(obj.GetNumberOfRegionsOfInterest(),1);
            
            for dRoiNumber=1:obj.GetNumberOfRegionsOfInterest()
                vsRoiNames(dRoiNumber) = string(obj.voClosedPolygonStructures(dRoiNumber).GetRegionOfInterestName());
            end
        end
        
        function vsRoiLabels = GetRegionsOfInterestObservationLabels(obj)
            vsRoiLabels = strings(obj.GetNumberOfRegionsOfInterest(),1);
            
            for dRoiNumber=1:obj.GetNumberOfRegionsOfInterest()
                vsRoiLabels(dRoiNumber) = string(obj.voClosedPolygonStructures(dRoiNumber).GetRegionOfInterestObservationLabel());
            end
        end
        
        function vsRoiTypes = GetRegionsOfInterestInterpretedTypes(obj)
            vsRoiTypes = strings(obj.GetNumberOfRegionsOfInterest(),1);
            
            for dRoiNumber=1:obj.GetNumberOfRegionsOfInterest()
                vsRoiTypes(dRoiNumber) = string(obj.voClosedPolygonStructures(dRoiNumber).GetRegionOfInterestInterpretedType());
            end
        end
        
        function dRecist_mm = GetRecistFromPolygonsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            if obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                dRecist_mm = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetRecistFromPolygons();
            else
                dRecist_mm = 0;
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>> POLYGON COORD GETTERS <<<<<<<<<<<<<<<<<<<<<<
        
        % >> ENABLED POLYGONS FOR ROI:
        % >>>> VERTEX POSITION COORDINATES:
        function c1m2dVertexPositionCoords_mm = GetAllEnabledPolygonVertexPositionCoordinatesByRoiNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            if obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)            
                c1m2dVertexPositionCoords_mm = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetAllEnabledPolygonVertexPositionCoordinates();
            else
                c1m2dVertexPositionCoords_mm = {};
            end
        end
        
        % >>>> VOXEL INDICES:
        function c1m2dVertexVoxelIndices = GetAllEnabledPolygonVertexVoxelIndicesByRoiNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            if obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)            
                c1m2dVertexVoxelIndices = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetAllEnabledPolygonVertexVoxelIndices();
            else
                c1m2dVertexVoxelIndices = {};
            end
        end
        
        % >>>> VOXEL INDICES FOR SLICE:
        function c1m2dVertexVoxelIndices = GetAllEnabledPolygonVertexVoxelIndicesInSliceByRoiNumber(obj, dRegionOfInterestNumber, vdAnatomicalPlaneIndices, eImagingPlaneType)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest {MustBeRAS(obj)}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger}
                eImagingPlaneType (1,1) ImagingPlaneTypes
            end
            
            obj.ForceApplyAllTransforms();
            
            if obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)            
                c1m2dVertexVoxelIndices = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetAllEnabledPolygonVertexVoxelIndicesInSlice(vdAnatomicalPlaneIndices, eImagingPlaneType);            
            else
                c1m2dVertexVoxelIndices = {};
            end
        end
        
        % >> ALL POLYGONS FOR ROI:
        
        function voClosedPlanarPolygons = GetEnabledClosedPlanarPolygonsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            if obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                voClosedPlanarPolygons = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetEnabledClosedPlanarPolygons();
            else
                voClosedPlanarPolygons = ClosedPlanarPolygons.empty;
            end
        end
        
        
        % >>>> VERTEX POSITION COORDINATES:
        function [c1m2dVertexPositionCoords_mm, vbEnabled] = GetAllPolygonVertexPositionCoordinatesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            [c1m2dVertexPositionCoords_mm, vbEnabled] = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetAllPolygonVertexPositionCoordinates();        
            
            if ~obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                vbEnabled(:) = false;
            end
        end
        
        % >>>> VOXEL INDICES:
        function [c1m2dVertexVoxelIndices, vbEnabled] = GetAllPolygonVertexVoxelIndicesByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            obj.ForceApplyAllTransforms();
            
            [c1m2dVertexVoxelIndices, vbEnabled] = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetAllPolygonVertexVoxelIndices();        
            
            if ~obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                vbEnabled(:) = false;
            end
        end
        
        % >>>> VOXEL INDICES FOR SLICE:
        function [c1m2dVertexVoxelIndices, vbEnabled, vdPolygonIndices] = GetAllPolygonVertexVoxelIndicesInSliceByRegionOfInterestNumber(obj, dRegionOfInterestNumber, vdAnatomicalPlaneIndices, eImagingPlaneType)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest {MustBeRAS(obj)}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger}
                eImagingPlaneType (1,1) ImagingPlaneTypes
            end
            
            obj.ForceApplyAllTransforms();
            
            [c1m2dVertexVoxelIndices, vbEnabled, vdPolygonIndices] = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetAllPolygonVertexVoxelIndicesInSlice(vdAnatomicalPlaneIndices, eImagingPlaneType); 
            
            if ~obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                vbEnabled(:) = false;
            end
        end
        
        % >> POLYGON BY STRUCTURE AND POLYGON INDICES
        function [m2dVertexVoxelIndices, bEnabled] = GetPolygonVertexVoxelIndicesByRoiNumberAndPolygonIndex(obj, dRegionOfInterestNumber, dPolygonIndex)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dPolygonIndex (1,1) double
            end
            
            obj.ForceApplyAllTransforms();
            
            [m2dVertexVoxelIndices, bEnabled] = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetPolygonVertexVoxelIndicesByPolygonIndex(dPolygonIndex);
            
            if ~obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                bEnabled = false;
            end
        end
        
        % >> NUMBER STRUCTURES/POYLGONS IN STRUCTURE
                
        function dNumRois = GetNumberOfRegionsOfInterestWithEnabledPolygons(obj)
            dNumRois = sum(obj.vbClosedPolygonStructureEnabled);
        end
        
        function dNumEnabledPolygons = GetNumberOfEnabledPolygonsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            if obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                dNumEnabledPolygons = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetNumberOfEnabledClosedPlanarPolygons();
            else
                dNumEnabledPolygons = 0;
            end
        end
        
        function dNumPolygons = GetNumberOfPolygonsByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            dNumPolygons = obj.voClosedPolygonStructures(dRegionOfInterestNumber).GetNumberOfClosedPlanarPolygons();
        end
        
        % >> GET ENABLED
        function vbEnabled = AreRegionsOfInterestPolygonsEnabled(obj)
            vbEnabled = obj.vbClosedPolygonStructureEnabled;
        end        
        
        function bEnabled = ArePolygonsEnabledByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
            end
            
            bEnabled = obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber);
        end
        
        function bEnabled = IsPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj, dRegionOfInterestNumber, dPolygonIndex)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dPolygonIndex (1,1) double
            end
            
            if obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                bEnabled = obj.voClosedPolygonStructures(dRegionOfInterestNumber).IsPolygonEnabledByPolygonIndex(dPolygonIndex);
            else
                bEnabled = false;
            end
        end
        
        function vbEnabled = IsPolygonEnabledByRegionOfInterestNumber(obj, dRegionOfInterestNumber)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}                
            end
            
            vbEnabled = obj.voClosedPolygonStructures(dRegionOfInterestNumber).IsPolygonEnabled();
            
            if ~obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber)
                vbEnabled(:) = false;
            end
        end
        
        
        % >>>>>>>>>>>>>> STRUCTURE/POLYGON ENABLED SETTERS <<<<<<<<<<<<<<<<
        
        function SetEnabledByRegionOfInterestNumber(obj, dRegionOfInterestNumber, bEnabled)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bEnabled (1,1) logical
            end
            
            bExistingValue = obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber);
            
            if bExistingValue ~= bEnabled               
                obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber) = bEnabled;             
                
                obj.RecomputeRegionOfInterestLabelMapForPolygonEnabledChange(dRegionOfInterestNumber);
            end
        end
        
        function SetPolygonEnabledByRegionOfInterestNumberAndPolygonIndex(obj, dRegionOfInterestNumber, dPolygonIndex, bEnabled)
            arguments
                obj (1,1) DicomRTStructLabelMapRegionsOfInterest
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dPolygonIndex (1,1) double
                bEnabled (1,1) logical
            end
            
            bExistingValue = obj.voClosedPolygonStructures(dRegionOfInterestNumber).IsPolygonEnabledByPolygonIndex(dPolygonIndex);
                        
            if bExistingValue ~= bEnabled                
                obj.voClosedPolygonStructures(dRegionOfInterestNumber).SetPolygonEnabledByPolygonIndex(dPolygonIndex, bEnabled);
                
                vbPolysEnabled = obj.voClosedPolygonStructures(dRegionOfInterestNumber).IsPolygonEnabled();
                
                if sum(vbPolysEnabled) == 1 % enable structure since first polygon was enabled
                    obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber) = true;
                elseif sum(vbPolysEnabled) == 0 % disable structure if all polygons disabled
                    obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber) = false;
                end
                
                obj.RecomputeRegionOfInterestLabelMapForPolygonEnabledChange(dRegionOfInterestNumber);
            end
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
        
    methods (Access = protected)
        
        function m3uiLabelMaps = LoadLabelMapsFromDisk(obj)     
            
            % create label maps from polygons
            vdVolumeDimensions = obj.GetOnDiskImageVolumeGeometry().GetVolumeDimensions();
                        
            m3uiLabelMaps = zeros(vdVolumeDimensions, obj.GetLabelMapUintType(obj.GetNumberOfRegionsOfInterest()));
            
            % restore original data to closed polygon structures
            dNumRois = length(obj.voClosedPolygonStructures);
            voClosedPolygonStructures = DicomRTStructLabelMapRegionsOfInterest.GetClosedPolygonStructuresFromFileMetadata(obj.stFileMetadata, obj.GetOnDiskImageVolumeGeometry(), obj.dNumberOfRegionsOfInterestInFile);
            
            voClosedPolygonStructures = voClosedPolygonStructures(obj.vdSelectedRegionsOfInterest);
            
            for dStructureIndex=1:dNumRois
                obj.voClosedPolygonStructures(dStructureIndex).RestoreToOnDiskGeometry(voClosedPolygonStructures(dStructureIndex));
            end
                        
            % set each mask into a given bit of the integer
            dRoiNumber = 1;
            
            for dStructureIndex=1:dNumRois
                if obj.vbClosedPolygonStructureEnabled(dStructureIndex)
                    m3bMask = obj.voClosedPolygonStructures(dStructureIndex).GetMask();
                                        
                    m3uiLabelMaps = bitset(m3uiLabelMaps, dRoiNumber, m3bMask);
                    dRoiNumber = dRoiNumber + 1;
                end
            end
        end
        
        function cpObj = copyElement(obj)
            % super-class call:
            cpObj = copyElement@LabelMapRegionsOfInterest(obj);
            
            % local call            
            cpObj.voClosedPolygonStructures = copy(obj.voClosedPolygonStructures);            
        end
        
        function RecomputeRegionOfInterestLabelMapForPolygonEnabledChange(obj, dRegionOfInterestNumber)
            if ~isempty(obj.m3uiLabelMaps) % only recompute if they've been computed
                if ~obj.vbClosedPolygonStructureEnabled(dRegionOfInterestNumber) % the ROI isn't enabled at all
                    obj.m3uiLabelMaps = bitset(obj.m3uiLabelMaps, dRegionOfInterestNumber, 0); % set all to zero
                else
                    oOnDiskImageVolumeGeometry = obj.GetOnDiskImageVolumeGeometry();
                    
                    % re-create from what was on disk
                    oPolygonStructure = DicomRTStructClosedPolygonStructure(obj.stFileMetadata, obj.vdSelectedRegionsOfInterest(dRegionOfInterestNumber), oOnDiskImageVolumeGeometry);
                    
                    % transfer the current structure's enabled/disabled polygon
                    % settings
                    oPolygonStructure.SetPolygonsEnabled(obj.voClosedPolygonStructures(dRegionOfInterestNumber).IsPolygonEnabled());
                    
                    % get the starting mask
                    m3bMask = oPolygonStructure.GetMask();
                    
                    % apply the transforms performed so far (all must be first
                    % voxel reassignments)
                    voAppliedImagingObjectTransforms = obj.voAppliedImagingObjectTransforms;
                    
                    oCurrentImageVolumeGeometry = oOnDiskImageVolumeGeometry;
                    
                    for dTransformIndex=2:obj.dCurrentAppliedImagingObjectTransform % start at index 2 (skip InitialTransform)
                        if ~isa(voAppliedImagingObjectTransforms(dTransformIndex), 'ImagingObjectFirstVoxelTransform')
                            error(...
                                'DicomRTStructLabelMapRegionsOfInterest:RecomputeRegionOfInterestLabelMapForPolygonEnabledChange:InvalidTransforms',...
                                'Polygons cannot be enabled/disabled after any transform that is not a first voxel reassignment is performed.');
                        end
                        
                        [m3bMask, oCurrentImageVolumeGeometry] = oCurrentImageVolumeGeometry.ReassignFirstVoxel(m3bMask, voAppliedImagingObjectTransforms(dTransformIndex).GetTargetImageVolumeGeometry());
                    end
                    
                    % slot the mask into the labelmap
                    obj.m3uiLabelMaps = bitset(obj.m3uiLabelMaps, dRegionOfInterestNumber, m3bMask);
                end
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private, Static = true)
        
        function voClosedPolygonStructures = GetClosedPolygonStructuresFromFileMetadata(stFileMetadata, oImageVolumeGeometry, dNumberOfRois)
            oFirstStructure = DicomRTStructClosedPolygonStructure(stFileMetadata, 1, oImageVolumeGeometry);
            voClosedPolygonStructures = repmat(oFirstStructure,dNumberOfRois,1);
            
            for dContourIndex=2:dNumberOfRois
                voClosedPolygonStructures(dContourIndex) = DicomRTStructClosedPolygonStructure(stFileMetadata, dContourIndex, oImageVolumeGeometry);
            end
        end
    end
    
    
    methods (Access = {?LabelMapRegionsOfInterest, ?ImagingObjectTransform})
                
        function ApplyReassignFirstVoxel(obj, oTargetImageVolumeGeometry)
            oCurrentImageVolumeGeometry = obj.GetCurrentImageVolumeGeometry();
            
            % super-class call
            ApplyReassignFirstVoxel@LabelMapRegionsOfInterest(obj, oTargetImageVolumeGeometry); 
            
            % local call
            [~, oResultingGeometry, vdVolumeDimensionReassignment] = oCurrentImageVolumeGeometry.ReassignFirstVoxel([], oTargetImageVolumeGeometry);
                        
            dNumRois = obj.GetNumberOfRegionsOfInterest();
            
            for dRoiNumber=1:dNumRois
                obj.voClosedPolygonStructures(dRoiNumber).ApplyReassignFirstVoxel(oResultingGeometry, vdVolumeDimensionReassignment);
            end
        end
        
        function ApplyMaskSpatialInterpolation(obj, oTargetImageVolumeGeometry, chInterpolationMethod, varargin)
            oCurrentImageVolumeGeometry = obj.GetCurrentImageVolumeGeometry();
            
            % super-class call
            ApplyMaskSpatialInterpolation@LabelMapRegionsOfInterest(obj, oTargetImageVolumeGeometry, chInterpolationMethod, varargin{:});
            
            % local call
            if ...
                    any(oCurrentImageVolumeGeometry.GetRowAxisUnitVector() ~= oTargetImageVolumeGeometry.GetRowAxisUnitVector()) ||...
                    any(oCurrentImageVolumeGeometry.GetColumnAxisUnitVector() ~= oTargetImageVolumeGeometry.GetColumnAxisUnitVector())
                error('Interpolating with a rotation! What to do with the polygon coords?');
            end
            
            for dRoiNumber=1:obj.GetNumberOfRegionsOfInterest()
                obj.voClosedPolygonStructures(dRoiNumber).ApplyNewVoxelResolution(oTargetImageVolumeGeometry);
            end
        end
        
        function ApplyCrop(obj, m2dBounds, oTargetImageVolumeGeometry)
            % super-class call
            ApplyCrop@LabelMapRegionsOfInterest(obj, m2dBounds, oTargetImageVolumeGeometry);
            
            for dRoiNumber=1:obj.GetNumberOfRegionsOfInterest()
                obj.voClosedPolygonStructures(dRoiNumber).ApplyNewVoxelResolution(oTargetImageVolumeGeometry);
            end
        end
    end
    
    
    
    
    
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    
    % *********************************************************************
    % *                        UNIT TEST ACCESS                           *
    % *                  (To ONLY be called by tests)                     *
    % *********************************************************************
    
    methods (Access = {?matlab.unittest.TestCase}, Static = false)
    end
    
    
    methods (Access = {?matlab.unittest.TestCase}, Static = true)        
    end
end


