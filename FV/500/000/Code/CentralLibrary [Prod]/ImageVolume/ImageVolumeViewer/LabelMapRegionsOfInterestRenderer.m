classdef LabelMapRegionsOfInterestRenderer < RegionsOfInterestRenderer
    %LabelMapRegionsOfInterestRenderer
    
    % Primary Author: David DeVries
    % Created: Sept 9, 2019
    
    
    % *********************************************************************   ORDERING: 1 Abstract        X.1 Public       X.X.1 Not Constant
    % *                            PROPERTIES                             *             2 Not Abstract -> X.2 Protected -> X.X.2 Constant
    % *********************************************************************                               X.3 Private
         
    properties (SetAccess = private, GetAccess = public)
        vbDisplayVoxelMask % row index is per ROI
        m2dVoxelMaskColour_rgb
        vdVoxelMaskAlpha
        
        vbDisplayVoxelMaskOutline
        m2dVoxelMaskOutlineColour_rgb
        vdVoxelMaskOutlineLineWidth
        c1chVoxelMaskOutlineLineStyle
        
        vbDisplay3DMesh        
        m2d3DMeshFaceColour_rgb
        vd3DMeshAlpha
        vbDisplay3DMeshEdges
        m2d3DMeshEdgeColour_rgb
        ch3DMeshLightingStyle
        
        c1hVoxelMaskImageHandles = {}
        vdVoxelMaskImageHandlesRegionOfInterestNumber = []
        vdVoxelMaskImageHandlesRenderGroupId = []
                
        c1c1hVoxelMaskOutlineHandles = {}
        vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber = []
        vdVoxelMaskImageOutlineHandlesRenderGroupId = []
        
        c1h3DMeshHandles = {}
        vd3DMeshHandlesRegionOfInterestNumber = []
        vd3DMeshHandlesRenderGroupId = []
    end
    
    properties (Constant = true, GetAccess = protected)
        dDefaultVoxelMaskAlpha = 0.5
        
        dDefaultVoxelMaskOutlineLineWidth = 1
        chDefaultVoxelMaskOutlineLineStyle = '-'
        
        dDefault3DMeshFaceAlpha = 0.8
        dDefault3DMeshEdgeColourShift_rgb = -0.2
        chDefault3DMeshLightingStyle = 'gouraud'
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                          PUBLIC METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
          
    methods (Access = public)
        
        function obj = LabelMapRegionsOfInterestRenderer(oLabelMapRegionsOfInterest, oRASLabelMapRegionsOfInterest)
            %obj = LabelMapRegionsOfInterestRenderer(oRegionsOfInterest)
            %
            % SYNTAX:
            %  obj = LabelMapRegionsOfInterestRenderer(oRegionsOfInterest)
            %
            % DESCRIPTION:
            %  TODO
            %
            % INPUT ARGUMENTS:
            %  TODO
            %
            % OUTPUTS ARGUMENTS:
            %  obj: Constructed object
            arguments
                oLabelMapRegionsOfInterest (1,1) LabelMapRegionsOfInterest
                oRASLabelMapRegionsOfInterest (1,1) LabelMapRegionsOfInterest
            end
            
            
            % Super-class constructor
            obj@RegionsOfInterestRenderer(oLabelMapRegionsOfInterest, oRASLabelMapRegionsOfInterest)
            
            % Set properities
            dNumRois = oLabelMapRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            obj.vbDisplayVoxelMask = true(dNumRois,1);
            obj.m2dVoxelMaskColour_rgb = zeros(dNumRois,3);
            obj.vdVoxelMaskAlpha = repmat(obj.dDefaultVoxelMaskAlpha, dNumRois, 1);
            
            obj.vbDisplayVoxelMaskOutline = true(dNumRois,1);
            obj.m2dVoxelMaskOutlineColour_rgb = zeros(dNumRois,3);
            obj.vdVoxelMaskOutlineLineWidth = repmat(obj.dDefaultVoxelMaskOutlineLineWidth, dNumRois, 1);
            obj.c1chVoxelMaskOutlineLineStyle = repmat({obj.chDefaultVoxelMaskOutlineLineStyle}, dNumRois, 1);
            
            obj.vbDisplay3DMesh = true(dNumRois,1);
            obj.m2d3DMeshFaceColour_rgb = zeros(dNumRois,3);
            obj.vd3DMeshAlpha = repmat(obj.dDefault3DMeshFaceAlpha, dNumRois, 1);
            obj.vbDisplay3DMeshEdges = true(dNumRois,1);
            obj.m2d3DMeshEdgeColour_rgb = zeros(dNumRois,3);
            obj.ch3DMeshLightingStyle = obj.chDefault3DMeshLightingStyle;
            
            % set colours for each ROI            
            for dRoiIndex=1:dNumRois
                vdDefaultRoiColour_rgb = oLabelMapRegionsOfInterest.GetDefaultRenderColourByRegionOfInterestNumber_rgb(dRoiIndex);
                
                obj.m2dVoxelMaskColour_rgb(dRoiIndex,:) = vdDefaultRoiColour_rgb;
                obj.m2dVoxelMaskOutlineColour_rgb(dRoiIndex,:) = vdDefaultRoiColour_rgb;
                
                obj.m2d3DMeshFaceColour_rgb(dRoiIndex,:) = vdDefaultRoiColour_rgb;
                obj.m2d3DMeshEdgeColour_rgb(dRoiIndex,:) = RegionsOfInterestRenderer.ApplyColourShift(vdDefaultRoiColour_rgb, obj.dDefault3DMeshEdgeColourShift_rgb);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>> UPDATE FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function UpdateAll(obj)
            arguments
                obj
            end
            
            obj.UpdateAll3D();
            obj.UpdateAll2D();
            
            %Super-class call
            UpdateAll@RegionsOfInterestRenderer(obj);
        end
        
        function UpdateAll3D(obj)
            arguments
                obj
            end
            
            %Super-class call
            UpdateAll3D@RegionsOfInterestRenderer(obj);
            
            % local calls
            obj.UpdateAll3DMeshes();
        end
        
        function UpdateAllOnPlane(obj)
            arguments
                obj
            end
            
            %Super-class call
            UpdateAllOnPlane@RegionsOfInterestRenderer(obj);
            
            % local calls
            obj.UpdateAllVoxelMasks();
            obj.UpdateAllVoxelMaskOutlines();
        end
        
        function UpdateRenderedOnPlaneMaskObjectsByRenderGroupId(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}                
            end
                
            % delete old outlines
            obj.DeleteVoxelMaskOutlinesByRenderGroupId(dRenderGroupId);
            
            dNumRois = obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest();
            
            for dRoiIndex=1:dNumRois            
                % get mask data
                [m2bVoxelMaskData, dRowVoxelSpacing_mm, dColVoxelSpacing_mm] = eImagingPlaneType.GetMaskSliceFromAnatomicalPlaneIndicesByRegionOfInterestNumber(obj.oRASRegionsOfInterest, dRoiIndex, vdAnatomicalPlaneIndices);
                
                % swap out mask data
                for dSliceIndex=1:length(obj.c1hVoxelMaskImageHandles)
                    if ...
                            dRenderGroupId == obj.vdVoxelMaskImageHandlesRenderGroupId(dSliceIndex) &&...
                            dRoiIndex == obj.vdVoxelMaskImageHandlesRegionOfInterestNumber(dSliceIndex)
                        
                        obj.c1hVoxelMaskImageHandles{dSliceIndex}.AlphaData = obj.vdVoxelMaskAlpha(dRoiIndex) .* double(m2bVoxelMaskData);
                    end
                end
                
                % draw outlines
                obj.RenderPlaneMaskOutlineForMaskByRegionOfInterestNumber(...
                    m2bVoxelMaskData,...
                    dRowVoxelSpacing_mm, dColVoxelSpacing_mm,...
                    oImagingPlaneAxes,...
                    dRoiIndex, dRenderGroupId);
            end
        end
        
        function UpdateAllVoxelMasks(obj)
            dNumVoxelMasksRendered = length(obj.c1hVoxelMaskImageHandles);
            
            for dMaskIndex=1:dNumVoxelMasksRendered
                obj.UpdateRenderedVoxelMask(dMaskIndex);
            end
        end
        
        function UpdateAllVoxelMaskOutlines(obj)
            dNumVoxelMaskOutlinesRendered = length(obj.c1c1hVoxelMaskOutlineHandles);
            
            for dOutlineIndex=1:dNumVoxelMaskOutlinesRendered
                obj.UpdateRenderedVoxelMaskOutlines(dOutlineIndex);
            end
        end
        
        function UpdateAll3DMeshes(obj)
            dNum3DMeshesRendered = length(obj.c1h3DMeshHandles);
            
            for dMeshIndex=1:dNum3DMeshesRendered
                obj.UpdateRendered3DMesh(dMeshIndex);
            end
        end
        
        function UpdateVoxelMaskOutlineByRegionOfInterestNumberAndRenderGroupId(obj, dRegionOfInterestNumber, dRenderGroupId)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)}
            end
            
            for dMaskOutlineIndex=1:length(obj.c1c1hVoxelMaskOutlineHandles)
                if ...
                    ( dRegionOfInterestNumber == obj.vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber(dMaskOutlineIndex) ) && ...
                    ( dRenderGroupId == obj.vdVoxelMaskImageOutlineHandlesRenderGroupId(dMaskOutlineIndex) )
                    obj.UpdateRenderedVoxelMaskOutlines(dMaskOutlineIndex);
                end
            end
        end
        
        % >>>>>>>>>>>>>>>>>>>>>>>>>>> DELETE FUNCTIONS <<<<<<<<<<<<<<<<<<<<
        function DeleteAll(obj)
            % Super-class call:
            DeleteAll@Renderer(obj);
            
            % Delete voxel masks
            for dMaskIndex=1:length(obj.c1hVoxelMaskImageHandles)
                delete(obj.c1hVoxelMaskImageHandles);
            end
            
            % Delete voxel mask outlines
            for dOutlinesIndex=1:length(obj.c1c1hVoxelMaskOutlineHandles)
                dNumOutlines = length(obj.c1c1hVoxelMaskOutlineHandles{dOutlinesIndex});
                
                for dOutlineIndex=1:dNumOutlines
                    delete(obj.c1c1hVoxelMaskOutlineHandles{dOutlinesIndex}{dOutlineIndex});
                end
            end
            
            % Delete meshes
            for dMeshIndex=1:length(obj.c1hVoxelMaskImageHandles)
                delete(obj.c1hVoxelMaskImageHandles{dMeshIndex});
            end
            
            % reset handles
            obj.c1hVoxelMaskImageHandles = {};
            obj.vdVoxelMaskImageHandlesRegionOfInterestNumber = [];
            
            obj.c1c1hVoxelMaskOutlineHandles = {};
            obj.vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber = [];
            
            obj.c1h3DMeshHandles = {};
            obj.vd3DMeshHandlesRegionOfInterestNumber = [];
        end
        
        function DeleteAllByRenderGroupId(obj, dRenderGroupId)
            obj.DeleteVoxelMasksByRenderGroupId(dRenderGroupId);
            obj.DeleteVoxelMaskOutlinesByRenderGroupId(dRenderGroupId);
            obj.Delete3DMeshesByRenderGroupId(dRenderGroupId);
        end
        
        function DeleteVoxelMasksByRenderGroupId(obj, dRenderGroupId)
            vbDelete = obj.vdVoxelMaskImageHandlesRenderGroupId == dRenderGroupId;
            
            for dMaskIndex=1:length(vbDelete)
                if vbDelete(dMaskIndex)
                    delete(obj.c1hVoxelMaskImageHandles{dMaskIndex});
                end
            end
            
            obj.c1hVoxelMaskImageHandles = obj.c1hVoxelMaskImageHandles(~vbDelete);
            obj.vdVoxelMaskImageHandlesRegionOfInterestNumber = obj.vdVoxelMaskImageHandlesRegionOfInterestNumber(~vbDelete);
            obj.vdVoxelMaskImageHandlesRenderGroupId = obj.vdVoxelMaskImageHandlesRenderGroupId(~vbDelete);
        end
        
        function DeleteVoxelMaskOutlinesByRenderGroupId(obj, dRenderGroupId)
            vbDelete = obj.vdVoxelMaskImageOutlineHandlesRenderGroupId == dRenderGroupId;
            
            for dOutlinesIndex=1:length(vbDelete)
                if vbDelete(dOutlinesIndex)
                    c1hOutlines = obj.c1c1hVoxelMaskOutlineHandles{dOutlinesIndex};
                    
                    for dOutlineIndex=1:length(c1hOutlines)
                        delete(c1hOutlines{dOutlineIndex});
                    end
                end
            end
            
            obj.c1c1hVoxelMaskOutlineHandles = obj.c1c1hVoxelMaskOutlineHandles(~vbDelete);
            obj.vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber = obj.vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber(~vbDelete);
            obj.vdVoxelMaskImageOutlineHandlesRenderGroupId = obj.vdVoxelMaskImageOutlineHandlesRenderGroupId(~vbDelete);
        end
        
        function Delete3DMeshsByRenderGroupId(obj, dRenderGroupId)
            vbDelete = obj.vd3DMeshHandlesRenderGroupId == dRenderGroupId;
            
            for dMeshIndex=1:length(vbDelete)
                if vbDelete(dMeshIndex)
                    delete(obj.c1h3DMeshHandles{dMeshIndex});
                end
            end
            
            obj.c1h3DMeshHandles = obj.c1h3DMeshHandles(~vbDelete);
            obj.vd3DMeshHandlesRegionOfInterestNumber = obj.vdVoxelMaskImageHandlesRegionOfInterestNumber(~vbDelete);
            obj.vd3DMeshHandlesRenderGroupId = obj.vd3DMeshHandlesRenderGroupId(~vbDelete);
        end
        
        function RenderOnPlane(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}                
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            dNumRois = obj.oRASRegionsOfInterest.GetNumberOfRegionsOfInterest();
                        
            for dRegionOfInterestNumber=1:dNumRois
                % get mask                
                [m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm] = eImagingPlaneType.GetMaskSliceFromAnatomicalPlaneIndicesByRegionOfInterestNumber(obj.oRASRegionsOfInterest, dRegionOfInterestNumber, vdAnatomicalPlaneIndices);
                
                % render mask
                obj.RenderPlaneMaskForMaskByRegionOfInterestNumber(...
                    m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm,...
                    oImagingPlaneAxes,...
                    dRegionOfInterestNumber, dRenderGroupId);
                
                % render outline
                obj.RenderPlaneMaskOutlineForMaskByRegionOfInterestNumber(...
                    m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm,...
                    oImagingPlaneAxes,...
                    dRegionOfInterestNumber, dRenderGroupId);
            end
        end
        
        function RenderPlaneMaskOutlineByRegionOfInterestNumber(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRegionOfInterestNumber, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
                                              
            [m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm] = eImagingPlaneType.GetMaskSliceFromAnatomicalPlaneIndicesByRegionOfInterestNumber(obj.oRASRegionsOfInterest, dRegionOfInterestNumber, vdAnatomicalPlaneIndices);
            
            obj.RenderPlaneMaskOutlineForMaskByRegionOfInterestNumber(...
                m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm,...
                oImagingPlaneAxes,...
                dRegionOfInterestNumber, dRenderGroupId);
        end
        
        function RenderPlaneMaskByRegionOfInterestNumber(obj, oImagingPlaneAxes, eImagingPlaneType, vdAnatomicalPlaneIndices, dRegionOfInterestNumber, dRenderGroupId)
            arguments
                obj
                oImagingPlaneAxes (1,1) ImagingPlaneAxes
                eImagingPlaneType (1,1) ImagingPlaneTypes
                vdAnatomicalPlaneIndices (1,3) double {mustBePositive, mustBeInteger}
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
            end
            
            [m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm] = eImagingPlaneType.GetMaskSliceFromAnatomicalPlaneIndicesByRegionOfInterestNumber(obj.oRASRegionsOfInterest, dRegionOfInterestNumber, vdAnatomicalPlaneIndices);
            
            obj.RenderPlaneMaskForMaskByRegionOfInterestNumber(...
                obj,...
                m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm,...
                oImagingPlaneAxes,...
                dRegionOfInterestNumber, dRenderGroupId);
        end
        
        function RenderIn3D(obj, oImaging3DRenderAxes, vdAnatomicalPlaneIndices, dRenderGroupId, NameValueArgs)
            arguments
                obj
                oImaging3DRenderAxes (1,1) Imaging3DRenderAxes
                vdAnatomicalPlaneIndices (1,:) double {mustBeInteger(vdAnatomicalPlaneIndices), mustBeFinite(vdAnatomicalPlaneIndices)}
                dRenderGroupId (1,1) double {MustBeValidRenderGroupId(obj, dRenderGroupId)} = CreateRenderGroup(obj)
                NameValueArgs.GeometricalImagingObjectRendererComplete (1,1) logical = false
            end
            
            
            % Super-class call:
            RenderIn3D@RegionsOfInterestRenderer(...
                obj, oImaging3DRenderAxes,...
                vdAnatomicalPlaneIndices,...
                dRenderGroupId,...
                'GeometricalImagingObjectRendererComplete', NameValueArgs.GeometricalImagingObjectRendererComplete);
            
            % Render 3D Meshes
            dNumRois = obj.oRASRegionsOfInterest.GetNumberOfRegionsOfInterest();
            dCurrentNumRenderedMeshes = length(obj.c1h3DMeshHandles);
            
            obj.c1h3DMeshHandles = [obj.c1h3DMeshHandles, cell(dNumRois,1)];
            obj.vd3DMeshHandlesRegionOfInterestNumber = [obj.vd3DMeshHandlesRegionOfInterestNumber, (1:dNumRois)];
            obj.vd3DMeshHandlesRenderGroupId = [obj.vd3DMeshHandlesRenderGroupId, repmat(dRenderGroupId, dNumRois, 1)];
            
            hAxes = oImaging3DRenderAxes.GetAxes();
            
            for dRoiIndex=1:dNumRois
                 [m2dFaces, m2dVertices] = obj.oRASRegionsOfInterest.Get3DMeshByRegionOfInterestNumber(dRoiIndex);

                 obj.c1h3DMeshHandles{dCurrentNumRenderedMeshes + dRoiIndex} = ...
                     patch(hAxes,...
                     'Faces', m2dFaces,...
                     'Vertices', m2dVertices);
                 obj.UpdateRendered3DMesh(dCurrentNumRenderedMeshes + dRoiIndex);
            end
        end
        
        
        % >>>>>>>>>>>>>>>>>>>>>>> SETTERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % All elements by ROI:
        function SetRegionOfInterestColour(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
                        
            % Set ROI colour for voxel mask
            obj.SetRegionOfInterestVoxelMaskColour(dRegionOfInterestNumber, vdNewColour_rgb);
            
            % Set ROI colour for voxel mask outline
            obj.SetRegionOfInterestVoxelMaskOutlineColour(dRegionOfInterestNumber, vdNewColour_rgb);
            
            % Set ROI colour for 3D mesh
            obj.SetRegionOfInterest3DMeshFaceColour(dRegionOfInterestNumber, vdNewColour_rgb);
            obj.SetRegionOfInterest3DMeshEdgeColour(dRegionOfInterestNumber, RegionsOfInterestRenderer.ApplyColourShift(vdNewColour_rgb, obj.dDefault3DMeshEdgeColourShift_rgb));
        end
        
        function SetRegionOfInterestVisibility(obj, dRegionOfInterestNumber, bVisible)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
                
            % Set visibility for voxel mask
            obj.SetRegionOfInterestVoxelMaskVisibility(dRegionOfInterestNumber, bVisible);         
            
            % Set visibility for voxel mask outline
            obj.SetRegionOfInterestVoxelMaskOutlineVisibility(dRegionOfInterestNumber, bVisible);         
            
            % Set visibility for 3D mesh
            obj.SetRegionOfInterest3DMeshVisibility(dRegionOfInterestNumber, bVisible);
        end
        
        % Single properities by ROI:
        function SetRegionOfInterestVoxelMaskColour(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.m2dVoxelMaskColour_rgb(dRegionOfInterestNumber,:) = vdNewColour_rgb;
        end
        
        function SetRegionOfInterestVoxelMaskOutlineColour(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.m2dVoxelMaskOutlineColour_rgb(dRegionOfInterestNumber,:) = vdNewColour_rgb;
        end
        
        function SetRegionOfInterest3DMeshFaceColour(obj, dRegionOfInterestNumber, vdNewColour_rgb)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.m2d3DMeshFaceColour_rgb(dRegionOfInterestNumber,:) = vdNewColour_rgb;
        end
        
        function SetRegionOfInterest3DMeshEdgeColour(obj, dRegionOfInterestNumber, vdNewColour_rgb)            
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                vdNewColour_rgb (1,3) double {ValidationUtils.MustBeValidRgbVector(vdNewColour_rgb)}
            end
            
            obj.m2d3DMeshEdgeColour_rgb(dRegionOfInterestNumber,:) = vdNewColour_rgb;
        end
        
        function SetRegionOfInterestVoxelMaskVisibility(obj, dRegionOfInterestNumber, bVisible)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            obj.vbDisplayVoxelMask(dRegionOfInterestNumber) = bVisible;
        end
        
        function SetRegionOfInterestVoxelMaskOutlineVisibility(obj, dRegionOfInterestNumber, bVisible)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            obj.vbDisplayVoxelMaskOutline(dRegionOfInterestNumber) = bVisible;
        end
        
        function SetRegionOfInterestVoxelMaskOutlineLineWidth(obj, dRegionOfInterestNumber, dNewWidth)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dNewWidth (1,1) double {mustBePositive(dNewWidth), mustBeFinite(dNewWidth)}
            end
            
            obj.vdVoxelMaskOutlineLineWidth(dRegionOfInterestNumber) = dNewWidth;
        end
        
        function SetRegionOfInterestVoxelMaskOutlineLineStyle(obj, dRegionOfInterestNumber, chLineStyle)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                chLineStyle (1,:) char
            end
            
            obj.c1chVoxelMaskOutlineLineStyle{dRegionOfInterestNumber} = chLineStyle;
        end
        
        function SetRegionOfInterest3DMeshVisibility(obj, dRegionOfInterestNumber, bVisible)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            obj.vbDisplay3DMesh(dRegionOfInterestNumber) = bVisible;
        end
        
        function SetRegionOfInterest3DMeshAlpha(obj, dRegionOfInterestNumber, dAlpha)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dAlpha (1,1) double {ValidationUtils.MustBeValidAlphaValue(dAlpha)}
            end
            
            obj.vd3DMeshAlpha(dRegionOfInterestNumber) = dAlpha;
        end
        
        function SetRegionOfInterest3DMeshEdgeVisibility(obj, dRegionOfInterestNumber, bVisible)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                bVisible (1,1) logical
            end
            
            obj.vbDisplay3DMeshEdges(dRegionOfInterestNumber) = bVisible;
        end
        
        function SetRegionOfInterestVoxelMaskAlpha(obj, dRegionOfInterestNumber, dNewAlpha)
            arguments
                obj
                dRegionOfInterestNumber (1,1) double {MustBeValidRegionOfInterestNumbers(obj, dRegionOfInterestNumber)}
                dNewAlpha (1,1) double {ValidationUtils.MustBeValidAlphaValue(dNewAlpha)}
            end
            
            obj.vdVoxelMaskAlpha(dRegionOfInterestNumber) = dNewAlpha;
        end
        
        % Single properities for all ROIs:
        function SetAllVoxelMaskVisibilities(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterestVoxelMaskVisibility(dRoiIndex, bVisible);
            end
        end
        
        function SetAllVoxelMaskAlphas(obj, dNewAlpha)
            arguments
                obj
                dNewAlpha (1,1) double {ValidationUtils.MustBeValidAlphaValue(dNewAlpha)}
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterestVoxelMaskAlpha(dRoiIndex, dNewAlpha);
            end
        end
        
        function SetAllVoxelMaskOutlineVisibilities(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterestVoxelMaskOutlineVisibility(dRoiIndex, bVisible);
            end
        end
        
        function SetAllVoxelMaskOutlineLineWidths(obj, dNewWidth)
            arguments
                obj
                dNewWidth (1,1) double {mustBePositive(dNewWidth), mustBeFinite(dNewWidth)}
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterestVoxelMaskOutlineLineWidth(dRoiIndex, dNewWidth);
            end
        end
        
        function SetAllVoxelMaskOutlineLineStyles(obj, chNewLineStyle)
            arguments
                obj
                chNewLineStyle (1,:) char
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterestVoxelMaskOutlineLineStyle(dRoiIndex, chNewLineStyle);
            end
        end
        
        function SetAll3DMeshVisibilities(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterest3DMeshVisibility(dRoiIndex, bVisible);
            end
        end
        
        function SetAll3DMeshAlphas(obj, dAlpha)
            arguments
                obj
                dAlpha (1,1) double {ValidationUtils.MustBeValidAlphaValue(dAlpha)}
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterest3DMeshAlpha(dRoiIndex, dAlpha);
            end
        end
        
        function SetAll3DMeshEdgeVisibilities(obj, bVisible)
            arguments
                obj
                bVisible (1,1) logical
            end
            
            for dRoiIndex=1:obj.oRegionsOfInterest.GetNumberOfRegionsOfInterest()
                obj.SetRegionOfInterest3DMeshEdgeVisibility(dRoiIndex, bVisible);
            end
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static 
    % *                        PROTECTED METHODS                          *             2 Not Abstract    X.2 Static
    % *********************************************************************
         
    methods (Access = protected)
        
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
        end
    end
    
    
    
    % *********************************************************************   ORDERING: 1 Abstract     -> X.1 Not Static
    % *                         PRIVATE METHODS                           *             2 Not Abstract    X.2 Static
    % *********************************************************************
    
    methods (Access = private)
        
        % >>>>>>>>>>>>>>> RENDERING HELPERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        function RenderPlaneMaskOutlineForMaskByRegionOfInterestNumber(obj, m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm, oImagingPlaneAxes, dRegionOfInterestNumber, dRenderGroupId)
                        
            % render voxel map outlines
            c1m2dVoxelOutlineCoordinates = GetVoxelOutlineCoordinatesForSlice_mex(m2bMask);
            
            dNumLines = length(c1m2dVoxelOutlineCoordinates);
            
            c1hOutlinesPerRoi = cell(1, dNumLines);
            
            for dLineIndex=1:dNumLines
                m2dCoordinates = c1m2dVoxelOutlineCoordinates{dLineIndex};
                
                [vdScaledRowCoords_mm, vdScaledColCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(...
                    m2dCoordinates(:,1), m2dCoordinates(:,2),...
                    dRowVoxelSpacing_mm, dColVoxelSpacing_mm);
                
                c1hOutlinesPerRoi{dLineIndex} = plot(...
                    oImagingPlaneAxes.GetAxes(),...
                    vdScaledColCoords_mm,...
                    vdScaledRowCoords_mm);
            end
            
            % update tracking                           
            obj.c1c1hVoxelMaskOutlineHandles = [obj.c1c1hVoxelMaskOutlineHandles, {c1hOutlinesPerRoi}];
            obj.vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber = [obj.vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber, dRegionOfInterestNumber];
            obj.vdVoxelMaskImageOutlineHandlesRenderGroupId = [obj.vdVoxelMaskImageOutlineHandlesRenderGroupId, dRenderGroupId];
                        
            obj.UpdateRenderedVoxelMaskOutlines(length(obj.vdVoxelMaskImageOutlineHandlesRenderGroupId));            
        end
        
        function RenderPlaneMaskForMaskByRegionOfInterestNumber(obj, m2bMask, dRowVoxelSpacing_mm, dColVoxelSpacing_mm, oImagingPlaneAxes, dRegionOfInterestNumber, dRenderGroupId)
            % get scaled voxel coordinates for image location
            vdDims = size(m2bMask);
            
            [vdScaledRowCoords_mm, vdScaledColCoords_mm] = GeometricalImagingObjectRenderer.GetScaledVoxelCoordinatesFromVoxelCoordinates(...
                [1,vdDims(1)], [1,vdDims(2)],...
                dRowVoxelSpacing_mm, dColVoxelSpacing_mm);
            
            % render voxel map image
            hImageHandle = image(...
                oImagingPlaneAxes.GetAxes(),...
                'XData', vdScaledColCoords_mm,...
                'YData', vdScaledRowCoords_mm,...
                'CData', zeros([size(m2bMask), 3]),...
                'AlphaData', double(m2bMask));
            
            % update tracking                
            obj.c1hVoxelMaskImageHandles = [obj.c1hVoxelMaskImageHandles, {hImageHandle}];
            obj.vdVoxelMaskImageHandlesRegionOfInterestNumber = [obj.vdVoxelMaskImageHandlesRegionOfInterestNumber, dRegionOfInterestNumber];
            obj.vdVoxelMaskImageHandlesRenderGroupId = [obj.vdVoxelMaskImageHandlesRenderGroupId, dRenderGroupId];
                           
            obj.UpdateRenderedVoxelMask(length(obj.c1hVoxelMaskImageHandles));
        end
        
        
        % >>>>>>>>>>>>>>>>>>>> UDPATERS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        function UpdateRenderedVoxelMask(obj, dRenderedMaskIndex)
            hImageHandle = obj.c1hVoxelMaskImageHandles{dRenderedMaskIndex};
            dRoiNumber = obj.vdVoxelMaskImageHandlesRegionOfInterestNumber(dRenderedMaskIndex);
            
            if obj.vbDisplayVoxelMask(dRoiNumber)
                chVisible = 'on';
            else
                chVisible = 'off';
            end
                        
            hImageHandle.Visible = chVisible;
            
            vdColour_rgb = obj.m2dVoxelMaskColour_rgb(dRoiNumber,:);
            hImageHandle.CData(:,:,1) = vdColour_rgb(1);
            hImageHandle.CData(:,:,2) = vdColour_rgb(2);
            hImageHandle.CData(:,:,3) = vdColour_rgb(3);
            
            if obj.vdVoxelMaskAlpha(dRoiNumber) == 0 % don't want to set all alphas to 0, or else we'll need to consult w/ the ROI of what the mask looks like. Instead, leave alpha values as is and hide
                hImageHandle.Visible = 'off';
            else
                hImageHandle.AlphaData(hImageHandle.AlphaData ~= 0) = obj.vdVoxelMaskAlpha(dRoiNumber);
            end
        end
        
        function UpdateRenderedVoxelMaskOutlines(obj, dRenderedOutlineIndex)
            c1hOutlineHandles = obj.c1c1hVoxelMaskOutlineHandles{dRenderedOutlineIndex};
            dRoiNumber = obj.vdVoxelMaskImageOutlineHandlesRegionOfInterestNumber(dRenderedOutlineIndex);
            
            % need to loop through outlines (can have multiple per slice if
            % ROI fragmented)
            if obj.vbDisplayVoxelMaskOutline(dRoiNumber)
                chVisible = 'on';
            else
                chVisible = 'off';
            end
            
            vdColour_rgb = obj.m2dVoxelMaskOutlineColour_rgb(dRoiNumber,:);
            dLineWidth = obj.vdVoxelMaskOutlineLineWidth(dRoiNumber);
            chLineStyle = obj.c1chVoxelMaskOutlineLineStyle{dRoiNumber};
            
            for dOutlineIndex=1:length(c1hOutlineHandles)
                hOutline = c1hOutlineHandles{dOutlineIndex};
                
                hOutline.Visible = chVisible;
                hOutline.Color = vdColour_rgb;
                hOutline.LineWidth = dLineWidth;
                hOutline.LineStyle = chLineStyle;
            end
        end
        
        function UpdateRendered3DMesh(obj, dRenderedMeshIndex)
            hMesh = obj.c1h3DMeshHandles{dRenderedMeshIndex};
            dRoiNumber = obj.vd3DMeshHandlesRegionOfInterestNumber(dRenderedMeshIndex);
            
            if obj.vbDisplay3DMesh(dRoiNumber)
                chVisible = 'on';
            else
                chVisible = 'off';
            end
            
            if obj.vbDisplay3DMeshEdges(dRoiNumber)
                xEdgeColour = obj.m2d3DMeshEdgeColour_rgb(dRoiNumber,:);
            else
                xEdgeColour = 'none';
            end
            
            hMesh.Visible = chVisible;
            hMesh.FaceColor = obj.m2d3DMeshFaceColour_rgb(dRoiNumber,:);
        	hMesh.FaceAlpha = obj.vd3DMeshAlpha(dRoiNumber);
            hMesh.EdgeColor = xEdgeColour;
            hMesh.EdgeAlpha = obj.vd3DMeshAlpha(dRoiNumber);
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


