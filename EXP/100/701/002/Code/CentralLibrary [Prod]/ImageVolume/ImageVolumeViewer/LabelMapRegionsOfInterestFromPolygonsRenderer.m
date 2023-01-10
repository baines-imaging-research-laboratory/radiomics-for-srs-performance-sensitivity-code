classdef LabelMapRegionsOfInterestFromPolygonsRenderer < LabelMapRegionsOfInterestRenderer
    %LabelMapRegionsOfInterestFromPolygonsRenderer
    
    % Primary Author: David DeVries
    % Created: Sept 5, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
         
    properties (SetAccess = private, GetAccess = public)
        c1vbDisplayPolygon % cell array for each ROI, vector of booleans the length of the number of poylgons in each ROI
        
        c1m2dPolygonFaceColour_rgb
        c1vdPolygonFaceAlpha
        c1m2dPolygonEdgeColour_rgb
        c1vdPolygonLineWidth
        c1c1chPolygonLineStyle
        c1m2dPolygonMarkerFaceColour_rgb
        c1m2dPolygonMarkerEdgeColour_rgb
        c1c1chPolygonMarkerSymbol 
        c1vdPolygonMarkerSize
        
        c1vbDisplay3DPolygon
        
        c1m2d3DPolygonFaceColour_rgb
        c1vd3DPolygonFaceAlpha
        c1m2d3DPolygonEdgeColour_rgb
        c1vd3DPolygonLineWidth
        c1c1ch3DPolygonLineStyle
        c1m2d3DPolygonMarkerFaceColour_rgb
        c1m2d3DPolygonMarkerEdgeColour_rgb
        c1c1ch3DPolygonMarkerSymbol 
        c1vd3DPolygonMarkerSize
        
        c1hPolygonHandles = {}
        vdPolygonHandlesRegionOfInterestNumber = []
        vdPolygonHandlesPolygonNumber = []
        vdPolygonHandlerRenderGroupId = []
                
        c1h3DPolygonHandles = {}
        vd3DPolygonHandlesRegionOfInterestNumber = []
        vd3DPolygonHandlesPolygonNumber = []
        vd3DPolygonHandlesRenderGroupId = []
    end
    
    properties (Constant = true, GetAccess = private)
        dDefaultPolygonFaceAlpha = 0
        dDefaultPolygonLineWidth = 1
        chDefaultPolygonLineStyle = '-'
        chDefaultPolygonMarkerSymbol = 'o'
        dDefaultPolygonMarkerSize = 6
        dDefaultPolygonMarkerColourShift_rgb = -0.2
        
        dDefault3DPolygonFaceAlpha = 0
        dDefault3DPolygonLineWidth = 1
        chDefault3DPolygonLineStyle = '-'
        chDefault3DPolygonMarkerSymbol = 'none'
        dDefault3DPolygonMarkerSize = 2
        dDefault3DPolygonMarkerColourShift_rgb = 0
    end
    
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
          
    methods (Access = public)
        
        function obj = LabelMapRegionsOfInterestFromPolygonsRenderer(oRegionsOfInterest, oRASRegionsOfInterest)
            %obj = LabelMapRegionsOfInterestFromPolygonsRenderer(oRegionsOfInterest)
            %
            % SYNTAX:
            %  obj = LabelMapRegionsOfInterestFromPolygonsRenderer(oRegionsOfInterest)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  oRegionsOfInterest: 
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            
            % super-class constructor
            obj@LabelMapRegionsOfInterestRenderer(oRegionsOfInterest, oRASRegionsOfInterest);
            
            % set starting values for the per polygon rendering
            dNumberOfRois = oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            obj.c1vbDisplayPolygon = cell(dNumberOfRois,1);
            obj.c1m2dPolygonEdgeColour_rgb = cell(dNumberOfRois,1);
            obj.c1vdPolygonLineWidth = cell(dNumberOfRois,1);
            obj.c1c1chPolygonLineStyle = cell(dNumberOfRois,1);
            obj.c1m2dPolygonMarkerFaceColour_rgb = cell(dNumberOfRois,1);
            obj.c1m2dPolygonMarkerEdgeColour_rgb = cell(dNumberOfRois,1);
            obj.c1c1chPolygonMarkerSymbol = cell(dNumberOfRois,1);
            obj.c1vdPolygonMarkerSize = cell(dNumberOfRois,1);
                   
            obj.c1vbDisplay3DPolygon = cell(dNumberOfRois,1);
            obj.c1m2d3DPolygonEdgeColour_rgb = cell(dNumberOfRois,1);
            obj.c1vd3DPolygonLineWidth = cell(dNumberOfRois,1);
            obj.c1c1ch3DPolygonLineStyle = cell(dNumberOfRois,1);
            obj.c1m2d3DPolygonMarkerFaceColour_rgb = cell(dNumberOfRois,1);
            obj.c1m2d3DPolygonMarkerEdgeColour_rgb = cell(dNumberOfRois,1);
            obj.c1c1ch3DPolygonMarkerSymbol = cell(dNumberOfRois,1);
            obj.c1vd3DPolygonMarkerSize = cell(dNumberOfRois,1);
            
            % Set default values
            for dRoiIndex=1:dNumberOfRois
                dNumPolygons = oRegionsOfInterest.GetNumberOfPolygonsByRegionOfInterestNumber(dRoiIndex);
                vdRoiColour_rgb = oRegionsOfInterest.GetDefaultRenderColourByRegionOfInterestNumber_rgb(dRoiIndex);
                
                obj.c1vbDisplayPolygon{dRoiIndex} = true(dNumPolygons,1); % display all
                obj.c1m2dPolygonFaceColour_rgb{dRoiIndex} = repmat(vdRoiColour_rgb, dNumPolygons, 1);
                obj.c1vdPolygonFaceAlpha{dRoiIndex} = repmat(LabelMapRegionsOfInterestFromPolygonsRenderer.dDefaultPolygonFaceAlpha, dNumPolygons, 1);
                obj.c1m2dPolygonEdgeColour_rgb{dRoiIndex} = repmat(vdRoiColour_rgb, dNumPolygons, 1);
                obj.c1vdPolygonLineWidth{dRoiIndex} = repmat(LabelMapRegionsOfInterestFromPolygonsRenderer.dDefaultPolygonLineWidth, dNumPolygons, 1);
                obj.c1c1chPolygonLineStyle{dRoiIndex} = repmat({LabelMapRegionsOfInterestFromPolygonsRenderer.chDefaultPolygonLineStyle}, dNumPolygons, 1);
                obj.c1m2dPolygonMarkerFaceColour_rgb{dRoiIndex} = repmat(vdRoiColour_rgb, dNumPolygons, 1);
                obj.c1m2dPolygonMarkerEdgeColour_rgb{dRoiIndex} = repmat(RegionsOfInterestRenderer.ApplyColourShift(vdRoiColour_rgb, LabelMapRegionsOfInterestFromPolygonsRenderer.dDefaultPolygonMarkerColourShift_rgb), dNumPolygons, 1);
                obj.c1c1chPolygonMarkerSymbol{dRoiIndex} = repmat({LabelMapRegionsOfInterestFromPolygonsRenderer.chDefaultPolygonMarkerSymbol}, dNumPolygons, 1);
                obj.c1vdPolygonMarkerSize{dRoiIndex} = repmat(LabelMapRegionsOfInterestFromPolygonsRenderer.dDefaultPolygonMarkerSize, dNumPolygons, 1);
                
                obj.c1vbDisplay3DPolygon{dRoiIndex} = true(dNumPolygons,1);
                obj.c1m2d3DPolygonFaceColour_rgb{dRoiIndex} = repmat(vdRoiColour_rgb, dNumPolygons, 1);
                obj.c1vd3DPolygonFaceAlpha{dRoiIndex} = repmat(LabelMapRegionsOfInterestFromPolygonsRenderer.dDefault3DPolygonFaceAlpha, dNumPolygons, 1);
                obj.c1m2d3DPolygonEdgeColour_rgb{dRoiIndex} = repmat(vdRoiColour_rgb, dNumPolygons, 1);
                obj.c1vd3DPolygonLineWidth{dRoiIndex} = repmat(LabelMapRegionsOfInterestFromPolygonsRenderer.dDefault3DPolygonLineWidth, dNumPolygons, 1);
                obj.c1c1ch3DPolygonLineStyle{dRoiIndex} = repmat({LabelMapRegionsOfInterestFromPolygonsRenderer.chDefault3DPolygonLineStyle}, dNumPolygons, 1);
                obj.c1m2d3DPolygonMarkerFaceColour_rgb{dRoiIndex} = repmat(vdRoiColour_rgb, dNumPolygons, 1);
                obj.c1m2d3DPolygonMarkerEdgeColour_rgb{dRoiIndex} = repmat(RegionsOfInterestRenderer.ApplyColourShift(vdRoiColour_rgb, LabelMapRegionsOfInterestFromPolygonsRenderer.dDefault3DPolygonMarkerColourShift_rgb), dNumPolygons, 1);
                obj.c1c1ch3DPolygonMarkerSymbol{dRoiIndex} = repmat({LabelMapRegionsOfInterestFromPolygonsRenderer.chDefault3DPolygonMarkerSymbol}, dNumPolygons, 1);
                obj.c1vd3DPolygonMarkerSize{dRoiIndex} = repmat(LabelMapRegionsOfInterestFromPolygonsRenderer.dDefault3DPolygonMarkerSize, dNumPolygons, 1);
            end
        end
        
        
        % *************************** RENDERING ***************************
        
        function UpdateAll(obj)
            arguments
                obj
            end
            
            obj.UpdateAll3D();
            obj.UpdateAllOnPlane();
        end
        
        function UpdateAll3D(obj)
            arguments
                obj
            end
            
            % Super-class call
            UpdateAll3D@LabelMapRegionsOfInterestRenderer(obj);
            
            % local calls
            obj.UpdateAll3DPolygons();
        end
        
        function UpdateAllOnPlane(obj)
            arguments
                obj
            end
            
            % Super-class call
            UpdateAllOnPlane@LabelMapRegionsOfInterestRenderer(obj);
            
            % local calls
            obj.UpdateAllPolygons();
        end
        
        function UpdateAllPolygons(obj)
            dNumPolygonsRendered = length(obj.c1hPolygonHandles);
            
            for dPolygonIndex=1:dNumPolygonsRendered
                obj.UpdateRenderedPolygon(dPolygonIndex);
            end
        end
        
        function UpdateAll3DPolygons(obj)
            dNum3DPolygonsRendered = length(obj.c1h3DPolygonHandles);
            
            for d3DPolygonIndex=1:dNum3DPolygonsRendered
                obj.UpdateRendered3DPolygon(d3DPolygonIndex);
            end
        end
        
        function DeleteAll(obj)
            % Super-class call
            DeleteAll@LabelMapRegionsOfInterestRenderer(obj);
            
            % Delete polygons
            for dPolygonIndex=1:length(obj.c1hPolygonHandles)
                delete(obj.c1hPolygonHandles{dPolygonIndex});
            end
            
            % Delete 3D polygons
            for d3DPolygonIndex=1:length(obj.c1h3DPolygonHandles)
                delete(obj.c1h3DPolygonHandles{d3DPolygonIndex});
            end
            
            % Reset current polygon handle
            obj.c1hPolygonHandles = {};
            obj.vdPolygonHandlesRegionOfInterestNumber = [];
            obj.vdPolygonHandlesPolygonNumber = [];
            
            obj.c1h3DPolygonHandles = {};
            obj.vd3DPolygonHandlesRegionOfInterestNumber = [];
            obj.vd3DPolygonHandlesPolygonNumber = [];
        end
        
        function DeleteAllByRenderGroupId(obj, dRenderGroupId)
            DeleteAllByRenderGroupId@LabelMapRegionsOfInterestRenderer(obj, dRenderGroupId);
            
            obj.DeletePolygonsByRenderGroupId(dRenderGroupId);
            obj.Delete3DPolygonsByRenderGroupId(dRenderGroupId);
        end
        
        function DeletePolygonsByRenderGroupId(obj, dRenderGroupId)
            vbDelete = obj.vdPolygonHandlerRenderGroupId == dRenderGroupId;
            
            for dPolygonIndex=1:length(vbDelete)
                if vbDelete(dPolygonIndex)
                    delete(obj.c1hPolygonHandles{dPolygonIndex});                    
                end
            end
            
            obj.c1hPolygonHandles = obj.c1hPolygonHandles(~vbDelete);
            obj.vdPolygonHandlesRegionOfInterestNumber = obj.vdPolygonHandlesRegionOfInterestNumber(~vbDelete);
            obj.vdPolygonHandlesPolygonNumber = obj.vdPolygonHandlesPolygonNumber(~vbDelete);
            obj.vdPolygonHandlerRenderGroupId = obj.vdPolygonHandlerRenderGroupId(~vbDelete);
        end
        
        function Delete3DPolygonsByRenderGroupId(obj, dRenderGroupId)
            vbDelete = obj.vd3DPolygonHandlesRenderGroupId == dRenderGroupId;
            
            for d3DPolygonIndex=1:length(vbDelete)
                if vbDelete(d3DPolygonIndex)
                    delete(obj.c1h3DPolygonHandles{d3DPolygonIndex});                    
                end
            end
            
            obj.c1h3DPolygonHandles = obj.c1hPolygonHandles(~vbDelete);
            obj.vd3DPolygonHandlesRegionOfInterestNumber = obj.vdPolygonHandlesRegionOfInterestNumber(~vbDelete);
            obj.vd3DPolygonHandlesPolygonNumber = obj.vdPolygonHandlesPolygonNumber(~vbDelete);
            obj.vd3DPolygonHandlesRenderGroupId = obj.vdPolygonHandlerRenderGroupId(~vbDelete);
        end
        
        function RenderOnPlane(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}                
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            % super-class call
            RenderOnPlane@LabelMapRegionsOfInterestRenderer(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId);
            
            % render polygons in slice by ROI
            obj.RenderPolygons(oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId);            
        end
        
        function RenderIn3D(obj, oImaging3DRenderAxes, vdAnatomicalPlaneIndices, dRenderGroupId, NameValueArgs)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                vdAnatomicalPlaneIndices (1,:) double {mustBeInteger(vdAnatomicalPlaneIndices), mustBeFinite(vdAnatomicalPlaneIndices)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)                
                NameValueArgs.GeometricalImagingObjectRendererComplete (1,1) logical = false
            end
            
            % Super-class call
            RenderIn3D@LabelMapRegionsOfInterestRenderer(...
                obj,...
                oImaging3DRenderAxes,...
                vdAnatomicalPlaneIndices, dRenderGroupId,...
                'GeometricalImagingObjectRendererComplete', NameValueArgs.GeometricalImagingObjectRendererComplete);
            
            % Render 3D polygons
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            dCurrentNumRenderedMeshes = length(obj.c1h3DMeshHandles);
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                dNumPolygons = obj.oRegionsOfInterest.GetNumberOfPolygonsByRegionOfInterestNumber(dRoiIndex);
                c1m2dPolygonCoords_mm = obj.oRegionsOfInterest.GetAllPolygonVertexPositionCoordinatesByRegionOfInterestNumber(dRoiIndex);
                
                dCurrentNumRendered3DPolygons = length(obj.c1h3DPolygonHandles);
                
                obj.c1h3DPolygonHandles = [obj.c1h3DPolygonHandles; cell(dNumPolygons,1)];
                obj.vd3DPolygonHandlesRegionOfInterestNumber = [obj.vd3DPolygonHandlesRegionOfInterestNumber; repmat(dRoiIndex, dNumPolygons, 1)];
                obj.vd3DPolygonHandlesPolygonNumber = [obj.vd3DPolygonHandlesPolygonNumber; (1:dNumPolygons)'];
                obj.vd3DPolygonHandlesRenderGroupId = [obj.vd3DPolygonHandlesRenderGroupId; repmat(dRenderGroupId, dNumPolygons, 1)];
                
                for dPolygonIndex=1:dNumPolygons
                    m2dCoords_mm = c1m2dPolygonCoords_mm{dPolygonIndex};
                    
                    obj.c1h3DPolygonHandles{dCurrentNumRendered3DPolygons + dPolygonIndex} = ...
                        patch(oImaging3DRenderAxes.GetAxes(),...
                        'XData', [m2dCoords_mm(:,1);m2dCoords_mm(1,1)],...
                        'YData', [m2dCoords_mm(:,2);m2dCoords_mm(1,2)],...
                        'ZData', [m2dCoords_mm(:,3);m2dCoords_mm(1,3)]);
                    obj.UpdateRendered3DPolygon(dCurrentNumRendered3DPolygons + dPolygonIndex);
                end
            end
        end
        
        function RenderPolygons(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}                
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            dNumRois = obj.oRASRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            vdVolumeDimensionSelect = eImagingPlaneType.GetRASVolumeDimensionSelect();
            
            dRowVolumeDimension = vdVolumeDimensionSelect(1);
            dColVolumeDimension = vdVolumeDimensionSelect(2);
            
            vdVoxelDimensions_mm = eImagingPlaneType.GetVoxelDimensions_mm(obj.oRASRegionsOfInterest);
            
            dRowVoxelDimension_mm = vdVoxelDimensions_mm(1);
            dColVoxelDimension_mm = vdVoxelDimensions_mm(2);
            
            for dRoiIndex=1:dNumRois
                [c1m2dVertexVoxelIndices, ~, vdPolygonNumbers] = obj.oRASRegionsOfInterest.GetAllPolygonVertexVoxelIndicesInSliceByRegionOfInterestNumber(dRoiIndex, vdAnatomicalPlaneIndices, eImagingPlaneType);
        
                dNumPolygons = length(c1m2dVertexVoxelIndices);
                
                for dPolygonIndex=1:dNumPolygons
                    vdRowVoxelIndicesCoords = c1m2dVertexVoxelIndices{dPolygonIndex}(:,dRowVolumeDimension);
                    vdColVoxelIndicesCoords = c1m2dVertexVoxelIndices{dPolygonIndex}(:,dColVolumeDimension);
                    
                    [vdScaledRowCoords_mm, vdScaledColumnCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(...
                        vdRowVoxelIndicesCoords, vdColVoxelIndicesCoords,...
                        dRowVoxelDimension_mm, dColVoxelDimension_mm);
                                        
                    hPlotHandle = patch(...
                        oImagingPlaneAxes.GetAxes(),...
                        'XData', vdScaledColumnCoords_mm,...
                        'YData', vdScaledRowCoords_mm);
                    
                    obj.c1hPolygonHandles = [obj.c1hPolygonHandles, {hPlotHandle}];
                    obj.vdPolygonHandlesRegionOfInterestNumber = [obj.vdPolygonHandlesRegionOfInterestNumber; dRoiIndex];
                    obj.vdPolygonHandlesPolygonNumber = [obj.vdPolygonHandlesPolygonNumber; vdPolygonNumbers(dPolygonIndex)];
                    obj.vdPolygonHandlerRenderGroupId = [obj.vdPolygonHandlerRenderGroupId; dRenderGroupId];
                    
                    obj.UpdateRenderedPolygon(length(obj.c1hPolygonHandles));
                end
            end
        end
        
        function UpdateRenderedOnPlaneMaskObjectsByRenderGroupId(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}                
            end
                
            % super-class call
            UpdateRenderedOnPlaneMaskObjectsByRenderGroupId@LabelMapRegionsOfInterestRenderer(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId);
            
            % delete old polygons
            obj.DeletePolygonsByRenderGroupId(dRenderGroupId);
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            % render new polygons
            obj.RenderPolygons(oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId);            
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>> SETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function SetRegionOfInterestColour(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            % Super-class call
            SetRegionOfInterestColour@LabelMapRegionsOfInterestRenderer(obj, dRegionOfInterestNumber, vdNewColour_rgb);
            
            % Set ROI colour for polygon
            obj.SetRegionOfInterestPolygonFaceColours(dRegionOfInterestNumber, vdNewColour_rgb);
            obj.SetRegionOfInterestPolygonEdgeColours(dRegionOfInterestNumber, vdNewColour_rgb);
            obj.SetRegionOfInterestPolygonMarkerFaceColors(dRegionOfInterestNumber, vdNewColour_rgb);
            obj.SetRegionOfInterestPolygonMarkerEdgeColors(dRegionOfInterestNumber, GeometricalImagingObjectRenderer.ApplyColourShift(vdNewColour_rgb, LabelMapRegionsOfInterestFromPolygonsRenderer.dDefaultPolygonMarkerColourShift_rgb));
            
            % Set ROI colour for 3D polygon
            obj.SetRegionOfInterest3DPolygonEdgeColours(dRegionOfInterestNumber, vdNewColour_rgb);
            obj.SetRegionOfInterest3DPolygonMarkerFaceColors(dRegionOfInterestNumber, vdNewColour_rgb);
            obj.SetRegionOfInterest3DPolygonMarkerEdgeColors(dRegionOfInterestNumber, GeometricalImagingObjectRenderer.ApplyColourShift(vdNewColour_rgb, LabelMapRegionsOfInterestFromPolygonsRenderer.dDefault3DPolygonMarkerColourShift_rgb));
        end
        
        function SetRegionOfInterestVisibility(obj, dRegionOfInterestNumber, bVisible)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            % Super-class call
            SetRegionOfInterestVisibility@LabelMapRegionsOfInterestRenderer(obj, dRegionOfInterestNumber, bVisible);
            
            % Set visibility for polygon
            obj.SetRegionOfInterestPolygonVisibilities(dRegionOfInterestNumber, bVisible);         
            
            % Set visibility for 3D polygon
            obj.SetRegionOfInterest3DPolygonVisibilities(dRegionOfInterestNumber, bVisible);         
        end
        
        function SetAllPolygonVisibilities(obj, bVisible)
            arguments
                obj                
                bVisible (1,1) logical
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.SetRegionOfInterestPolygonVisibilities(dRoiIndex, bVisible);
            end
        end
        
        function SetAll3DPolygonVisibilities(obj, bVisible)
            arguments
                obj                
                bVisible (1,1) logical
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.SetRegionOfInterest3DPolygonVisibilities(dRoiIndex, bVisible);
            end
        end
        
        function SetRegionOfInterestPolygonVisibilities(obj, dRegionOfInterestNumber, bVisible)            
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            obj.c1vbDisplayPolygon{dRegionOfInterestNumber}(:) = bVisible;
        end
        
        function SetRegionOfInterestPerPolygonVisibility(obj, dRegionOfInterestNumber, vbVisible)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vbVisible (:,1) logical
            end
            
            obj.c1vbDisplayPolygon{dRegionOfInterestNumber}(:) = vbVisible;
        end
        
        function SetRegionOfInterestPer3DPolygonVisibility(obj, dRegionOfInterestNumber, vbVisible)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vbVisible (:,1) logical
            end
            
            obj.c1vbDisplay3DPolygon{dRegionOfInterestNumber}(:) = vbVisible;
        end
        
        function SetRegionOfInterest3DPolygonVisibilities(obj, dRegionOfInterestNumber, bVisible)           
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            obj.c1vbDisplay3DPolygon{dRegionOfInterestNumber}(:) = bVisible;
        end
        
        function SetRegionOfInterestPolygonFaceColours(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.c1m2dPolygonFaceColour_rgb{dRegionOfInterestNumber}(:,1) = vdNewColour_rgb(1);
            obj.c1m2dPolygonFaceColour_rgb{dRegionOfInterestNumber}(:,2) = vdNewColour_rgb(2);
            obj.c1m2dPolygonFaceColour_rgb{dRegionOfInterestNumber}(:,3) = vdNewColour_rgb(3);
        end
        
        function SetRegionOfInterestPolygonEdgeColours(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.c1m2dPolygonEdgeColour_rgb{dRegionOfInterestNumber}(:,1) = vdNewColour_rgb(1);
            obj.c1m2dPolygonEdgeColour_rgb{dRegionOfInterestNumber}(:,2) = vdNewColour_rgb(2);
            obj.c1m2dPolygonEdgeColour_rgb{dRegionOfInterestNumber}(:,3) = vdNewColour_rgb(3);
        end
        
        function SetRegionOfInterest3DPolygonEdgeColours(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.c1m2d3DPolygonEdgeColour_rgb{dRegionOfInterestNumber}(:,1) = vdNewColour_rgb(1);
            obj.c1m2d3DPolygonEdgeColour_rgb{dRegionOfInterestNumber}(:,2) = vdNewColour_rgb(2);
            obj.c1m2d3DPolygonEdgeColour_rgb{dRegionOfInterestNumber}(:,3) = vdNewColour_rgb(3);
        end
        
        function SetAllPolygonLineWidths(obj, dNewLineWidth)
            arguments
                obj                
                dNewLineWidth (1,1) double {mustBePositive(dNewLineWidth), mustBeFinite(dNewLineWidth)}
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1vdPolygonLineWidth{dRoiIndex}(:) = dNewLineWidth;
            end
        end
        
        function SetAll3DPolygonLineWidths(obj, dNewLineWidth)
            arguments
                obj                
                dNewLineWidth (1,1) double {mustBePositive(dNewLineWidth), mustBeFinite(dNewLineWidth)}
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1vd3DPolygonLineWidth{dRoiIndex}(:) = dNewLineWidth;
            end
        end
        
        function SetAllPolygonOverlayAlphas(obj, dAlpha)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer         
                dAlpha (1,1) double {ValidationUtils.MustBeValidAlphaValue(dAlpha)}
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1vdPolygonFaceAlpha{dRoiIndex}(:) = dAlpha;
            end
        end
        
        function SetAll3DPolygonFaceAlphas(obj, dAlpha)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer         
                dAlpha (1,1) double {ValidationUtils.MustBeValidAlphaValue(dAlpha)}
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1vd3DPolygonFaceAlpha{dRoiIndex}(:) = dAlpha;
            end
        end
        
        function SetAllPolygonLineStyles(obj, chLineStyle)
            arguments
                obj                
                chLineStyle (1,:) char
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1c1chPolygonLineStyle{dRoiIndex}(:) = {chLineStyle};
            end
        end
        
        function SetAll3DPolygonLineStyles(obj, chLineStyle)
            arguments
                obj                
                chLineStyle (1,:) char
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1c1ch3DPolygonLineStyle{dRoiIndex}(:) = {chLineStyle};
            end
        end
        
        function SetRegionOfInterestPolygonMarkerFaceColors(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.c1m2dPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(:,1) = vdNewColour_rgb(1);
            obj.c1m2dPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(:,2) = vdNewColour_rgb(2);
            obj.c1m2dPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(:,3) = vdNewColour_rgb(3);
        end
        
        function SetRegionOfInterest3DPolygonMarkerFaceColors(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.c1m2d3DPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(:,1) = vdNewColour_rgb(1);
            obj.c1m2d3DPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(:,2) = vdNewColour_rgb(2);
            obj.c1m2d3DPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(:,3) = vdNewColour_rgb(3);
        end
        
        function SetRegionOfInterestPolygonMarkerEdgeColors(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.c1m2dPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(:,1) = vdNewColour_rgb(1);
            obj.c1m2dPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(:,2) = vdNewColour_rgb(2);
            obj.c1m2dPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(:,3) = vdNewColour_rgb(3);
        end
        
        function SetRegionOfInterest3DPolygonMarkerEdgeColors(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj                
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.c1m2d3DPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(:,1) = vdNewColour_rgb(1);
            obj.c1m2d3DPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(:,2) = vdNewColour_rgb(2);
            obj.c1m2d3DPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(:,3) = vdNewColour_rgb(3);
        end
        
        function SetAllPolygonMarkerSymbols(obj, chMarkerSymbol)
            arguments
                obj                
                chMarkerSymbol (1,:) char
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1c1chPolygonMarkerSymbol{dRoiIndex}(:) = {chMarkerSymbol};
            end
        end
        
        function SetAll3DPolygonMarkerSymbols(obj, chMarkerSymbol)
            arguments
                obj                
                chMarkerSymbol (1,:) char
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1c1ch3DPolygonMarkerSymbol{dRoiIndex}(:) = {chMarkerSymbol};
            end
        end
        
        function SetAllPolygonMarkerSizes(obj, dNewSize)
            arguments
                obj                
                dNewSize (1,1) double {mustBePositive(dNewSize), mustBeFinite(dNewSize)}
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1vdPolygonMarkerSize{dRoiIndex}(:) = dNewSize;
            end
        end
        
        function SetAll3DPolygonMarkerSizes(obj, dNewSize)
            arguments
                obj                
                dNewSize (1,1) double {mustBePositive(dNewSize), mustBeFinite(dNewSize)}
            end
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois
                obj.c1vd3DPolygonMarkerSize{dRoiIndex}(:) = dNewSize;
            end
        end
        
        function SetPolygonColour(obj, dRegionOfInterestNumber, dPolygonNumber, vdColour_rgb)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dPolygonNumber (1,1) double {MustBeValidPolygonNumber(obj, dRegionOfInterestNumber, dPolygonNumber)}
                vdColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdColour_rgb)}
            end
            
            obj.c1m2dPolygonFaceColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = vdColour_rgb;
            obj.c1m2dPolygonEdgeColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = vdColour_rgb;
            obj.c1m2dPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = vdColour_rgb;
            obj.c1m2dPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = GeometricalImagingObjectRenderer.ApplyColourShift(vdColour_rgb, LabelMapRegionsOfInterestFromPolygonsRenderer.dDefaultPolygonMarkerColourShift_rgb);            
        end
        
        function Set3DPolygonColour(obj, dRegionOfInterestNumber, dPolygonNumber, vdColour_rgb)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dPolygonNumber (1,1) double {MustBeValidPolygonNumber(obj, dRegionOfInterestNumber, dPolygonNumber)}
                vdColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdColour_rgb)}
            end
            
            obj.c1m2d3DPolygonFaceColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = vdColour_rgb;
            obj.c1m2d3DPolygonEdgeColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = vdColour_rgb;
            obj.c1m2d3DPolygonMarkerEdgeColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = vdColour_rgb;
            obj.c1m2d3DPolygonMarkerFaceColour_rgb{dRegionOfInterestNumber}(dPolygonNumber,:) = GeometricalImagingObjectRenderer.ApplyColourShift(vdColour_rgb, LabelMapRegionsOfInterestFromPolygonsRenderer.dDefaultPolygonMarkerColourShift_rgb);            
        end
                
        function SetPolygonLineStyle(obj, dRegionOfInterestNumber, dPolygonNumber, chLineStyle)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dPolygonNumber (1,1) double {MustBeValidPolygonNumber(obj, dRegionOfInterestNumber, dPolygonNumber)}
                chLineStyle (1,:) char 
            end
            
            obj.c1c1chPolygonLineStyle{dRegionOfInterestNumber}{dPolygonNumber} = chLineStyle;
        end
                
        function Set3DPolygonLineStyle(obj, dRegionOfInterestNumber, dPolygonNumber, chLineStyle)
            arguments
                obj (1,1) LabelMapRegionsOfInterestFromPolygonsRenderer
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dPolygonNumber (1,1) double {MustBeValidPolygonNumber(obj, dRegionOfInterestNumber, dPolygonNumber)}
                chLineStyle (1,:) char 
            end
            
            obj.c1c1ch3DPolygonLineStyle{dRegionOfInterestNumber}{dPolygonNumber} = chLineStyle;
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = protected) % None
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
       
    methods (Access = private)
                
        function MustBeValidPolygonNumber(obj, dRegionOfInterestNumber, dPolygonNumber)
            arguments
                obj
                dRegionOfInterestNumber
                dPolygonNumber (1,1) double {mustBeInteger, mustBePositive}
            end
            
            mustBeLessThanOrEqual(dPolygonNumber, length(obj.c1vbDisplayPolygon{dRegionOfInterestNumber}));
        end
        
        function UpdateRenderedPolygon(obj, dRenderedPolygonIndex)
            hPolygon = obj.c1hPolygonHandles{dRenderedPolygonIndex};
            dRoiNumber = obj.vdPolygonHandlesRegionOfInterestNumber(dRenderedPolygonIndex);
            dPolygonNumber = obj.vdPolygonHandlesPolygonNumber(dRenderedPolygonIndex);
            
            if obj.c1vbDisplayPolygon{dRoiNumber}(dPolygonNumber)
                chVisible = 'on';
            else
                chVisible = 'off';
            end
            
            hPolygon.Visible = chVisible;
            hPolygon.FaceColor = obj.c1m2dPolygonFaceColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.FaceAlpha = obj.c1vdPolygonFaceAlpha{dRoiNumber}(dPolygonNumber,:);
            hPolygon.EdgeColor = obj.c1m2dPolygonEdgeColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.LineWidth = obj.c1vdPolygonLineWidth{dRoiNumber}(dPolygonNumber);
            hPolygon.LineStyle = obj.c1c1chPolygonLineStyle{dRoiNumber}{dPolygonNumber};
            hPolygon.MarkerFaceColor = obj.c1m2dPolygonMarkerFaceColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.MarkerEdgeColor = obj.c1m2dPolygonMarkerEdgeColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.Marker = obj.c1c1chPolygonMarkerSymbol{dRoiNumber}{dPolygonNumber};
            hPolygon.MarkerSize = obj.c1vdPolygonMarkerSize{dRoiNumber}(dPolygonNumber);
        end
        
        function UpdateRendered3DPolygon(obj, dRenderedPolygonIndex)
            hPolygon = obj.c1h3DPolygonHandles{dRenderedPolygonIndex};
            dRoiNumber = obj.vd3DPolygonHandlesRegionOfInterestNumber(dRenderedPolygonIndex);
            dPolygonNumber = obj.vd3DPolygonHandlesPolygonNumber(dRenderedPolygonIndex);
            
            if obj.c1vbDisplay3DPolygon{dRoiNumber}(dPolygonNumber)
                chVisible = 'on';
            else
                chVisible = 'off';
            end
            
            hPolygon.Visible = chVisible;
            hPolygon.FaceColor = obj.c1m2d3DPolygonFaceColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.FaceAlpha = obj.c1vd3DPolygonFaceAlpha{dRoiNumber}(dPolygonNumber,:);
            hPolygon.EdgeColor = obj.c1m2d3DPolygonEdgeColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.LineWidth = obj.c1vd3DPolygonLineWidth{dRoiNumber}(dPolygonNumber);
            hPolygon.LineStyle = obj.c1c1ch3DPolygonLineStyle{dRoiNumber}{dPolygonNumber};
            hPolygon.MarkerFaceColor = obj.c1m2d3DPolygonMarkerFaceColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.MarkerEdgeColor = obj.c1m2d3DPolygonMarkerEdgeColour_rgb{dRoiNumber}(dPolygonNumber,:);
            hPolygon.Marker = obj.c1c1ch3DPolygonMarkerSymbol{dRoiNumber}{dPolygonNumber};
            hPolygon.MarkerSize = obj.c1vd3DPolygonMarkerSize{dRoiNumber}(dPolygonNumber);
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


