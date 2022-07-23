classdef (Abstract) GeometricalImagingObjectRenderer < handle
    %Renderer
    
    % Primary Author: David DeVries
    % Created: Sept 7, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
          
    properties (SetAccess = immutable, GetAccess = public)
        dMaxVolumeExtent_mm (1,1) double
        dAxisLength_mm (1,1) double
    end
    
    properties (SetAccess = private, GetAccess = public)
                    
        voImaging3DRenderAxes = []
        
        % 3D Display options:
        bDisplay3DImageVolumeOutline = true
        vd3DImageVolumeOutlineColour_rgb = [1 1 1] % white
        d3DImageVolumeOutlineLineWidth = 1
        ch3DImageVolumeOutlineLineStyle = '-'
        
        bDisplay3DImageVolumeDimensionsVoxels = true
        d3DImageVolumeDimensionsVoxelsFontSize = 12
        
        bDisplay3DImageVolumeDimensionsMetric = true
        d3DImageVolumeDimensionsMetricFontSize = 12
        
        bDisplay3DAnatomicalPlanes = true
        d3DAnatomicalPlanesAlpha = 0.3
        
        bDisplay3DAnatomicalPlanesLabels = true
        d3DAnatomicalPlanesLabelsFontSize = 14
        
        bDisplay3DAnatomicalPlanesAlignmentMarkers = true
        d3DAnatomicalPlanesAlignmentMarkerFontSize = 14
        
        bDisplay3DRepresentativeVoxel = true
        vd3DRepresentativeVoxelColour_rgb = [1 1 1] % white
        d3DRepresentativeVoxelLineWidth = 1
        ch3DRepresentativeVoxelLineStyle = '-'
        
        bDisplay3DRepresentativeVoxelDimensions = true
        d3DRepresentativeVoxelDimensionsFontSize = 12
        
        bDisplay3DImageVolumeCoordinateAxes = true
        d3DImageVolumeCoordinateAxesLineWidth = 3
        ch3DImageVolumeCoordinateAxesLineStyle = '-'
        
        bDisplay3DImageVolumeCoordinateAxesLabels = true
        d3DImageVolumeCoordinateAxesLabelsFontSize = 12
        
        bDisplay3DRepresentativePatient = false
        d3DRepresentativePatientAlpha = 0.5
        
        vdVolumeDimensionIColour_rgb = [0 1 1] % yellow
        vdVolumeDimensionJColour_rgb = [1 0 1] % pink
        vdVolumeDimensionKColour_rgb = [1 1 0] % cyan
        
        bDisplay3DAxes = true
        ch3DAxesPositiveAxisLineStyle = '-'
        ch3DAxesNegativeAxisLineStyle = '--'
        
        bDisplay3DAxesCartesianLabels = true
        bDisplay3DAxesAnatomicalLabels = true
        dDisplay3DAxesLabelsFontSize = 14
        
        vdVolumeDimensionSagittalColour_rgb = [1 0 0] % red
        vdVolumeDimensionCoronalColour_rgb = [0 1 0] % green
        vdVolumeDimensionAxialColour_rgb = [0.3 0.3 1] % blue
        
        
        % 3D-Rendered objects tracking:
        c1c1h3DAxesHandles = {}
        vd3DAxesRenderGroupIds = []
                
        c1c1h3DAxesCartesianLabelHandles = {}
        vd3DAxesCartesianLabelRenderGroupIds = []
                        
        c1c1h3DAxesAnatomicalLabelHandles = {}
        vd3DAxesAnatomicalLabelRenderGroupIds = []
        
        c1c1hRendered3DImageVolumeOutlines = {}
        vdRendered3DImageVolumeOutlinesRenderGroupIds = []
        
        c1c1hRendered3DImageVolumeDimensionsVoxels = {}
        vdRendered3DImageVolumeDimensionsVoxelsRenderGroupIds = []
        
        c1c1hRendered3DImageVolumeDimensionsMetric = {}
        vdRendered3DImageVolumeDimensionsMetricRenderGroupIds = []
        
        c1c1hRendered3DAnatomicalPlanes = {}
        vdRendered3DAnatomicalPlanesRenderGroupIds = []
        
        c1c1hRendered3DAnatomicalPlanesLabels = {}
        vdRendered3DAnatomicalPlanesLabelsRenderGroupIds = []
        
        c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels = {}
        vdRendered3DAnatomicalPlanesAlignmentsMarkersRenderGroupIds = []
        
        c1c1hRendered3DRepresentativeVoxels = {}
        vdRendered3DRepresentativeVoxelsRenderGroupIds = {}
        
        c1c1hRendered3DRepresentativeVoxelDimensions = {}
        vdRendered3DRepresentativeVoxelDimensionsRenderGroupIds = {}
        
        c1c1hRendered3DImageVolumeCoordinatesAxes = {}
        vdRendered3DImageVolumeCoordinatesAxesRenderGroupIds = {}
        
        c1c1hRendered3DImageVolumeCoordinatesAxesLabels = {}
        vdRendered3DImageVolumeCoordinatesAxesLabelsRenderGroupIds = {}
        
        c1c1hRendered3DRepresentativePatients = {}
        vdRendered3DRepresentativePatientsRenderGroupIds = {}
        
        % Plane Rendered options:
        vbDisplaySliceIntersections = []
        vdSliceIntersectionsColour_rgb = [1 1 0] % yellow
        dSliceIntersectionsLineWidth = 1
        chSliceIntersectionsLineStyle = '-'
        
        % Plane Rendered objects tracking:
        c1c1hRenderedSliceIntersections
        vdRenderedSliceIntersectionRenderGroupIds
    end
    
    properties (SetAccess = protected, GetAccess = protected)
        vdRenderGroupIds = 0        
    end
    
    properties (Constant = true, GetAccess = private)
        bDefaultDisplaySliceIntersections = true
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
          
    methods (Access = public)
        
        function obj = GeometricalImagingObjectRenderer(oGeometricalImagingObject)
            arguments
                oGeometricalImagingObject (1,1) GeometricalImagingObject
            end
            
            % calculate and save the max volume extent and axis length
            oImageVolumeGeometry = oGeometricalImagingObject.GetImageVolumeGeometry();
            
            [vdVolumeBoundsX_mm, vdVolumeBoundsY_mm, vdVolumeBoundsZ_mm] = oImageVolumeGeometry.GetVolumeBounds();
                        
            dMaxExtent_mm = max(abs([vdVolumeBoundsX_mm, vdVolumeBoundsY_mm, vdVolumeBoundsZ_mm]));
            
            dAxisLength_mm = 1.5*dMaxExtent_mm;
            
            obj.dMaxVolumeExtent_mm = dMaxExtent_mm;
            obj.dAxisLength_mm = dAxisLength_mm;
        end
        
        function dRenderGroupId = CreateRenderGroup(obj)
            dRenderGroupId = max(obj.vdRenderGroupIds) + 1;
            obj.vdRenderGroupIds = [obj.vdRenderGroupIds, dRenderGroupId];
        end
        
        function BringSliceIntersectionLinesToTopByRenderGroupId(obj, dRenderGroupId)
            arguments
                obj
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}
            end
            
            for dIntersectionLinesIndex=1:length(obj.vdRenderedSliceIntersectionRenderGroupIds)
                if obj.vdRenderedSliceIntersectionRenderGroupIds(dIntersectionLinesIndex) == dRenderGroupId
                    obj.BringRenderedSliceIntersectionLinesToTop(dIntersectionLinesIndex);
                end
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> VALIDATORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function MustBeValidRenderGroupId(obj, dRenderGroupId)
            arguments
                obj
                dRenderGroupId (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if dRenderGroupId > obj.vdRenderGroupIds(end)
                error(...
                    'GeometricalImagingObjectRenderer:MustBeValidRenderGroupId:Invalid',...
                    'The render group ID was not found.');
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> UPDATERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function UpdateAll(obj)
            arguments
                obj
            end
            
            % local class updaters
            obj.UpdateAll3D();
            obj.UpdateAllOnPlane();
        end
        
        function UpdateAll3D(obj)
            arguments
                obj
            end
            
            % local class updaters
            obj.UpdateAllRendered3DAxes();
            obj.UpdateAllRendered3DAxesCartesianLabels();
            obj.UpdateAllRendered3DAxesAnatomicalLabels();
            obj.UpdateAllRendered3DImageVolumeOutline();
            obj.UpdateAllRendered3DImageVolumeDimensionsVoxels();
            obj.UpdateAllRendered3DImageVolumeDimensionsMetric();
            obj.UpdateAllRendered3DAnatomicalPlanes();
            obj.UpdateAllRendered3DAnatomicalPlaneLabels();
            obj.UpdateAllRendered3DAnatomicalPlaneAlignmentMarkers();
            obj.UpdateAllRendered3DRepresentativeVoxel();
            obj.UpdateAllRendered3DRepresentativeVoxelDimensions();
            obj.UpdateAllRendered3DImageVolumeCoordinateAxes();
            obj.UpdateAllRendered3DImageVolumeCoordinateAxesLabels();
            obj.UpdateAllRendered3DRepresentativePatient();
            
            obj.UpdateAllImaging3DRenderAxes();
        end
        
        function UpdateAllOnPlane(obj)
            arguments
                obj
            end
            
            % local class updaters
            obj.UpdateAllRenderedSliceIntersections();
        end
                
        function UpdateRenderedOnPlaneSliceIntersectionsPositionsByRenderGroupId(obj, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            vdDimensionSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            veImagingPlaneTypes = enumeration('ImagingPlaneTypes');
            veIntersectingPlaneTypes = veImagingPlaneTypes(vdDimensionSelect(1:2));
            
            for dSliceIndex=1:length(obj.c1c1hRenderedSliceIntersections)
                if dRenderGroupId == obj.vdRenderedSliceIntersectionRenderGroupIds(dSliceIndex)
                    for dPlaneIndex=1:2
                        [vdX_mm, vdY_mm] = eImagingPlaneType.GetSliceIntersectionCoordinates(obj.oRASImageVolume, veIntersectingPlaneTypes(dPlaneIndex), vdAnatomicalPlaneIndices(vdDimensionSelect(dPlaneIndex)));
                        
                        set(...
                            obj.c1c1hRenderedSliceIntersections{dSliceIndex}{dPlaneIndex},...
                            'XData', vdX_mm,...
                            'YData', vdY_mm);
                    end
                end
            end
        end
        
        function Update3DRenderAnatomicalPlanePositionByRenderGroupIdAndType(obj, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}
            end
            
            oGeometryRAS = obj.oRASImageVolume.GetImageVolumeGeometry();
            vdVolumeDimensions = oGeometryRAS.GetVolumeDimensions();
            
            switch eImagingPlaneType
                case ImagingPlaneTypes.Sagittal
                    dHandleIndex = 1;
                    dSliceIndex = vdAnatomicalPlaneIndices(1);
                    
                    [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                        [dSliceIndex dSliceIndex dSliceIndex dSliceIndex],...
                        [0.5 0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5],...
                        [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
                case ImagingPlaneTypes.Coronal
                    dHandleIndex = 2;
                    dSliceIndex = vdAnatomicalPlaneIndices(2);   
                    
                    [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                        [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                        [dSliceIndex dSliceIndex dSliceIndex dSliceIndex],...
                        [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
                case ImagingPlaneTypes.Axial
                    dHandleIndex = 3;
                    dSliceIndex = vdAnatomicalPlaneIndices(3);
                    
                    [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                        [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                        [0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5 0.5],...
                        [dSliceIndex dSliceIndex dSliceIndex dSliceIndex]);
            end
            
            % Update planes
            for dPlaneIndex=1:length(obj.c1c1hRendered3DAnatomicalPlanes)
                if dRenderGroupId == obj.vdRendered3DAnatomicalPlanesRenderGroupIds(dPlaneIndex)
                    set(...
                        obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{dHandleIndex},...
                        'XData', vdX_mm,...
                        'YData', vdY_mm,...
                        'ZData', vdZ_mm);
                end
            end
            
            % Update plane labels
            for dLabelIndex=1:length(obj.c1c1hRendered3DAnatomicalPlanesLabels)
                if dRenderGroupId == obj.vdRendered3DAnatomicalPlanesLabelsRenderGroupIds(dLabelIndex)
                    obj.c1c1hRendered3DAnatomicalPlanesLabels{dLabelIndex}{dHandleIndex}.Position = [vdX_mm(2), vdY_mm(2), vdZ_mm(2)];                
                end
            end
            
            % Update plane alignment markers
            for dMarkersIndex=1:length(obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels)
                if dRenderGroupId == obj.vdRendered3DAnatomicalPlanesAlignmentsMarkersRenderGroupIds(dMarkersIndex)
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{(dHandleIndex-1)*4 + 1}.Position = [vdX_mm(3), vdY_mm(3), vdZ_mm(3)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{(dHandleIndex-1)*4 + 2}.Position = [vdX_mm(4), vdY_mm(4), vdZ_mm(4)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{(dHandleIndex-1)*4 + 3}.Position = [vdX_mm(2), vdY_mm(2), vdZ_mm(1)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{(dHandleIndex-1)*4 + 4}.Position = [vdX_mm(1), vdY_mm(1), vdZ_mm(1)];
                end
            end   
        end
        
        function Update3DRenderAnatomicalPlanePositionsByRenderGroupId(obj, vdAnatomicalPlaneIndices, dRenderGroupId)
            
            dSagittalPlaneIndex = vdAnatomicalPlaneIndices(1);
            dCoronalPlaneIndex = vdAnatomicalPlaneIndices(2);
            dAxialPlaneIndex = vdAnatomicalPlaneIndices(3);
            
            oGeometryRAS = obj.oRASImageVolume.GetImageVolumeGeometry();
            
            vdVolumeDimensions = oGeometryRAS.GetVolumeDimensions();
            
            [vdSagX_mm, vdSagY_mm, vdSagZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                [dSagittalPlaneIndex dSagittalPlaneIndex dSagittalPlaneIndex dSagittalPlaneIndex],...
                [0.5 0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5],...
                [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
            
            [vdCorX_mm, vdCorY_mm, vdCorZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                [dCoronalPlaneIndex dCoronalPlaneIndex dCoronalPlaneIndex dCoronalPlaneIndex],...
                [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
            
            [vdAxX_mm, vdAxY_mm, vdAxZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                [0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5 0.5],...
                [dAxialPlaneIndex dAxialPlaneIndex dAxialPlaneIndex dAxialPlaneIndex]);
            
            % Update planes
            for dPlaneIndex=1:length(obj.c1c1hRendered3DAnatomicalPlanes)
                if dRenderGroupId == obj.vdRendered3DAnatomicalPlanesRenderGroupIds(dPlaneIndex)
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{1}.XData = vdSagX_mm;
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{1}.YData = vdSagY_mm;
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{1}.ZData = vdSagZ_mm;
                    
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{2}.XData = vdCorX_mm;
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{2}.YData = vdCorY_mm;
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{2}.ZData = vdCorZ_mm;
                    
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{3}.XData = vdAxX_mm;
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{3}.YData = vdAxY_mm;
                    obj.c1c1hRendered3DAnatomicalPlanes{dPlaneIndex}{3}.ZData = vdAxZ_mm;
                end
            end
            
            % Update plane labels
            for dLabelIndex=1:length(obj.c1c1hRendered3DAnatomicalPlanesLabels)
                if dRenderGroupId == obj.vdRendered3DAnatomicalPlanesLabelsRenderGroupIds(dLabelIndex)
                    obj.c1c1hRendered3DAnatomicalPlanesLabels{dLabelIndex}{1}.Position = [vdSagX_mm(2), vdSagY_mm(2), vdSagZ_mm(2)];                                        
                    obj.c1c1hRendered3DAnatomicalPlanesLabels{dLabelIndex}{2}.Position = [vdCorX_mm(2), vdCorY_mm(2), vdCorZ_mm(2)];                                                            
                    obj.c1c1hRendered3DAnatomicalPlanesLabels{dLabelIndex}{3}.Position = [vdAxX_mm(2), vdAxY_mm(2), vdAxZ_mm(2)];                    
                end
            end
            
            % Update plane alignment markers
            for dMarkersIndex=1:length(obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels)
                if dRenderGroupId == obj.vdRendered3DAnatomicalPlanesAlignmentsMarkersRenderGroupIds(dMarkersIndex)
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{1}.Position = [vdSagX_mm(3), vdSagY_mm(3), vdSagZ_mm(3)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{2}.Position = [vdSagX_mm(4), vdSagY_mm(4), vdSagZ_mm(4)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{3}.Position = [vdSagX_mm(2), vdSagY_mm(2), vdSagZ_mm(1)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{4}.Position = [vdSagX_mm(1), vdSagY_mm(1), vdSagZ_mm(1)];
                    
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{5}.Position = [vdCorX_mm(3), vdCorY_mm(3), vdCorZ_mm(3)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{6}.Position = [vdCorX_mm(4), vdCorY_mm(4), vdCorZ_mm(4)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{7}.Position = [vdCorX_mm(2), vdCorY_mm(2), vdCorZ_mm(1)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{8}.Position = [vdCorX_mm(1), vdCorY_mm(1), vdCorZ_mm(1)];
                    
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{9}.Position = [vdAxX_mm(3), vdAxY_mm(3), vdAxZ_mm(3)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{10}.Position = [vdAxX_mm(4), vdAxY_mm(4), vdAxZ_mm(4)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{11}.Position = [vdAxX_mm(2), vdAxY_mm(2), vdAxZ_mm(1)];
                    obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dMarkersIndex}{12}.Position = [vdAxX_mm(1), vdAxY_mm(1), vdAxZ_mm(1)];
                end
            end            
        end
        
        function UpdateAllRendered3DAxes(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vd3DAxesRenderGroupIds)
                obj.UpdateRendered3DAxes(dIndex);
           end
        end
        
        function UpdateAllRendered3DAxesCartesianLabels(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vd3DAxesCartesianLabelRenderGroupIds)
                obj.UpdateRendered3DAxesCartesianLabels(dIndex);
           end
        end
        
        function UpdateAllRendered3DAxesAnatomicalLabels(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vd3DAxesAnatomicalLabelRenderGroupIds)
                obj.UpdateRendered3DAxesAnatomicalLabels(dIndex);
           end
        end
        
        function UpdateAllRendered3DImageVolumeOutline(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DImageVolumeOutlinesRenderGroupIds)
                obj.UpdateRendered3DImageVolumeOutline(dIndex);
           end
        end
        
        function UpdateAllRendered3DImageVolumeDimensionsVoxels(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DImageVolumeDimensionsVoxelsRenderGroupIds)
                obj.UpdateRendered3DImageVolumeDimensionsVoxels(dIndex);
           end
        end
        
        function UpdateAllRendered3DImageVolumeDimensionsMetric(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DImageVolumeDimensionsMetricRenderGroupIds)
                obj.UpdateRendered3DImageVolumeDimensionsMetric(dIndex);
           end
        end
        
        function UpdateAllRendered3DAnatomicalPlanes(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DAnatomicalPlanesRenderGroupIds)
                obj.UpdateRendered3DAnatomicalPlanes(dIndex);
           end
        end
        
        function UpdateAllRendered3DAnatomicalPlaneLabels(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DAnatomicalPlanesLabelsRenderGroupIds)
                obj.UpdateRendered3DAnatomicalPlaneLabels(dIndex);
           end
        end
        
        function UpdateAllRendered3DAnatomicalPlaneAlignmentMarkers(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DAnatomicalPlanesAlignmentsMarkersRenderGroupIds)
                obj.UpdateRendered3DAnatomicalPlaneAlignmentMarkers(dIndex);
           end
        end
        
        function UpdateAllRendered3DRepresentativeVoxel(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DRepresentativeVoxelsRenderGroupIds)
                obj.UpdateRendered3DRepresentativeVoxel(dIndex);
           end
        end
        
        function UpdateAllRendered3DRepresentativeVoxelDimensions(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DRepresentativeVoxelDimensionsRenderGroupIds)
                obj.UpdateRendered3DRepresentativeVoxelDimensions(dIndex);
           end
        end
        
        function UpdateAllRendered3DImageVolumeCoordinateAxes(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DImageVolumeCoordinatesAxesRenderGroupIds)
                obj.UpdateRendered3DImageVolumeCoordinateAxes(dIndex);
           end
        end
        
        function UpdateAllRendered3DImageVolumeCoordinateAxesLabels(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DImageVolumeCoordinatesAxesLabelsRenderGroupIds)
                obj.UpdateRendered3DImageVolumeCoordinateAxesLabels(dIndex);
           end
        end
        
        function UpdateAllRendered3DRepresentativePatient(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRendered3DRepresentativePatientsRenderGroupIds)
                obj.UpdateRendered3DRepresentativePatient(dIndex);
           end
        end
        
        function UpdateAllRenderedSliceIntersections(obj)
           arguments
                obj
           end
            
           for dIndex=1:length(obj.vdRenderedSliceIntersectionRenderGroupIds)
                obj.UpdateRenderedSliceIntersections(dIndex);
           end
        end
        
        function UpdateAllImaging3DRenderAxes(obj)
            arguments
                obj
            end
            
            for dAxesIndex=1:length(obj.voImaging3DRenderAxes)
                obj.voImaging3DRenderAxes(dAxesIndex).UpdateAxesWithLightingStyle;
            end 
        end        
       
        
        % >>>>>>>>>>>>>>>>>>>>>> SETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function SetAllImaging3DRenderAxesLightingStyles(obj, chLightingStyle)
            arguments
                obj
                chLightingStyle (1,:) char
            end
            
            for dAxesIndex=1:length(obj.voImaging3DRenderAxes)
                obj.voImaging3DRenderAxes(dAxesIndex).SetLightingStyle(chLightingStyle);
            end            
        end
            
        
        function SetAllSliceIntersectionVisibilities(obj, bIsVisible)
            arguments
                obj
                bIsVisible (1,1) logical
            end
                        
            obj.vbDisplaySliceIntersections(:) = bIsVisible;
        end
        
        function SetAllSliceIntersectionLineWidths(obj, dLineWidth)
            arguments
                obj
                dLineWidth (1,1) double {mustBePositive, mustBeFinite}
            end
            
            obj.dSliceIntersectionsLineWidth = dLineWidth;
        end
        
        function SetAllSliceIntersectionLineStyles(obj, chLineStyle)
            arguments
                obj
                chLineStyle (1,:) char
            end
            
            obj.chSliceIntersectionsLineStyle = chLineStyle;
        end
        
        function Set3DAxesVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DAxes = bVisible;
        end
        
        function Set3DAxesCartesianLabelsVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DAxesCartesianLabels = bVisible;
        end
        
        function Set3DAxesAnatomicalLabelsVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DAxesAnatomicalLabels = bVisible;
        end
        
        function Set3DAnatomicalPlanesVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DAnatomicalPlanes = bVisible;
        end
        
        function Set3DAnatomicalPlaneLabelsVisiblity(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DAnatomicalPlanesLabels = bVisible;
        end
        
        function Set3DAnatomicalPlaneAlignmentMarkersVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DAnatomicalPlanesAlignmentMarkers = bVisible;
        end
        
        function Set3DImageVolumeOutlineVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DImageVolumeOutline = bVisible;
        end
        
        function Set3DImageVolumeDimensionsVoxelsVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DImageVolumeDimensionsVoxels = bVisible;
        end
        
        function Set3DImageVolumeDimensionsMetricVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DImageVolumeDimensionsMetric = bVisible;
        end
        
        function Set3DImageVolumeCoordinateAxesVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DImageVolumeCoordinateAxes = bVisible;
        end
        
        function Set3DImageVolumeCoordinateAxesLabelsVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DImageVolumeCoordinateAxesLabels = bVisible;
        end
        
        function Set3DRepresentativeVoxelVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DRepresentativeVoxel = bVisible;
        end
        
        function Set3DRepresentativeVoxelLabelsVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DRepresentativeVoxelDimensions = bVisible;
        end
        
        function Set3DRepresentativePatientVisibility(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            obj.bDisplay3DRepresentativePatient = bVisible;
        end
        
        
        
        % >>>>>>>>>>>>>>>>>>>>>> RENDER PLANE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function RenderOnPlane(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId, NameValueArgs)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,:) double
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
                NameValueArgs.GeometricalImagingObjectRendererComplete (1,1) logical = false
            end
            
            % only render if this super-class call wasn't completed through
            % a different class heirachy already
            if ~NameValueArgs.GeometricalImagingObjectRendererComplete
                obj.RenderPlaneSliceIntersections(...
                    oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices,...
                    dRenderGroupId);
            end
        end
        
        function RenderPlaneSliceIntersections(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,:) double
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % Render slice intersections (after ROIs so their on top)
            vdDimensionSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();            
            veImagingPlaneTypes = enumeration('ImagingPlaneTypes');
            veIntersectingPlaneTypes = veImagingPlaneTypes(vdDimensionSelect(1:2));
            
            c1hSliceIntersectionLines = cell(1,2);
            
            hAxes = oImagingPlaneAxes.GetAxes();
            
            for dPlaneIndex=1:2
                [vdX_mm, vdY_mm] = eImagingPlaneType.GetSliceIntersectionCoordinates(...
                    obj.GetRASGeometricalImagingObject(),...
                    veIntersectingPlaneTypes(dPlaneIndex),...
                    vdAnatomicalPlaneIndices(vdDimensionSelect(dPlaneIndex)));
                
                c1hSliceIntersectionLines{dPlaneIndex} = line(...
                    hAxes,...
                    vdX_mm, vdY_mm);
            end
            
            obj.vbDisplaySliceIntersections = [obj.vbDisplaySliceIntersections, obj.bDefaultDisplaySliceIntersections];
            obj.c1c1hRenderedSliceIntersections = [obj.c1c1hRenderedSliceIntersections, {c1hSliceIntersectionLines}];
            obj.vdRenderedSliceIntersectionRenderGroupIds = [obj.vdRenderedSliceIntersectionRenderGroupIds, dRenderGroupId];
            
            % Update
            obj.UpdateRenderedSliceIntersections(length(obj.c1c1hRenderedSliceIntersections));
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>> RENDER 3D <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function RenderIn3D(obj, oImaging3DRenderAxes, vdAnatomicalPlaneIndices, dRenderGroupId, NameValueArgs)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                vdAnatomicalPlaneIndices (1,:) double {mustBeInteger(vdAnatomicalPlaneIndices), mustBeFinite(vdAnatomicalPlaneIndices)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
                NameValueArgs.GeometricalImagingObjectRendererComplete (1,1) logical = false
            end
            
            if ~NameValueArgs.GeometricalImagingObjectRendererComplete
                % record the 3D axes object
                obj.voImaging3DRenderAxes = [obj.voImaging3DRenderAxes; oImaging3DRenderAxes];
                                
                % Render components
                obj.Render3DAxes(oImaging3DRenderAxes, dRenderGroupId);
                obj.Render3DAxesCartesianLabels(oImaging3DRenderAxes, dRenderGroupId);
                obj.Render3DAxesAnatomicalLabels(oImaging3DRenderAxes, dRenderGroupId);
                
                obj.Render3DImageVolumeOutline(oImaging3DRenderAxes, dRenderGroupId);
                obj.Render3DImageVolumeDimensionsVoxels(oImaging3DRenderAxes, dRenderGroupId);
                obj.Render3DImageVolumeDimensionsMetric(oImaging3DRenderAxes, dRenderGroupId);
                
                if ~isempty(vdAnatomicalPlaneIndices)
                    obj.Render3DAnatomicalPlanes(vdAnatomicalPlaneIndices, oImaging3DRenderAxes, dRenderGroupId);
                    obj.Render3DAnatomicalPlaneLabels(vdAnatomicalPlaneIndices, oImaging3DRenderAxes, dRenderGroupId);
                    obj.Render3DAnatomicalPlaneAlignmentMarkers(vdAnatomicalPlaneIndices, oImaging3DRenderAxes, dRenderGroupId);
                end
                
                obj.Render3DRepresentativeVoxel(oImaging3DRenderAxes, dRenderGroupId);
                obj.Render3DRepresentativeVoxelDimensions(oImaging3DRenderAxes, dRenderGroupId);
                
                obj.Render3DImageVolumeCoordinateAxes(oImaging3DRenderAxes, dRenderGroupId);
                obj.Render3DImageVolumeCoordinateAxesLabels(oImaging3DRenderAxes, dRenderGroupId);
                
                obj.Render3DRepresentativePatient(oImaging3DRenderAxes, dRenderGroupId);
            end
        end
        
        function Render3DAxes(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            c1hAxesLines = cell(1,6);
            
            c1hAxesLines{1} = line(h3DAxes, [0 +obj.dAxisLength_mm],[0 0],[0 0]);
            c1hAxesLines{2} = line(h3DAxes, [0 -obj.dAxisLength_mm],[0 0],[0 0]);
            
            c1hAxesLines{3} = line(h3DAxes, [0 0],[0 +obj.dAxisLength_mm],[0 0]);
            c1hAxesLines{4} = line(h3DAxes, [0 0],[0 -obj.dAxisLength_mm],[0 0]);
                       
            c1hAxesLines{5} = line(h3DAxes, [0 0],[0 0],[0 +obj.dAxisLength_mm]);
            c1hAxesLines{6} = line(h3DAxes, [0 0],[0 0],[0 -obj.dAxisLength_mm]);
            
            % set handles/render group IDs
            obj.c1c1h3DAxesHandles = [obj.c1c1h3DAxesHandles, {c1hAxesLines}];
            obj.vd3DAxesRenderGroupIds = [obj.vd3DAxesRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DAxes(length(obj.c1c1h3DAxesHandles));
        end
        
        function Render3DAxesCartesianLabels(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            c1hCartesianLabels = cell(1,6);
            
            c1hCartesianLabels{1} = text(h3DAxes, +obj.dAxisLength_mm, 0, 0, '+X           ',...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            c1hCartesianLabels{2} = text(h3DAxes, -obj.dAxisLength_mm, 0, 0, '-X',...
                'VerticalAlignment', 'top');
            
            c1hCartesianLabels{3} = text(h3DAxes, 0, +obj.dAxisLength_mm, 0, '+Y               ',...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            c1hCartesianLabels{4} = text(h3DAxes, 0, -obj.dAxisLength_mm, 0, '-Y',...
                'VerticalAlignment', 'top');
              
            c1hCartesianLabels{5} = text(h3DAxes, 0, 0, +obj.dAxisLength_mm, '+Z                ',...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            c1hCartesianLabels{6} = text(h3DAxes, 0, 0, -obj.dAxisLength_mm, '-Z',...
                'VerticalAlignment', 'top');
            
            % set handles/render group IDs
            obj.c1c1h3DAxesCartesianLabelHandles = [obj.c1c1h3DAxesCartesianLabelHandles, {c1hCartesianLabels}];
            obj.vd3DAxesCartesianLabelRenderGroupIds = [obj.vd3DAxesCartesianLabelRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DAxesCartesianLabels(length(obj.c1c1h3DAxesCartesianLabelHandles));            
        end
        
        function Render3DAxesAnatomicalLabels(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            c1hAnatomicalLabels = cell(1,6);
            
            c1hAnatomicalLabels{1} = text(h3DAxes, +obj.dAxisLength_mm, 0, 0, '(Right)',...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            c1hAnatomicalLabels{2} = text(h3DAxes, -obj.dAxisLength_mm, 0, 0, '    (Left)',...
                'VerticalAlignment', 'top');
            
            c1hAnatomicalLabels{3} = text(h3DAxes, 0, +obj.dAxisLength_mm, 0, '(Anterior)',...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            c1hAnatomicalLabels{4} = text(h3DAxes, 0, -obj.dAxisLength_mm, 0, '    (Posterior)',...
                'VerticalAlignment', 'top');
              
            c1hAnatomicalLabels{5} = text(h3DAxes, 0, 0, +obj.dAxisLength_mm, '(Superior)',...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            c1hAnatomicalLabels{6} = text(h3DAxes, 0, 0, -obj.dAxisLength_mm, '    (Inferior)',...
                'VerticalAlignment', 'top');
            
            % set handles/render group IDs
            obj.c1c1h3DAxesAnatomicalLabelHandles = [obj.c1c1h3DAxesAnatomicalLabelHandles, {c1hAnatomicalLabels}];
            obj.vd3DAxesAnatomicalLabelRenderGroupIds = [obj.vd3DAxesAnatomicalLabelRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DAxesAnatomicalLabels(length(obj.c1c1h3DAxesAnatomicalLabelHandles));            
        end
        
        function Render3DImageVolumeOutline(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            oGeometryRAS = obj.GetRASGeometricalImagingObject().GetImageVolumeGeometry();
            
            vdVolumeDimensions = oGeometryRAS.GetVolumeDimensions();
            
            dFirstRow = 0.5;
            dLastRow = vdVolumeDimensions(1) + 0.5;
            
            dFirstCol = 0.5;
            dLastCol = vdVolumeDimensions(2) + 0.5;
            
            dFirstSlice = 0.5;
            dLastSlice = vdVolumeDimensions(3) + 0.5;
            
            [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                [dFirstRow   dFirstRow  dFirstRow   dFirstRow  dLastRow    dLastRow   dLastRow    dLastRow],...
                [dFirstCol   dFirstCol  dLastCol    dLastCol   dFirstCol   dFirstCol  dLastCol    dLastCol],...
                [dFirstSlice dLastSlice dFirstSlice dLastSlice dFirstSlice dLastSlice dFirstSlice dLastSlice]);
            
            c1hLines = GeometricalImagingObjectRenderer.Render3DRectangularPrism(h3DAxes, vdX_mm, vdY_mm, vdZ_mm);
            
            % set handles/render group IDs
            obj.c1c1hRendered3DImageVolumeOutlines = [obj.c1c1hRendered3DImageVolumeOutlines, {c1hLines}];
            obj.vdRendered3DImageVolumeOutlinesRenderGroupIds = [obj.vdRendered3DImageVolumeOutlinesRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DImageVolumeOutline(length(obj.c1c1hRendered3DImageVolumeOutlines));
        end
        
        function Render3DImageVolumeDimensionsVoxels(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            vdVolumeDimensions = obj.GetGeometricalImagingObject().GetVolumeDimensions();
            
            [vdX_mm, vdY_mm, vdZ_mm] = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetPositionCoordinatesFromVoxelIndices(...
                [vdVolumeDimensions(1)/2, vdVolumeDimensions(1)+0.5, vdVolumeDimensions(1)+0.5],...
                [0.5, vdVolumeDimensions(2)/2, 0.5],...
                [vdVolumeDimensions(3)+0.5, 0.5, vdVolumeDimensions(3)/2]);
            
            c1hLabels = cell(3,1);
            
            c1hLabels{1} = text(h3DAxes, vdX_mm(1), vdY_mm(1), vdZ_mm(1),...
                num2str(vdVolumeDimensions(1)), 'FontWeight', 'bold');
            c1hLabels{2} = text(h3DAxes, vdX_mm(2), vdY_mm(2), vdZ_mm(2),...
                num2str(vdVolumeDimensions(2)), 'FontWeight', 'bold');
            c1hLabels{3} = text(h3DAxes, vdX_mm(3), vdY_mm(3), vdZ_mm(3),...
                num2str(vdVolumeDimensions(3)), 'FontWeight', 'bold');
            
            % set handles/render group IDs
            obj.c1c1hRendered3DImageVolumeDimensionsVoxels = [obj.c1c1hRendered3DImageVolumeDimensionsVoxels, {c1hLabels}];
            obj.vdRendered3DImageVolumeDimensionsVoxelsRenderGroupIds = [obj.vdRendered3DImageVolumeDimensionsVoxelsRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DImageVolumeDimensionsVoxels(length(obj.c1c1hRendered3DImageVolumeDimensionsVoxels));
        end
        
        function Render3DImageVolumeDimensionsMetric(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            vdVolumeDimensions = obj.GetGeometricalImagingObject().GetVolumeDimensions();
            vdVoxelDimensions_mm = obj.GetGeometricalImagingObject().GetVoxelDimensions_mm();
            
            [vdX_mm, vdY_mm, vdZ_mm] = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetPositionCoordinatesFromVoxelIndices(...
                [vdVolumeDimensions(1)/2, 0.5, 0.5],...
                [vdVolumeDimensions(2)+0.5, vdVolumeDimensions(2)/2, vdVolumeDimensions(2)+0.5],...
                [0.5, vdVolumeDimensions(3)+0.5, vdVolumeDimensions(3)/2]);
            
            c1hLabels = cell(3,1);
            
            c1hLabels{1} = text(h3DAxes, vdX_mm(1), vdY_mm(1), vdZ_mm(1),...
                [num2str(vdVolumeDimensions(1)*vdVoxelDimensions_mm(1)),'mm'], 'FontWeight', 'bold');
            c1hLabels{2} = text(h3DAxes, vdX_mm(2), vdY_mm(2), vdZ_mm(2),...
                [num2str(vdVolumeDimensions(2)*vdVoxelDimensions_mm(2)),'mm'], 'FontWeight', 'bold');
            c1hLabels{3} = text(h3DAxes, vdX_mm(3), vdY_mm(3), vdZ_mm(3),...
                [num2str(vdVolumeDimensions(3)*vdVoxelDimensions_mm(3)),'mm'], 'FontWeight', 'bold');
            
            % set handles/render group IDs
            obj.c1c1hRendered3DImageVolumeDimensionsMetric = [obj.c1c1hRendered3DImageVolumeDimensionsMetric, {c1hLabels}];
            obj.vdRendered3DImageVolumeDimensionsMetricRenderGroupIds = [obj.vdRendered3DImageVolumeDimensionsMetricRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DImageVolumeDimensionsMetric(length(obj.c1c1hRendered3DImageVolumeDimensionsMetric));
        end
        
        function Render3DAnatomicalPlanes(obj, vdAnatomicalPlaneIndices, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger(vdAnatomicalPlaneIndices), mustBeFinite(vdAnatomicalPlaneIndices)}
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            dSagittalPlaneIndex = vdAnatomicalPlaneIndices(1);
            dCoronalPlaneIndex = vdAnatomicalPlaneIndices(2);
            dAxialPlaneIndex = vdAnatomicalPlaneIndices(3);
            
            c1hPlanePatches = cell(1,3);
            
            oGeometryRAS = obj.GetRASGeometricalImagingObject().GetImageVolumeGeometry();
            
            vdVolumeDimensions = oGeometryRAS.GetVolumeDimensions();
            
            [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                [dSagittalPlaneIndex dSagittalPlaneIndex dSagittalPlaneIndex dSagittalPlaneIndex],...
                [0.5 0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5],...
                [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
            
            c1hPlanePatches{1} = patch(h3DAxes, 'XData', vdX_mm, 'YData', vdY_mm, 'ZData', vdZ_mm);
            
            [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                [dCoronalPlaneIndex dCoronalPlaneIndex dCoronalPlaneIndex dCoronalPlaneIndex],...
                [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
            
            c1hPlanePatches{2} = patch(h3DAxes, 'XData', vdX_mm, 'YData', vdY_mm, 'ZData', vdZ_mm);
            
            [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                [0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5 0.5],...
                [dAxialPlaneIndex dAxialPlaneIndex dAxialPlaneIndex dAxialPlaneIndex]);
            
            c1hPlanePatches{3} = patch(h3DAxes, 'XData', vdX_mm, 'YData', vdY_mm, 'ZData', vdZ_mm);
            
            % set handles/render group IDs
            obj.c1c1hRendered3DAnatomicalPlanes = [obj.c1c1hRendered3DAnatomicalPlanes, {c1hPlanePatches}];
            obj.vdRendered3DAnatomicalPlanesRenderGroupIds = [obj.vdRendered3DAnatomicalPlanesRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DAnatomicalPlanes(length(obj.c1c1hRendered3DAnatomicalPlanes));
        end
        
        function Render3DAnatomicalPlaneLabels(obj, vdAnatomicalPlaneIndices, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger(vdAnatomicalPlaneIndices), mustBeFinite(vdAnatomicalPlaneIndices)}
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            dSagittalPlaneIndex = vdAnatomicalPlaneIndices(1);
            dCoronalPlaneIndex = vdAnatomicalPlaneIndices(2);
            dAxialPlaneIndex = vdAnatomicalPlaneIndices(3);
            
            c1hLabels = cell(1,3);
            
            oGeometryRAS = obj.GetRASGeometricalImagingObject().GetImageVolumeGeometry();
            
            vdVolumeDimensions = oGeometryRAS.GetVolumeDimensions();
            
            [dX_mm, dY_mm, dZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                dSagittalPlaneIndex,...
                0.5,...
                vdVolumeDimensions(3)+0.5);
            
            c1hLabels{1} = text(h3DAxes, dX_mm, dY_mm, dZ_mm, '  Sagittal', 'VerticalAlignment', 'bottom');
            
            [dX_mm, dY_mm, dZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                0.5,...
                dCoronalPlaneIndex,...
                vdVolumeDimensions(3)+0.5);
            
            c1hLabels{2} = text(h3DAxes, dX_mm, dY_mm, dZ_mm, '  Coronal', 'VerticalAlignment', 'bottom');
            
            [dX_mm, dY_mm, dZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                0.5,...
                vdVolumeDimensions(2)+0.5,...
                dAxialPlaneIndex);
            
            c1hLabels{3} = text(h3DAxes, dX_mm, dY_mm, dZ_mm, '  Axial', 'VerticalAlignment', 'bottom');
            
            % set handles/render group IDs
            obj.c1c1hRendered3DAnatomicalPlanesLabels = [obj.c1c1hRendered3DAnatomicalPlanesLabels, {c1hLabels}];
            obj.vdRendered3DAnatomicalPlanesLabelsRenderGroupIds = [obj.vdRendered3DAnatomicalPlanesLabelsRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DAnatomicalPlaneLabels(length(obj.c1c1hRendered3DAnatomicalPlanesLabels));
        end
        
        function Render3DAnatomicalPlaneAlignmentMarkers(obj, vdAnatomicalPlaneIndices, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                vdAnatomicalPlaneIndices (1,3) double {mustBeInteger(vdAnatomicalPlaneIndices), mustBeFinite(vdAnatomicalPlaneIndices)}
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
                % get axes
                h3DAxes = oImaging3DRenderAxes.GetAxes();
                
                % Render
                dSagittalPlaneIndex = vdAnatomicalPlaneIndices(1);
                dCoronalPlaneIndex = vdAnatomicalPlaneIndices(2);
                dAxialPlaneIndex = vdAnatomicalPlaneIndices(3);
                
                c1hMarkers = cell(1,12);
                
                oGeometryRAS = obj.GetRASGeometricalImagingObject().GetImageVolumeGeometry();
                
                vdVolumeDimensions = oGeometryRAS.GetVolumeDimensions();
                
                [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                    [dSagittalPlaneIndex dSagittalPlaneIndex dSagittalPlaneIndex dSagittalPlaneIndex],...
                    [0.5 0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5],...
                    [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
                
                c1hMarkers{1} = text(h3DAxes, vdX_mm(3), vdY_mm(3), vdZ_mm(3), '\lceil', 'HorizontalAlignment', 'right');
                c1hMarkers{2} = text(h3DAxes, vdX_mm(4), vdY_mm(4), vdZ_mm(4), '\lfloor', 'HorizontalAlignment', 'right');
                c1hMarkers{3} = text(h3DAxes, vdX_mm(2), vdY_mm(2), vdZ_mm(2), '\rceil');
                c1hMarkers{4} = text(h3DAxes, vdX_mm(1), vdY_mm(1), vdZ_mm(1), '\rfloor');
                
                [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                    [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                    [dCoronalPlaneIndex dCoronalPlaneIndex dCoronalPlaneIndex dCoronalPlaneIndex],...
                    [0.5 vdVolumeDimensions(3)+0.5 vdVolumeDimensions(3)+0.5 0.5]);
                
                c1hMarkers{5} = text(h3DAxes, vdX_mm(3), vdY_mm(3), vdZ_mm(3), '\lceil', 'HorizontalAlignment', 'right');
                c1hMarkers{6} = text(h3DAxes, vdX_mm(4), vdY_mm(4), vdZ_mm(4), '\lfloor', 'HorizontalAlignment', 'right');
                c1hMarkers{7} = text(h3DAxes, vdX_mm(2), vdY_mm(2), vdZ_mm(2), '\rceil');
                c1hMarkers{8} = text(h3DAxes, vdX_mm(1), vdY_mm(1), vdZ_mm(1), '\rfloor');
                
                [vdX_mm, vdY_mm, vdZ_mm] = oGeometryRAS.GetPositionCoordinatesFromVoxelIndices(...
                    [0.5 0.5 vdVolumeDimensions(1)+0.5 vdVolumeDimensions(1)+0.5],...
                    [0.5 vdVolumeDimensions(2)+0.5 vdVolumeDimensions(2)+0.5 0.5],...
                    [dAxialPlaneIndex dAxialPlaneIndex dAxialPlaneIndex dAxialPlaneIndex]);
                
                c1hMarkers{9} = text(h3DAxes, vdX_mm(3), vdY_mm(3), vdZ_mm(3), '\lceil', 'HorizontalAlignment', 'right');
                c1hMarkers{10} = text(h3DAxes, vdX_mm(4), vdY_mm(4), vdZ_mm(4), '\lfloor', 'HorizontalAlignment', 'right');
                c1hMarkers{11} = text(h3DAxes, vdX_mm(2), vdY_mm(2), vdZ_mm(2), '\rceil');
                c1hMarkers{12} = text(h3DAxes, vdX_mm(1), vdY_mm(1), vdZ_mm(1), '\rfloor');
                
                % set handles/render group IDs
                obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels = [obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels, {c1hMarkers}];
                obj.vdRendered3DAnatomicalPlanesAlignmentsMarkersRenderGroupIds = [obj.vdRendered3DAnatomicalPlanesAlignmentsMarkersRenderGroupIds, dRenderGroupId];
                
                % update
                obj.UpdateRendered3DAnatomicalPlaneAlignmentMarkers(length(obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels));            
        end
        
        function Render3DRepresentativeVoxel(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            vdVolumeDimensions = obj.GetGeometricalImagingObject().GetVolumeDimensions();
            vdVolumeDimensions_mm = obj.GetGeometricalImagingObject().GetVolumeDimensions_mm();
            vdVoxelDimensions_mm = obj.GetGeometricalImagingObject().GetVoxelDimensions_mm();
            
            vdMinDim_mm = min(vdVolumeDimensions_mm);            
            vdMaxVoxelDim_mm = max(vdVoxelDimensions_mm);
            
            dNumVoxelToRender = 0.5 * vdMinDim_mm ./ vdMaxVoxelDim_mm;
            
            dFirstRow = vdVolumeDimensions(1) + 0.5;
            dLastRow = dFirstRow - dNumVoxelToRender;
            
            dFirstCol = vdVolumeDimensions(2) + 0.5;
            dLastCol = dFirstCol - dNumVoxelToRender;            
            
            dFirstSlice = vdVolumeDimensions(3) + 0.5;
            dLastSlice = dFirstSlice - dNumVoxelToRender;
            
            [vdX_mm, vdY_mm, vdZ_mm] = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetPositionCoordinatesFromVoxelIndices(...
                [dFirstRow   dFirstRow  dFirstRow   dFirstRow  dLastRow    dLastRow   dLastRow    dLastRow],...
                [dFirstCol   dFirstCol  dLastCol    dLastCol   dFirstCol   dFirstCol  dLastCol    dLastCol],...
                [dFirstSlice dLastSlice dFirstSlice dLastSlice dFirstSlice dLastSlice dFirstSlice dLastSlice]);
            
            c1hLines = GeometricalImagingObjectRenderer.Render3DRectangularPrism(h3DAxes, vdX_mm, vdY_mm, vdZ_mm);
            
            % set handles/render group IDs
            obj.c1c1hRendered3DRepresentativeVoxels = [obj.c1c1hRendered3DRepresentativeVoxels, {c1hLines}];
            obj.vdRendered3DRepresentativeVoxelsRenderGroupIds = [obj.vdRendered3DRepresentativeVoxelsRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DRepresentativeVoxel(length(obj.c1c1hRendered3DRepresentativeVoxels));
        end
        
        function Render3DRepresentativeVoxelDimensions(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            vdVolumeDimensions = obj.GetGeometricalImagingObject().GetVolumeDimensions();
            vdVolumeDimensions_mm = obj.GetGeometricalImagingObject().GetVolumeDimensions_mm();
            vdVoxelDimensions_mm = obj.GetGeometricalImagingObject().GetVoxelDimensions_mm();
            
            vdMinDim_mm = min(vdVolumeDimensions_mm);            
            vdMaxVoxelDim_mm = max(vdVoxelDimensions_mm);
            
            dNumVoxelToRender = (0.5 / 2) * vdMinDim_mm ./ vdMaxVoxelDim_mm;
            
            dFirstRow = vdVolumeDimensions(1) + 0.5;
            dMidRow = dFirstRow - dNumVoxelToRender;
            
            dFirstCol = vdVolumeDimensions(2) + 0.5;
            dMidCol = dFirstCol - dNumVoxelToRender;            
            
            dFirstSlice = vdVolumeDimensions(3) + 0.5;
            dMidSlice = dFirstSlice - dNumVoxelToRender;
            
            [vdX_mm, vdY_mm, vdZ_mm] = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetPositionCoordinatesFromVoxelIndices(...
                    [dMidRow     dFirstRow   dFirstRow],...
                    [dFirstCol   dMidCol     dFirstCol],...
                    [dFirstSlice dFirstSlice dMidSlice]);
              
            c1hLabels = cell(1,3);
                
            c1hLabels{1} = text(h3DAxes, vdX_mm(1), vdY_mm(1), vdZ_mm(1),...
                ['  ', num2str(vdVoxelDimensions_mm(1)), 'mm'], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
            c1hLabels{2} = text(h3DAxes, vdX_mm(2), vdY_mm(2), vdZ_mm(2),...
                [num2str(vdVoxelDimensions_mm(2)), 'mm  '], 'HorizontalAlignment', 'right', 'FontWeight', 'bold');
            c1hLabels{3} = text(h3DAxes, vdX_mm(3), vdY_mm(3), vdZ_mm(3),...
                ['  ', num2str(vdVoxelDimensions_mm(3)), 'mm'], 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
            
            % set handles/render group IDs
            obj.c1c1hRendered3DRepresentativeVoxelDimensions = [obj.c1c1hRendered3DRepresentativeVoxelDimensions, {c1hLabels}];
            obj.vdRendered3DRepresentativeVoxelDimensionsRenderGroupIds = [obj.vdRendered3DRepresentativeVoxelDimensionsRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DRepresentativeVoxelDimensions(length(obj.c1c1hRendered3DRepresentativeVoxelDimensions));
        end
        
        function Render3DImageVolumeCoordinateAxes(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            vdRowUnitVector = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetRowAxisUnitVector();
            vdColUnitVector = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetColumnAxisUnitVector();
            vdSliceUnitVector = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetSliceAxisUnitVector();
            
            vdFirstCorner_mm = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetFirstVoxelCornerPosition();
                        
            dMaxDimensions_mm = max(obj.GetGeometricalImagingObject().GetVolumeDimensions_mm());
            
            dUnitVectorLength_mm = dMaxDimensions_mm / 10;
            
            vdEndOfRowUnitVector = vdFirstCorner_mm + dUnitVectorLength_mm.*vdRowUnitVector;
            vdEndOfColUnitVector = vdFirstCorner_mm + dUnitVectorLength_mm.*vdColUnitVector;
            vdEndOfSliceUnitVector = vdFirstCorner_mm + dUnitVectorLength_mm.*vdSliceUnitVector;
            
            c1hLines = cell(1,3);
            
            c1hLines{1} = line(h3DAxes,...
                [vdFirstCorner_mm(1), vdEndOfRowUnitVector(1)],...
                [vdFirstCorner_mm(2), vdEndOfRowUnitVector(2)],...
                [vdFirstCorner_mm(3), vdEndOfRowUnitVector(3)]);
            c1hLines{2} = line(h3DAxes,...
                [vdFirstCorner_mm(1), vdEndOfColUnitVector(1)],...
                [vdFirstCorner_mm(2), vdEndOfColUnitVector(2)],...
                [vdFirstCorner_mm(3), vdEndOfColUnitVector(3)]);
            c1hLines{3} = line(h3DAxes,...
                [vdFirstCorner_mm(1), vdEndOfSliceUnitVector(1)],...
                [vdFirstCorner_mm(2), vdEndOfSliceUnitVector(2)],...
                [vdFirstCorner_mm(3), vdEndOfSliceUnitVector(3)]);
            
            % set handles/render group IDs
            obj.c1c1hRendered3DImageVolumeCoordinatesAxes = [obj.c1c1hRendered3DImageVolumeCoordinatesAxes, {c1hLines}];
            obj.vdRendered3DImageVolumeCoordinatesAxesRenderGroupIds = [obj.vdRendered3DImageVolumeCoordinatesAxesRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DImageVolumeCoordinateAxes(length(obj.c1c1hRendered3DImageVolumeCoordinatesAxes));
        end
        
        function Render3DImageVolumeCoordinateAxesLabels(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            vdRowUnitVector = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetRowAxisUnitVector();
            vdColUnitVector = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetColumnAxisUnitVector();
            vdSliceUnitVector = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetSliceAxisUnitVector();
            
            vdFirstCorner_mm = obj.GetGeometricalImagingObject().GetImageVolumeGeometry().GetFirstVoxelCornerPosition();
               
            dUnitVectorTextLength_mm = 50;
            
            vdRowUnitVectorTextPos_mm = vdFirstCorner_mm + dUnitVectorTextLength_mm.*vdRowUnitVector;
            vdColUnitVectorTextPos_mm = vdFirstCorner_mm + dUnitVectorTextLength_mm.*vdColUnitVector;
            vdSliceUnitVectorTextPos_mm = vdFirstCorner_mm + dUnitVectorTextLength_mm.*vdSliceUnitVector;
                        
            c1hLabels = cell(1,3);
            
            c1hLabels{1} = text(h3DAxes, vdRowUnitVectorTextPos_mm(1), vdRowUnitVectorTextPos_mm(2), vdRowUnitVectorTextPos_mm(3),...
                '+Row (i)');
            c1hLabels{2} = text(h3DAxes, vdColUnitVectorTextPos_mm(1), vdColUnitVectorTextPos_mm(2), vdColUnitVectorTextPos_mm(3),...
                '+Col (j)');
            c1hLabels{3} = text(h3DAxes, vdSliceUnitVectorTextPos_mm(1), vdSliceUnitVectorTextPos_mm(2), vdSliceUnitVectorTextPos_mm(3),...
                '+Slice (k)');
            
            % set handles/render group IDs
            obj.c1c1hRendered3DImageVolumeCoordinatesAxesLabels = [obj.c1c1hRendered3DImageVolumeCoordinatesAxesLabels, {c1hLabels}];
            obj.vdRendered3DImageVolumeCoordinatesAxesLabelsRenderGroupIds = [obj.vdRendered3DImageVolumeCoordinatesAxesLabelsRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DImageVolumeCoordinateAxesLabels(length(obj.c1c1hRendered3DImageVolumeCoordinatesAxesLabels));
        end
        
        function Render3DRepresentativePatient(obj, oImaging3DRenderAxes, dRenderGroupId)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % get axes
            h3DAxes = oImaging3DRenderAxes.GetAxes();
            
            % Render
            c1hPatientComponents = GeometricalImagingObjectRenderer.Render3DRepresentativePatientHelper(h3DAxes);
            
            % set handles/render group IDs
            obj.c1c1hRendered3DRepresentativePatients = [obj.c1c1hRendered3DRepresentativePatients, {c1hPatientComponents}];
            obj.vdRendered3DRepresentativePatientsRenderGroupIds = [obj.vdRendered3DRepresentativePatientsRenderGroupIds, dRenderGroupId];
            
            % update
            obj.UpdateRendered3DRepresentativePatient(length(obj.c1c1hRendered3DRepresentativePatients));
        end
    end
    
    
    methods (Access = public, Static = true)
        
        function h3DAxes = GetAxesFor3DRender()
            hFig = figure();
            hFig.Color = [0 0 0];
            
            h3DAxes = axes(hFig);            
        end
        
        function [vdScaledRowCoords_mm, vdScaledColumnCoords_mm] = GetScaledVoxelCoordinatesFromVoxelCoordinates(vdRowCoords, vdColumnCoords, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm)
            vdScaledRowCoords_mm = (vdRowCoords-1)*dRowVoxelSpacing_mm;
            vdScaledColumnCoords_mm = (vdColumnCoords-1)*dColumnVoxelSpacing_mm;
        end
        
        function [vdRowCoords, vdColumnCoords] = GetVoxelCoordinatesFromScaledVoxelCoordinates(vdScaledRowCoords_mm, vdScaledColumnCoords_mm, dRowVoxelSpacing_mm, dColumnVoxelSpacing_mm)
            vdRowCoords = (vdScaledRowCoords_mm / dRowVoxelSpacing_mm) + 1;
            vdColumnCoords = (vdScaledColumnCoords_mm / dColumnVoxelSpacing_mm) + 1;
        end
        
        function vdShiftedColour_rgb = ApplyColourShift(vdColour_rgb, dShift_rgb)
            % TODO
            
            vdShiftedColour_rgb = vdColour_rgb + dShift_rgb;
            
            vdShiftedColour_rgb(vdShiftedColour_rgb > 1) = 1;
            vdShiftedColour_rgb(vdShiftedColour_rgb < 0) = 0;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
     
    methods (Access = protected, Abstract = true)
        
        oGeometricalImagingObj = GetGeometricalImagingObject(obj)
        
        oRASGeometricalImagingObj = GetRASGeometricalImagingObject(obj)
    end
    
    
    methods (Access = protected, Static = true)
        
        
        function chVisible = GetVisibleStringFromBoolean(bVisible)
            if bVisible
                chVisible = 'on';
            else
                chVisible = 'off';
            end
        end
        
        function c1hLines = Render3DRectangularPrism(h3DAxes, vdX_mm, vdY_mm, vdZ_mm)
            c1hLines = cell(1,12);
            
            c1hLines{1}  = line(h3DAxes, [vdX_mm(1) vdX_mm(2)], [vdY_mm(1) vdY_mm(2)], [vdZ_mm(1) vdZ_mm(2)]);
            c1hLines{2}  = line(h3DAxes, [vdX_mm(1) vdX_mm(3)], [vdY_mm(1) vdY_mm(3)], [vdZ_mm(1) vdZ_mm(3)]);
            c1hLines{3}  = line(h3DAxes, [vdX_mm(1) vdX_mm(5)], [vdY_mm(1) vdY_mm(5)], [vdZ_mm(1) vdZ_mm(5)]);
            c1hLines{4}  = line(h3DAxes, [vdX_mm(7) vdX_mm(8)], [vdY_mm(7) vdY_mm(8)], [vdZ_mm(7) vdZ_mm(8)]);
            c1hLines{5}  = line(h3DAxes, [vdX_mm(7) vdX_mm(5)], [vdY_mm(7) vdY_mm(5)], [vdZ_mm(7) vdZ_mm(5)]);
            c1hLines{6}  = line(h3DAxes, [vdX_mm(7) vdX_mm(3)], [vdY_mm(7) vdY_mm(3)], [vdZ_mm(7) vdZ_mm(3)]);
            c1hLines{7}  = line(h3DAxes, [vdX_mm(6) vdX_mm(5)], [vdY_mm(6) vdY_mm(5)], [vdZ_mm(6) vdZ_mm(5)]);
            c1hLines{8}  = line(h3DAxes, [vdX_mm(6) vdX_mm(2)], [vdY_mm(6) vdY_mm(2)], [vdZ_mm(6) vdZ_mm(2)]);
            c1hLines{9}  = line(h3DAxes, [vdX_mm(6) vdX_mm(8)], [vdY_mm(6) vdY_mm(8)], [vdZ_mm(6) vdZ_mm(8)]);
            c1hLines{10} = line(h3DAxes, [vdX_mm(4) vdX_mm(3)], [vdY_mm(4) vdY_mm(3)], [vdZ_mm(4) vdZ_mm(3)]);
            c1hLines{11} = line(h3DAxes, [vdX_mm(4) vdX_mm(2)], [vdY_mm(4) vdY_mm(2)], [vdZ_mm(4) vdZ_mm(2)]);
            c1hLines{12} = line(h3DAxes, [vdX_mm(4) vdX_mm(8)], [vdY_mm(4) vdY_mm(8)], [vdZ_mm(4) vdZ_mm(8)]);
        end
    end
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        function BringRenderedSliceIntersectionLinesToTop(obj, dIntersectionLinesIndex)
            c1hLines = obj.c1c1hRenderedSliceIntersections{dIntersectionLinesIndex};
            
            vhChildren = c1hLines{1}.Parent.Children;
            
            dLine1Index = [];
            dLine2Index = [];
            
            for dChildrenIndex=1:length(vhChildren)
                if isempty(dLine1Index) && vhChildren(dChildrenIndex) == c1hLines{1}
                    dLine1Index = dChildrenIndex;
                elseif isempty(dLine2Index) && vhChildren(dChildrenIndex) == c1hLines{2}
                    dLine2Index = dChildrenIndex;
                end
            end
            
            vdIndices = 1:length(vhChildren);
            vdIndices([dLine1Index, dLine2Index]) = [];
            vdIndices = [dLine1Index, dLine2Index, vdIndices];
            
            c1hLines{1}.Parent.Children = vhChildren(vdIndices);
        end
        
        % 3D Update Functions:
        function UpdateRendered3DAxes(obj, dRenderedAxesIndex)
            c1hAxesHandles = obj.c1c1h3DAxesHandles{dRenderedAxesIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DAxes);
            
            c1hAxesHandles{1}.Visible = chVisible;
            c1hAxesHandles{1}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            c1hAxesHandles{1}.LineStyle = obj.ch3DAxesPositiveAxisLineStyle;
            
            c1hAxesHandles{2}.Visible = chVisible;
            c1hAxesHandles{2}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            c1hAxesHandles{2}.LineStyle = obj.ch3DAxesNegativeAxisLineStyle;
            
            c1hAxesHandles{3}.Visible = chVisible;
            c1hAxesHandles{3}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            c1hAxesHandles{3}.LineStyle = obj.ch3DAxesPositiveAxisLineStyle;
            
            c1hAxesHandles{4}.Visible = chVisible;
            c1hAxesHandles{4}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            c1hAxesHandles{4}.LineStyle = obj.ch3DAxesNegativeAxisLineStyle;
            
            c1hAxesHandles{5}.Visible = chVisible;
            c1hAxesHandles{5}.Color = obj.vdVolumeDimensionAxialColour_rgb;
            c1hAxesHandles{5}.LineStyle = obj.ch3DAxesPositiveAxisLineStyle;
            
            c1hAxesHandles{6}.Visible = chVisible;
            c1hAxesHandles{6}.Color = obj.vdVolumeDimensionAxialColour_rgb;
            c1hAxesHandles{6}.LineStyle = obj.ch3DAxesNegativeAxisLineStyle;
        end
        
        function UpdateRendered3DAxesCartesianLabels(obj, dRenderedAxesLabelsIndex)
            c1hAxesLabelsHandles = obj.c1c1h3DAxesCartesianLabelHandles{dRenderedAxesLabelsIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DAxesCartesianLabels);
            
            c1hAxesLabelsHandles{1}.Visible = chVisible;
            c1hAxesLabelsHandles{1}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            c1hAxesLabelsHandles{1}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{2}.Visible = chVisible;
            c1hAxesLabelsHandles{2}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            c1hAxesLabelsHandles{2}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{3}.Visible = chVisible;
            c1hAxesLabelsHandles{3}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            c1hAxesLabelsHandles{3}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{4}.Visible = chVisible;
            c1hAxesLabelsHandles{4}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            c1hAxesLabelsHandles{4}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{5}.Visible = chVisible;
            c1hAxesLabelsHandles{5}.Color = obj.vdVolumeDimensionAxialColour_rgb;
            c1hAxesLabelsHandles{5}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{6}.Visible = chVisible;
            c1hAxesLabelsHandles{6}.Color = obj.vdVolumeDimensionAxialColour_rgb;
            c1hAxesLabelsHandles{6}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
        end
        
        function UpdateRendered3DAxesAnatomicalLabels(obj, dRenderedAxesLabelsIndex)
            c1hAxesLabelsHandles = obj.c1c1h3DAxesAnatomicalLabelHandles{dRenderedAxesLabelsIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DAxesAnatomicalLabels);
            
            c1hAxesLabelsHandles{1}.Visible = chVisible;
            c1hAxesLabelsHandles{1}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            c1hAxesLabelsHandles{1}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{2}.Visible = chVisible;
            c1hAxesLabelsHandles{2}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            c1hAxesLabelsHandles{2}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{3}.Visible = chVisible;
            c1hAxesLabelsHandles{3}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            c1hAxesLabelsHandles{3}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{4}.Visible = chVisible;
            c1hAxesLabelsHandles{4}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            c1hAxesLabelsHandles{4}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{5}.Visible = chVisible;
            c1hAxesLabelsHandles{5}.Color = obj.vdVolumeDimensionAxialColour_rgb;
            c1hAxesLabelsHandles{5}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
            
            c1hAxesLabelsHandles{6}.Visible = chVisible;
            c1hAxesLabelsHandles{6}.Color = obj.vdVolumeDimensionAxialColour_rgb;
            c1hAxesLabelsHandles{6}.FontSize = obj.dDisplay3DAxesLabelsFontSize;
        end
        
        function UpdateRendered3DImageVolumeOutline(obj, dRenderedOutlineIndex)
            c1hLines = obj.c1c1hRendered3DImageVolumeOutlines{dRenderedOutlineIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DImageVolumeOutline);
            vdColour_rgb = obj.vd3DImageVolumeOutlineColour_rgb;
            dLineWidth = obj.d3DImageVolumeOutlineLineWidth;
            chLineStyle = obj.ch3DImageVolumeOutlineLineStyle;
            
            for dLineIndex=1:length(c1hLines)
                c1hLines{dLineIndex}.Visible = chVisible;
                c1hLines{dLineIndex}.Color = vdColour_rgb;
                c1hLines{dLineIndex}.LineWidth = dLineWidth;
                c1hLines{dLineIndex}.LineStyle = chLineStyle;
            end
        end
        
        function UpdateRendered3DImageVolumeDimensionsVoxels(obj, dRenderedDimensionsIndex)
            c1hLabels = obj.c1c1hRendered3DImageVolumeDimensionsVoxels{dRenderedDimensionsIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DImageVolumeDimensionsVoxels);
            
            vdRowColour_rgb = obj.vdVolumeDimensionIColour_rgb;
            vdColColour_rgb = obj.vdVolumeDimensionJColour_rgb;
            vdSliceColour_rgb = obj.vdVolumeDimensionKColour_rgb;
            
            dFontSize = obj.d3DImageVolumeDimensionsVoxelsFontSize;
            
            c1hLabels{1}.Visible = chVisible;
            c1hLabels{1}.Color = vdRowColour_rgb;
            c1hLabels{1}.FontSize = dFontSize;
            
            c1hLabels{2}.Visible = chVisible;
            c1hLabels{2}.Color = vdColColour_rgb;
            c1hLabels{2}.FontSize = dFontSize;
            
            c1hLabels{3}.Visible = chVisible;
            c1hLabels{3}.Color = vdSliceColour_rgb;
            c1hLabels{3}.FontSize = dFontSize;
        end
        
        function UpdateRendered3DImageVolumeDimensionsMetric(obj, dRenderedDimensionsIndex)
            c1hLabels = obj.c1c1hRendered3DImageVolumeDimensionsMetric{dRenderedDimensionsIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DImageVolumeDimensionsMetric);
            
            vdRowColour_rgb = obj.vdVolumeDimensionIColour_rgb;
            vdColColour_rgb = obj.vdVolumeDimensionJColour_rgb;
            vdSliceColour_rgb = obj.vdVolumeDimensionKColour_rgb;
            
            dFontSize = obj.d3DImageVolumeDimensionsMetricFontSize;
            
            c1hLabels{1}.Visible = chVisible;
            c1hLabels{1}.Color = vdRowColour_rgb;
            c1hLabels{1}.FontSize = dFontSize;
            
            c1hLabels{2}.Visible = chVisible;
            c1hLabels{2}.Color = vdColColour_rgb;
            c1hLabels{2}.FontSize = dFontSize;
            
            c1hLabels{3}.Visible = chVisible;
            c1hLabels{3}.Color = vdSliceColour_rgb;
            c1hLabels{3}.FontSize = dFontSize;
        end
        
        function UpdateRendered3DAnatomicalPlanes(obj, dRenderedPlanesIndex)
            c1hPlanes = obj.c1c1hRendered3DAnatomicalPlanes{dRenderedPlanesIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DAnatomicalPlanes);
            dAlpha = obj.d3DAnatomicalPlanesAlpha;
            
            c1hPlanes{1}.Visible = chVisible;
            c1hPlanes{1}.FaceColor = obj.vdVolumeDimensionSagittalColour_rgb;
            c1hPlanes{1}.FaceAlpha = dAlpha;
            c1hPlanes{1}.EdgeColor = obj.vdVolumeDimensionSagittalColour_rgb;
                        
            c1hPlanes{2}.Visible = chVisible;
            c1hPlanes{2}.FaceColor = obj.vdVolumeDimensionCoronalColour_rgb;
            c1hPlanes{2}.FaceAlpha = dAlpha;
            c1hPlanes{2}.EdgeColor = obj.vdVolumeDimensionCoronalColour_rgb;
                        
            c1hPlanes{3}.Visible = chVisible;
            c1hPlanes{3}.FaceColor = obj.vdVolumeDimensionAxialColour_rgb;
            c1hPlanes{3}.FaceAlpha = dAlpha;
            c1hPlanes{3}.EdgeColor = obj.vdVolumeDimensionAxialColour_rgb;
        end
        
        function UpdateRendered3DAnatomicalPlaneLabels(obj, dRenderedMarkersIndex)
            c1hLabels = obj.c1c1hRendered3DAnatomicalPlanesLabels{dRenderedMarkersIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DAnatomicalPlanesLabels);
            dFontSize = obj.d3DAnatomicalPlanesLabelsFontSize;
            
            c1hLabels{1}.Visible = chVisible;
            c1hLabels{1}.FontSize = dFontSize;
            c1hLabels{1}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            
            c1hLabels{2}.Visible = chVisible;
            c1hLabels{2}.FontSize = dFontSize;
            c1hLabels{2}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            
            c1hLabels{3}.Visible = chVisible;
            c1hLabels{3}.FontSize = dFontSize;
            c1hLabels{3}.Color = obj.vdVolumeDimensionAxialColour_rgb;
        end
        
        function UpdateRendered3DAnatomicalPlaneAlignmentMarkers(obj, dRenderedMarkersIndex)
            c1hMarkers = obj.c1c1hRendered3DAnatomicalPlanesAlignmentsMarkersLabels{dRenderedMarkersIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DAnatomicalPlanesAlignmentMarkers);
            dFontSize = obj.d3DAnatomicalPlanesAlignmentMarkerFontSize;
            
            % Sagittal
            for dMarkerIndex = 1:4
                c1hMarkers{dMarkerIndex}.Visible = chVisible;
                c1hMarkers{dMarkerIndex}.FontSize = dFontSize;
                c1hMarkers{dMarkerIndex}.Color = obj.vdVolumeDimensionSagittalColour_rgb;
            end
            
            % Coronal
            for dMarkerIndex = 5:8
                c1hMarkers{dMarkerIndex}.Visible = chVisible;
                c1hMarkers{dMarkerIndex}.FontSize = dFontSize;
                c1hMarkers{dMarkerIndex}.Color = obj.vdVolumeDimensionCoronalColour_rgb;
            end
            
            % Axial
            for dMarkerIndex = 9:12
                c1hMarkers{dMarkerIndex}.Visible = chVisible;
                c1hMarkers{dMarkerIndex}.FontSize = dFontSize;
                c1hMarkers{dMarkerIndex}.Color = obj.vdVolumeDimensionAxialColour_rgb;
            end
        end
        
        function UpdateRendered3DRepresentativeVoxel(obj, dRenderedVoxelIndex)
            c1hLines = obj.c1c1hRendered3DRepresentativeVoxels{dRenderedVoxelIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DRepresentativeVoxel);
            vdColour_rgb = obj.vd3DRepresentativeVoxelColour_rgb;
            dLineWidth = obj.d3DRepresentativeVoxelLineWidth;
            chLineStyle = obj.ch3DRepresentativeVoxelLineStyle;
            
            for dLineIndex=1:length(c1hLines)
                c1hLines{dLineIndex}.Visible = chVisible;
                c1hLines{dLineIndex}.Color = vdColour_rgb;
                c1hLines{dLineIndex}.LineWidth = dLineWidth;
                c1hLines{dLineIndex}.LineStyle = chLineStyle;
            end
        end
        
        function UpdateRendered3DRepresentativeVoxelDimensions(obj, dRenderedDimensionsIndex)
            c1hLabels = obj.c1c1hRendered3DRepresentativeVoxelDimensions{dRenderedDimensionsIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DRepresentativeVoxelDimensions);
            dFontSize = obj.d3DRepresentativeVoxelDimensionsFontSize;
            
            c1hLabels{1}.Visible = chVisible;
            c1hLabels{1}.Color = obj.vdVolumeDimensionIColour_rgb;
            c1hLabels{1}.FontSize = dFontSize;
            
            c1hLabels{2}.Visible = chVisible;
            c1hLabels{2}.Color = obj.vdVolumeDimensionJColour_rgb;
            c1hLabels{2}.FontSize = dFontSize;
            
            c1hLabels{3}.Visible = chVisible;
            c1hLabels{3}.Color = obj.vdVolumeDimensionKColour_rgb;
            c1hLabels{3}.FontSize = dFontSize;
        end
        
        function UpdateRendered3DImageVolumeCoordinateAxes(obj, dRenderedAxesIndex)
            c1hLines = obj.c1c1hRendered3DImageVolumeCoordinatesAxes{dRenderedAxesIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DImageVolumeCoordinateAxes);
            dLineWidth = obj.d3DImageVolumeCoordinateAxesLineWidth;
            chLineStyle = obj.ch3DImageVolumeCoordinateAxesLineStyle;
            
            c1hLines{1}.Visible = chVisible;
            c1hLines{1}.Color = obj.vdVolumeDimensionIColour_rgb;
            c1hLines{1}.LineWidth = dLineWidth;
            c1hLines{1}.LineStyle = chLineStyle;
            
            c1hLines{2}.Visible = chVisible;
            c1hLines{2}.Color = obj.vdVolumeDimensionJColour_rgb;
            c1hLines{2}.LineWidth = dLineWidth;
            c1hLines{2}.LineStyle = chLineStyle;
            
            c1hLines{3}.Visible = chVisible;
            c1hLines{3}.Color = obj.vdVolumeDimensionKColour_rgb;
            c1hLines{3}.LineWidth = dLineWidth;
            c1hLines{3}.LineStyle = chLineStyle;
        end
        
        function UpdateRendered3DImageVolumeCoordinateAxesLabels(obj, dRenderedLabelsIndex)
            c1hLabels = obj.c1c1hRendered3DImageVolumeCoordinatesAxesLabels{dRenderedLabelsIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DImageVolumeCoordinateAxesLabels);
            dFontSize = obj.d3DImageVolumeCoordinateAxesLabelsFontSize;
            
            c1hLabels{1}.Visible = chVisible;
            c1hLabels{1}.Color = obj.vdVolumeDimensionIColour_rgb;
            c1hLabels{1}.FontSize = dFontSize;
            
            c1hLabels{2}.Visible = chVisible;
            c1hLabels{2}.Color = obj.vdVolumeDimensionJColour_rgb;
            c1hLabels{2}.FontSize = dFontSize;
            
            c1hLabels{3}.Visible = chVisible;
            c1hLabels{3}.Color = obj.vdVolumeDimensionKColour_rgb;
            c1hLabels{3}.FontSize = dFontSize;
        end
        
        function UpdateRendered3DRepresentativePatient(obj, dRenderedPatientIndex)
            c1hPatientComponents = obj.c1c1hRendered3DRepresentativePatients{dRenderedPatientIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.bDisplay3DRepresentativePatient);
            dAlpha = obj.d3DRepresentativePatientAlpha;
            
            for dComponentIndex=1:length(c1hPatientComponents)
                c1hPatientComponents{dComponentIndex}.Visible = chVisible;
                c1hPatientComponents{dComponentIndex}.FaceAlpha = dAlpha;
            end
        end
        
        % 2D Update Functions:
        function UpdateRenderedSliceIntersections(obj, dRenderedSliceIntersectionsIndex)
            c1hLines = obj.c1c1hRenderedSliceIntersections{dRenderedSliceIntersectionsIndex};
            
            chVisible = GeometricalImagingObjectRenderer.GetVisibleStringFromBoolean(obj.vbDisplaySliceIntersections(dRenderedSliceIntersectionsIndex));
            vdColour_rgb = obj.vdSliceIntersectionsColour_rgb;
            dLineWidth = obj.dSliceIntersectionsLineWidth;
            chLineStyle = obj.chSliceIntersectionsLineStyle;
            
            for dLineIndex=1:length(c1hLines)
                c1hLines{dLineIndex}.Visible = chVisible;
                c1hLines{dLineIndex}.Color = vdColour_rgb;
                c1hLines{dLineIndex}.LineWidth = dLineWidth;
                c1hLines{dLineIndex}.LineStyle = chLineStyle;
            end
        end
    end
    
    
     methods (Access = private, Static = true)
         
         function c1hPatientComponents = Render3DRepresentativePatientHelper(h3DAxes)
             c1hPatientComponents = cell(12,1);
             
             vdColour = [1 1 1]; % white
             vdHighlightColour = [1 0 0]; % red
             vdEdgeColour = 'none';
             
             dScale = 400;
             
             % >> HEAD:
             [m2dHeadX,m2dHeadY,m2dHeadZ] = sphere();
             
             m2dHeadX = m2dHeadX ./ 4;
             m2dHeadY = m2dHeadY ./ 4;
             m2dHeadZ = m2dHeadZ ./ 4;
             
             m2dHeadZ = m2dHeadZ + 0.75;
             
             m3dColours = ones([size(m2dHeadX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             c1hPatientComponents{1} = surf(h3DAxes, dScale.*m2dHeadX, dScale.*m2dHeadY, dScale.*m2dHeadZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             % >> NOSE:
             
             vdNoseX = [0 -0.05 0];
             vdNoseY = [0.24 0.24 0.34];
             vdNoseZ = [0.8 0.7 0.7];
             
             c1hPatientComponents{2} = patch(h3DAxes, dScale.*vdNoseX, dScale.*vdNoseY, dScale.*vdNoseZ,...
                 vdHighlightColour,...
                 'EdgeColor', vdEdgeColour);
             
             vdNoseX = [0 +0.05 0];
             vdNoseY = [0.24 0.24 0.34];
             vdNoseZ = [0.8 0.7 0.7];
             
             c1hPatientComponents{3} = patch(h3DAxes, dScale.*vdNoseX, dScale.*vdNoseY, dScale.*vdNoseZ,...
                 vdHighlightColour,...
                 'EdgeColor', vdEdgeColour);
             
             % >> TORSO
             
             [m2dTorsoX, m2dTorsoY, m2dTorsoZ] = cylinder(0.15);
             
             m2dTorsoZ = m2dTorsoZ - 0.5;
             
             m3dColours = ones([size(m2dTorsoX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             c1hPatientComponents{4} = surf(h3DAxes, dScale.*m2dTorsoX, dScale.*m2dTorsoY, dScale.*m2dTorsoZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             % >> LEGS
             
             [m2dLegX, m2dLegY, m2dLegZ] = cylinder(0.075);
             
             m2dLegX = m2dLegX + 0.075;
             m2dLegZ = m2dLegZ - 1.4;
             
             m3dColours = ones([size(m2dLegX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             hLeftLeg = surf(h3DAxes, dScale.*m2dLegX, dScale.*m2dLegY, dScale.*m2dLegZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             rotate(hLeftLeg, [0 1 0], -25, dScale.*[+0.075, 0 -0.4]);
             c1hPatientComponents{5} = hLeftLeg;
             
             [m2dLegX, m2dLegY, m2dLegZ] = cylinder(0.075);
             
             m2dLegX = m2dLegX - 0.075;
             m2dLegZ = m2dLegZ - 1.4;
             
             m3dColours = ones([size(m2dLegX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             hRightLeg = surf(h3DAxes, dScale.*m2dLegX, dScale.*m2dLegY, dScale.*m2dLegZ,...
                 m3dColours,....
                 'EdgeColor', vdEdgeColour);
             
             rotate(hRightLeg, [0 1 0], 25, dScale.*[-0.075, 0 -0.4]);
             c1hPatientComponents{6} = hRightLeg;
             
             % >> FEET
             [m2dFootX, m2dFootY, m2dFootZ] = cylinder(0.075);
             
             m2dFootX = m2dFootX + 0.46;
             m2dFootZ = m2dFootZ ./ 4;
             m2dFootZ = m2dFootZ - 1.23;
             
             m3dColours = ones([size(m2dFootX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             hLeftFoot = surf(h3DAxes, dScale.*m2dFootX, dScale.*m2dFootY, dScale.*m2dFootZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             rotate(hLeftFoot, [1 0 0], -90, dScale.*[+0.46, 0 -1.23]);
             c1hPatientComponents{7} = hLeftFoot;
             
             [m2dFootX, m2dFootY, m2dFootZ] = cylinder(0.075);
             
             m2dFootX = m2dFootX - 0.46;
             m2dFootZ = m2dFootZ ./ 4;
             m2dFootZ = m2dFootZ - 1.23;
             
             m3dColours = ones([size(m2dFootX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             hRightFoot = surf(h3DAxes, dScale.*m2dFootX, dScale.*m2dFootY, dScale.*m2dFootZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             rotate(hRightFoot, [1 0 0], -90, dScale.*[-0.46, 0 -1.23]);
             c1hPatientComponents{8} = hRightFoot;
             
             % >> ARMS
             
             [m2dArmX, m2dArmY, m2dArmZ] = cylinder(0.075);
             
             m2dArmX = m2dArmX + 0.10;
             m2dArmZ = m2dArmZ + 0.3;
             
             m3dColours = ones([size(m2dArmX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             hLeftArm = surf(h3DAxes, dScale.*m2dArmX, dScale.*m2dArmY, dScale.*m2dArmZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             rotate(hLeftArm, [0 1 0], 55, dScale.*[+0.10, 0 0.3]);
             c1hPatientComponents{9} = hLeftArm;
             
             [m2dArmX, m2dArmY, m2dArmZ] = cylinder(0.075);
             
             m2dArmX = m2dArmX - 0.10;
             m2dArmZ = m2dArmZ + 0.3;
             
             m3dColours = ones([size(m2dArmX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             hRightArm = surf(h3DAxes, dScale.*m2dArmX, dScale.*m2dArmY, dScale.*m2dArmZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             rotate(hRightArm, [0 1 0], -55, dScale.*[-0.10, 0 0.3]);
             c1hPatientComponents{10} = hRightArm;
             
             % >> HANDS
             
             [m2dHandX,m2dHandY,m2dHandZ] = sphere();
             
             m2dHandX = m2dHandX ./ 8;
             m2dHandY = m2dHandY ./ 8;
             m2dHandZ = m2dHandZ ./ 8;
             
             m2dHandX = m2dHandX + 1;
             m2dHandZ = m2dHandZ + 0.92;
             
             m3dColours = ones([size(m2dHandX),3]);
             
             m3dColours(:,:,1) = vdColour(1);
             m3dColours(:,:,2) = vdColour(2);
             m3dColours(:,:,3) = vdColour(3);
             
             c1hPatientComponents{11} = surf(h3DAxes, dScale.*m2dHandX, dScale.*m2dHandY, dScale.*m2dHandZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
             
             
             [m2dHandX,m2dHandY,m2dHandZ] = sphere();
             
             m2dHandX = m2dHandX ./ 8;
             m2dHandY = m2dHandY ./ 8;
             m2dHandZ = m2dHandZ ./ 8;
             
             m2dHandX = m2dHandX - 1;
             m2dHandZ = m2dHandZ + 0.92;
             
             m3dColours = ones([size(m2dHandX),3]);
             
             m3dColours(:,:,1) = vdHighlightColour(1);
             m3dColours(:,:,2) = vdHighlightColour(2);
             m3dColours(:,:,3) = vdHighlightColour(3);
             
             c1hPatientComponents{12} = surf(h3DAxes, dScale.*m2dHandX, dScale.*m2dHandY, dScale.*m2dHandZ,...
                 m3dColours,...
                 'EdgeColor', vdEdgeColour);
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


